//
//  WHPWhisperAppClient.m
//  Whisper-iOS-SDK
//
//  Created by Yujin Ariza on 6/23/14.
//  Copyright (c) 2014 Whisper. All rights reserved.
//

#import "WHPWhisperAppClient.h"
#import <Whisper-iOS-SDK/NSData+WHPImageFormat.h>
#import <Whisper-iOS-SDK/NSError+WHPErrors.h>

CGSize const WHPMinimumSourceImageSize = {640.0f, 920.0f};
static CGSize const WHPButtonSizeSmall = {44.0f, 44.0f};
static CGSize const WHPButtonSizeMedium = {60.0f, 60.0f};
static CGSize const WHPButtonSizeLarge = {80.0f, 80.0f};

static CGFloat const WHPButtonCornerRadius = 10.0f;
static CGFloat const WHPSourceImageQuality = 1.0f;

static NSString *const WHPWhisperBundleIdentifier = @"sh.whisper.whisperapp";
static NSString *const WHPResourceBundleName = @"WhisperResources";
static NSString *const WHPAppStoreURL = @"itms://itunes.apple.com/us/app/whisper-share-express-meet/id506141837";
static NSString *const WHPWhisperAppURL = @"whisperapp://";

static NSString *const WHPTemporaryDirectoryName = @"whisperTmp";
static NSString *const WHPTemporaryFileName = @"whisperTemp.whimage";
static NSString *const WHPWhisperIconResourceName = @"whp_whisper_button";
static NSString *const WHPWhisperIconResourceType = @"png";

static NSString *const WHPWhisperImageUTI = @"sh.whisper.whimage";

static NSString *const WHPRedirectMessage = @"You don't have Whisper Installed. You are about to be taken to the Whisper App Store page. Continue?";
static NSString *const WHPUpdateMessage = @"Your Whisper App is not up to date. You are about to be taken to the Whisper App Store page. Continue?";
static NSString *const WHPCannotOpenAppStoreMessage = @"Cannot open Whisper App Store Page.";

static NSString *const annotationKeyCallbackURL = @"callback_url";
static NSString *const annotationKeyWhisperText = @"whisper_text";
static NSString *const annotationKeyParentWid = @"parent_wid";

@interface WHPWhisperAppClient () <UIDocumentInteractionControllerDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) UIDocumentInteractionController *documentController;
@property (nonatomic, strong) NSURL *fileURL;

@property (nonatomic, weak) UIBarButtonItem *item;
@property (nonatomic, weak) UIView *view;
@property CGRect rect;

-(void)cleanUpTempDirectory;
-(BOOL)whisperAppExists;
-(void)redirectToAppStore;
-(void)promptForRedirect;
-(BOOL)isLegalImageSize:(UIImage *)image;
-(NSString *)getApplicationURLScheme;
-(BOOL)writeToCache:(NSData *)data error:(NSError **)error;
-(BOOL)showFileOpenDialog:(NSURL *)url error:(NSError **)error;
-(void)createWhisperWithDelegate;
-(BOOL)prepareWhisperWithMenuPresentationType:(WHPMenuPresentationType)type;
-(BOOL)createWhisperWithSourceType:(WHPImageSourceType)sourceType error:(NSError **)error;

@end

@implementation WHPWhisperAppClient

#pragma mark - Singleton

+(WHPWhisperAppClient *)sharedClient
{
    static WHPWhisperAppClient *singleton = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        singleton = [[WHPWhisperAppClient alloc] init];
    });
    return singleton;
}

#pragma mark - Initialization

-(id)init
{
    if (self = [super init]) {
#ifdef WHISPER_DEBUG
        NSLog(@"WHPWhisperAppClient: Init");
#endif
        _animated = YES;
        [self cleanUpTempDirectory];
    }
    return self;
}

#pragma mark - Public

+(CGSize)whisperButtonSizeForSize:(WHPWhisperAppClientButtonSize)size
{
    switch (size) {
        case kWHPWhisperAppClientButtonSize_Small:
            return WHPButtonSizeSmall;
            break;
        case kWHPWhisperAppClientButtonSize_Medium:
            return WHPButtonSizeMedium;
        case kWHPWhisperAppClientButtonSize_Large:
            return WHPButtonSizeLarge;
        default:
            return WHPButtonSizeMedium;
    }
}

+(BOOL)handleOpenURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication
{
#ifdef WHISPER_DEBUG
    NSLog(@"WHPWhisperAppClient: Handle Open URL %@ from %@", url.path, sourceApplication);
#endif
    [[WHPWhisperAppClient sharedClient] cleanUpTempDirectory];
    
    if ([sourceApplication isEqualToString:WHPWhisperBundleIdentifier]) {

        return YES;
    }
    return NO;
}

-(UIButton *)whisperButtonWithSize:(WHPWhisperAppClientButtonSize)size rounded:(BOOL)rounded
{
    return [self whisperButtonWithCustomSize:[WHPWhisperAppClient whisperButtonSizeForSize:size] rounded:rounded];
}

-(UIButton *)whisperButtonWithCustomSize:(CGSize)size rounded:(BOOL)rounded
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    NSBundle *whisperBundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:WHPResourceBundleName ofType:@"bundle"]];
    NSString *buttonPath = [whisperBundle pathForResource:WHPWhisperIconResourceName ofType:WHPWhisperIconResourceType];
    
#ifdef WHISPER_DEBUG
    NSLog(@"Getting resource %@.%@ from bundle %@", WHPWhisperIconResourceName, WHPWhisperIconResourceType, whisperBundle.bundlePath);
#endif
    
    UIImage *buttonImage = [UIImage imageWithContentsOfFile:buttonPath];
    
    button.frame = CGRectMake(0, 0, size.width, size.height);
    
    if (rounded) {
        button.layer.cornerRadius = WHPButtonCornerRadius;
        button.clipsToBounds = YES;
    }
    
#ifdef WHISPER_DEBUG
    NSLog(@"WHPWhisperAppClient: Button with size (%f, %f) with rounded: %@", buttonSize.width, buttonSize.height, rounded ? @"YES" : @"NO");
#endif
    
    [button setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [button.imageView setContentMode:UIViewContentModeScaleAspectFit];
    
    [button addTarget:self action:@selector(createWhisperWithDelegate) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

-(void)prepareWithBarButtonItem:(UIBarButtonItem *)item
{
    NSParameterAssert(item);
#ifdef WHISPER_DEBUG
    NSLog(@"WHPWhisperAppClient: Preparing with bar button item %@", item);
#endif
    _item = item;
    _view = nil;
    _rect = CGRectZero;
}

-(void)prepareWithView:(UIView *)view inRect:(CGRect)rect
{
    NSParameterAssert(view);
    NSParameterAssert(!CGRectIsEmpty(rect));
#ifdef WHISPER_DEBUG
    NSLog(@"WHPWhisperAppClient: Preparing with view %@ and rect ((%f, %f), (%f, %f))", view, rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
#endif
    _item = nil;
    _view = view;
    _rect = rect;
}

-(BOOL)createWhisperWithData:(NSData *)data error:(NSError **)error
{
#ifdef WHISPER_DEBUG
    NSLog(@"WHPWhisperAppClient: Whisper with data (%u bytes)", data.length);
#endif
    if (!data) {
#ifdef WHISPER_DEBUG
        NSLog(@"WHPWhisperAppClient: ERROR - Data is nil");
#endif
        *error = [NSError whp_ErrorCouldNotInitializeImageFromData];
        return NO;
    }
    if (![data whp_isJPG]) {
#ifdef WHISPER_DEBUG
        NSLog(@"WHPWhisperAppClient: ERROR - Data is not in JPEG format");
#endif
        *error = [NSError whp_ErrorWrongImageFormat];
        return NO;
    }
    if (![self writeToCache:data error:error])
        return NO;
    
    return [self createWhisperWithCachedURL:_fileURL error:error];
}

-(BOOL)createWhisperWithImage:(UIImage *)image error:(NSError **)error
{
    NSParameterAssert(image);
#ifdef WHISPER_DEBUG
    NSLog(@"WHPWhisperAppClient: Whisper with image (%fx%f points)", image.size.width, image.size.height);
#endif
    NSData *data = UIImageJPEGRepresentation(image, WHPSourceImageQuality);
    return [self createWhisperWithData:data error:error];
}

-(BOOL)createWhisperWithPath:(NSString *)path error:(NSError **)error
{
    NSParameterAssert(path);
#ifdef WHISPER_DEBUG
    NSLog(@"WHPWhisperAppClient: Whisper with path %@", path);
#endif
    NSURL *url = [NSURL fileURLWithPath:path];
    return [self createWhisperWithURL:url error:error];
}

-(BOOL)createWhisperWithURL:(NSURL *)url error:(NSError **)error
{
    NSParameterAssert(url);
#ifdef WHISPER_DEBUG
    NSLog(@"WHPWhisperAppClient: Whisper with URL %@", url.path);
#endif
    NSData *imageData = [NSData dataWithContentsOfURL:url options:NSDataReadingUncached error:error];
    if (!imageData)
        return NO;
    return [self createWhisperWithData:imageData error:error];
}

-(BOOL)createWhisperWithCachedURL:(NSURL *)url error:(NSError **)error
{
#ifdef WHISPER_DEBUG
    NSLog(@"WHPWhisperAppClient: Whisper with cached URL %@", url.path);
#endif
    NSData *imageData = [NSData dataWithContentsOfURL:url];
    UIImage *image = [UIImage imageWithData:imageData];
    if (!image) {
#ifdef WHISPER_DEBUG
        NSLog(@"WHPWhisperAppClient: ERROR - unable to load URL into UIImage");
#endif
        *error = [NSError whp_ErrorCouldNotInitializeImageFromData];
        return NO;
    }
    if (![self isLegalImageSize:image]) {
#ifdef WHISPER_DEBUG
        NSLog(@"WHPWhisperAppClient: ERROR - Image is too small (%fx%f)", image.size.width, image.size.height);
#endif
        *error = [NSError whp_ErrorImageIsTooSmall];
        return NO;
    }
    if ([self whisperAppExists]) {
        if (![self showFileOpenDialog:url error:error])
            return NO;
    }
    else {
#ifdef WHISPER_DEBUG
        NSLog(@"WHPWhisperAppClient: Whisper app not found. Redirect to App Store");
#endif
        if (_autotakeToAppStore) {
            //redirect
            [self redirectToAppStore];
        }
        else {
            //prompt, then redirect
            [self promptForRedirect];
        }
    }
    return YES;
}

#pragma mark - UIAlertView

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
#ifdef WHISPER_DEBUG
        NSLog(@"WHPWhisperAppClient: AlertView cancelled");
#endif
    }
    else {
#ifdef WHISPER_DEBUG
        NSLog(@"WHPWhisperAppClient: AlertView confirmed");
#endif
        [self redirectToAppStore];
    }
}

#pragma mark - Private

-(void)cleanUpTempDirectory
{
    BOOL isDir;
    NSError *error = nil;
    NSString *dirPath = [NSTemporaryDirectory() stringByAppendingPathComponent:WHPTemporaryDirectoryName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:dirPath isDirectory:&isDir]) {
#ifdef WHISPER_DEBUG
        NSLog(@"WHPWhisperAppClient: Removing Temp directory %@", dirPath);
#endif
        [[NSFileManager defaultManager] removeItemAtPath:dirPath error:&error];
    }
    return;
}

-(BOOL)whisperAppExists
{
    return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:WHPWhisperAppURL]];
}

-(void)redirectToAppStore
{
    NSURL *whisperAppURL = [NSURL URLWithString:WHPAppStoreURL];
    if ([[UIApplication sharedApplication] canOpenURL:whisperAppURL]) {
        [[UIApplication sharedApplication] openURL:whisperAppURL];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Cannot open URL" message:WHPCannotOpenAppStoreMessage delegate:self cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil, nil];
        alert.alertViewStyle = UIAlertViewStyleDefault;
        [alert show];
    }
}

-(void)promptForRedirect
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Redirect Alert" message:WHPRedirectMessage delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK!", nil];
    alert.alertViewStyle = UIAlertViewStyleDefault;
    [alert show];
}

-(void)promptForUpdate
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Redirect Alert" message:WHPUpdateMessage delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK!", nil];
    alert.alertViewStyle = UIAlertViewStyleDefault;
    [alert show];
}

-(BOOL)isLegalImageSize:(UIImage *)image
{
    CGSize size = image.size;
    return size.width >= WHPMinimumSourceImageSize.width && size.height >= WHPMinimumSourceImageSize.height;
}

-(NSString *)getApplicationURLScheme
{
    if (_customCallbackURL) {
        return _customCallbackURL;
    }
    NSArray *urlTypes = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleURLTypes"];
    if (urlTypes.count == 0) {
        return nil;
    }
    NSArray *urlSchemes = [[urlTypes objectAtIndex:0] objectForKey:@"CFBundleURLSchemes"];
    if (urlSchemes.count == 0) {
        return nil;
    }
    return [urlSchemes objectAtIndex:0];
}

-(BOOL)writeToCache:(NSData *)data error:(NSError **)error
{
    
    NSURL *directoryURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:WHPTemporaryDirectoryName] isDirectory:YES];
    [[NSFileManager defaultManager] createDirectoryAtURL:directoryURL withIntermediateDirectories:YES attributes:nil error:error];
    NSString *fileName = [NSString stringWithFormat:@"%@_%@", [[NSProcessInfo processInfo] globallyUniqueString], WHPTemporaryFileName];
    _fileURL = [directoryURL URLByAppendingPathComponent:fileName];
    
#ifdef WHISPER_DEBUG
    NSLog(@"WHPWhisperAppClient: Writing data (%u bytes) to %@", data.length, _fileURL);
#endif
    *error = nil;
    return [data writeToFile:_fileURL.path options:NSDataWritingAtomic error:error];
}

-(BOOL)showFileOpenDialog:(NSURL *)url error:(NSError **)error
{
    BOOL result;
    NSString *urlScheme = [self getApplicationURLScheme];
    
    if (_documentController) {
        [_documentController dismissMenuAnimated:_animated];
    }
    _documentController = [UIDocumentInteractionController interactionControllerWithURL:url];
    _documentController.delegate = self;
    _documentController.UTI = WHPWhisperImageUTI;
    
    NSMutableDictionary *annotations = [[NSMutableDictionary alloc] init];
    if (urlScheme) {
        annotations[annotationKeyCallbackURL] = urlScheme;
    }
    if (_whisperText.length > 0) {
        annotations[annotationKeyWhisperText] = _whisperText;
    }
    _documentController.annotation = annotations;
#ifdef WHISPER_DEBUG
    NSLog(@"WHPWhisperAppClient: Initializing Document controller with URL: %@, callback: %@", url.path, urlScheme ? urlScheme : @"(none)");
#endif
    
    if (_item) {
        if (_optionsMenu) {
#ifdef WHISPER_DEBUG
            NSLog(@"WHPWhisperAppClient: Attempting to open Options Menu from UIBarButtonItem");
#endif
            result = [_documentController presentOptionsMenuFromBarButtonItem:_item animated:_animated];
        }
        else {
#ifdef WHISPER_DEBUG
            NSLog(@"WHPWhisperAppClient: Attempting to open Menu from UIBarButtonItem");
#endif
            result = [_documentController presentOpenInMenuFromBarButtonItem:_item animated:_animated];
        }
    }
    else if (_view) {
        if (_optionsMenu) {
#ifdef WHISPER_DEBUG
            NSLog(@"WHPWhisperAppClient: Attempting to open Options Menu from UIView");
#endif
            result = [_documentController presentOptionsMenuFromRect:_rect inView:_view animated:_animated];
        }
        else {
#ifdef WHISPER_DEBUG
            NSLog(@"WHPWhisperAppClient: Attempting to open Menu from UIView");
#endif
            result = [_documentController presentOpenInMenuFromRect:_rect inView:_view animated:_animated];
        }
    }
    else {
        
        
#ifdef WHISPER_DEBUG
        NSLog(@"WHPWhisperAppClient: ERROR - Not configured");
#endif
        *error = [NSError whp_ErrorNotConfigured];
        return NO;
    }
    if (!result) {
#ifdef WHISPER_DEBUG
        NSLog(@"WHPWhisperAppClient: Whisper not up to date. Prompting for update");
#endif
        [self promptForUpdate];
        return YES;
    }
    return YES;
}

-(void)createWhisperWithDelegate
{
    NSError *error = nil;
    BOOL success = NO;
    
    for (WHPMenuPresentationType menuType = 0; menuType < WHPMenuPresentationTypeCount; menuType++) {
        success = [self prepareWhisperWithMenuPresentationType:menuType];
        if (success) {
            break;
        }
    }
    if (!success) {
        error = [NSError whp_ErrorNotConfigured];
        if ([_delegate respondsToSelector:@selector(whisperAppClientDidFailWithError:)]) {
            [_delegate whisperAppClientDidFailWithError:error];
        }
        return;
    }
    if ([_delegate respondsToSelector:@selector(whisperAppClientTextForWhisper)]) {
        _whisperText = [_delegate whisperAppClientTextForWhisper];
    }
    else {
        _whisperText = nil;
    }
    for (WHPImageSourceType sourceType = 0; sourceType < WHPImageSourceTypeCount; sourceType++) {
        error = nil;
        success = [self createWhisperWithSourceType:sourceType error:&error];
        if (success) {
            break;
        }
    }
    if (!success) {
        if ([_delegate respondsToSelector:@selector(whisperAppClientDidFailWithError:)]) {
            [_delegate whisperAppClientDidFailWithError:error];
        }
    }
}

-(BOOL)prepareWhisperWithMenuPresentationType:(WHPMenuPresentationType)type
{
    switch (type) {
        case kWHPMenuPresentationType_View:
        {
            if ([_delegate respondsToSelector:@selector(whisperAppClientViewForMenuPresentation)]) {
                UIView *view = [_delegate whisperAppClientViewForMenuPresentation];
                [self prepareWithView:view inRect:view.frame];
                return YES;
            }
            break;
        }
        case kWHPMenuPresentationType_BarButtonItem:
        {
            if ([_delegate respondsToSelector:@selector(whisperAppClientBarButtonItemForMenuPresentation)]) {
                [self prepareWithBarButtonItem:[_delegate whisperAppClientBarButtonItemForMenuPresentation]];
                return YES;
            }
            break;
        }
        default:
            break;
    }
    return NO;
}

-(BOOL)createWhisperWithSourceType:(WHPImageSourceType)sourceType error:(NSError **)error
{
    switch (sourceType) {
        case kWHPImageSourceType_Image:
        {
            if ([_delegate respondsToSelector:@selector(whisperAppClientSourceImageForWhisper)]) {
                return [self createWhisperWithImage:[_delegate whisperAppClientSourceImageForWhisper] error:error];
            }
            break;
        }
        case kWHPImageSourceType_Data:
        {
            if ([_delegate respondsToSelector:@selector(whisperAppClientSourceDataForWhisper)]) {
                return [self createWhisperWithData:[_delegate whisperAppClientSourceDataForWhisper] error:error];
            }
        }
        case kWHPImageSourceType_Path:
        {
            if ([_delegate respondsToSelector:@selector(whisperAppClientSourcePathForWhisper)]) {
                return [self createWhisperWithPath:[_delegate whisperAppClientSourcePathForWhisper] error:error];
            }
        }
        case kWHPImageSourceType_URL:
        {
            if ([_delegate respondsToSelector:@selector(whisperAppClientSourceURLForWhisper)]) {
                return [self createWhisperWithURL:[_delegate whisperAppClientSourceURLForWhisper] error:error];
            }
        }
        default:
            break;
    }
    *error = [NSError whp_ErrorDelegateMethodNotImplemented];
    return NO;
}

@end
