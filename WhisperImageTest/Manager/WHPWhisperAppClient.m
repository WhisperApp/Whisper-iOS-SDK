//
//  WHPWhisperAppClient.m
//  WhisperImageTest
//
//  Created by Yujin Ariza on 6/23/14.
//  Copyright (c) 2014 Whisper. All rights reserved.
//

#import "WHPWhisperAppClient.h"
#import "NSData+ImageFormat.h"
#import "NSError+WHPErrors.h"

CGSize const whp_minImageSize = {640.0f, 920.0f};
CGSize const whp_imageSizeSmall = {50.0f, 50.0f};
CGSize const whp_imageSizeMedium = {60.0f, 60.0f};
CGSize const whp_imageSizeLarge = {75.0f, 75.0f};

CGFloat const whp_buttonCornerRadius = 10.0f;
CGFloat const whp_imageQuality = 1.0f;

NSString *const whp_bundleID = @"sh.whisper.whisperapp";
NSString *const whp_resourceBundle = @"WhisperResources.bundle";
NSString *const whp_appStoreURL = @"http://itunes.apple.com/us/app/whisper-share-express-meet/id506141837?mt=8";
NSString *const whp_appURL = @"whisperapp://";

NSString *const tempDirectoryName = @"whisperTmp";
NSString *const tempFileName = @"whisperTemp.whimage";
NSString *const whisperIconName = @"whisper_appicon152";
NSString *const whisperIconType = @"png";

NSString *const redirectMessage = @"You don't have Whisper Installed. You are about to be taken to the Whisper App Store page. Continue?";
NSString *const updateMessage = @"Your Whisper App is not up to date. You are about to be taken to the Whisper App Store page. Continue?";

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

#pragma mark - Class

+(UIButton *)whisperButtonWithSize:(WHPWhisperAppClientButtonSize)size rounded:(BOOL)rounded
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    NSString *resourceName = [NSString stringWithFormat:@"%@/%@", whp_resourceBundle, whisperIconName];
    NSString *buttonPath = [[NSBundle mainBundle] pathForResource:resourceName ofType:whisperIconType];
    
    UIImage *buttonImage = [UIImage imageWithContentsOfFile:buttonPath];
    
    CGSize buttonSize = [WHPWhisperAppClient whisperButtonSizeForSize:size];
    button.frame = CGRectMake(0, 0, buttonSize.width, buttonSize.height);
    
    if (rounded) {
        button.layer.cornerRadius = whp_buttonCornerRadius;
        button.clipsToBounds = YES;
    }
    
    [button setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [button.imageView setContentMode:UIViewContentModeScaleAspectFit];
    return button;
}

+(CGSize)whisperButtonSizeForSize:(WHPWhisperAppClientButtonSize)size
{
    switch (size) {
        case kWHPWhisperAppClientButtonSize_Small:
            return whp_imageSizeSmall;
            break;
        case kWHPWhisperAppClientButtonSize_Medium:
            return whp_imageSizeMedium;
        case kWHPWhisperAppClientButtonSize_Large:
            return whp_imageSizeLarge;
        default:
            return whp_imageSizeMedium;
    }
}

+(BOOL)handleOpenURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication
{
    [[WHPWhisperAppClient sharedClient] cleanUpTempDirectory];
    
    if ([sourceApplication isEqualToString:whp_bundleID]) {

        return YES;
    }
    return NO;
}

#pragma mark - Public

-(void)prepareWithBarButtonItem:(UIBarButtonItem *)item
{
    NSAssert(item, @"item cannot be nil");
    _item = item;
    _view = nil;
    _rect = CGRectZero;
}

-(void)prepareWithView:(UIView *)view inRect:(CGRect)rect
{
    NSAssert(view, @"view cannot be nil");
    NSAssert(!CGRectIsEmpty(rect), @"rect cannot be empty");
    _item = nil;
    _view = view;
    _rect = rect;
}

-(BOOL)createWhisperWithData:(NSData *)data error:(NSError **)error
{
    if (!data) {
        *error = [NSError whp_ErrorCouldNotInitializeImageFromData];
        return NO;
    }
    if (![data whp_isJPG]) {
        *error = [NSError whp_ErrorWrongImageFormat];
        return NO;
    }
    if (![self writeToCache:data error:error])
        return NO;
    
    *error = nil;
    return [self createWhisperWithCachedURL:_fileURL error:error];
}

-(BOOL)createWhisperWithImage:(UIImage *)image error:(NSError **)error
{
    NSData *data = UIImageJPEGRepresentation(image, whp_imageQuality);
    *error = nil;
    return [self createWhisperWithData:data error:error];
}

-(BOOL)createWhisperWithPath:(NSString *)path error:(NSError **)error
{
    NSURL *url = [NSURL URLWithString:path relativeToURL:[NSURL URLWithString:@"file://"]];
    *error = nil;
    return [self createWhisperWithURL:url error:error];
}

-(BOOL)createWhisperWithURL:(NSURL *)url error:(NSError **)error
{

    NSData *imageData = [NSData dataWithContentsOfURL:url options:NSDataReadingUncached error:error];
    if (!imageData)
        return NO;
    *error = nil;
    return [self createWhisperWithData:imageData error:error];
}

-(BOOL)createWhisperWithCachedURL:(NSURL *)url error:(NSError **)error
{
    
    NSData *imageData = [NSData dataWithContentsOfURL:url];
    UIImage *image = [UIImage imageWithData:imageData];
    if (!image) {
        *error = [NSError whp_ErrorCouldNotInitializeImageFromData];
        return NO;
    }
    if (![self isLegalImageSize:image]) {
        *error = [NSError whp_ErrorImageIsTooSmall];
        return NO;
    }
    if ([self whisperAppExists]) {
        *error = nil;
        if (![self showFileOpenDialog:url error:error])
            return NO;
    }
    else {
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
#pragma mark UIAlertView

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        // cancelled
    }
    else {
        // ok!
        [self redirectToAppStore];
    }
}

#pragma mark Private

-(id)init
{
    if (self=[super init]) {
        _animated = YES;
        [self cleanUpTempDirectory];
    }
    return self;
}

-(void)cleanUpTempDirectory
{
    BOOL isDir;
    NSError *error = nil;
    NSString *dirPath = [NSTemporaryDirectory() stringByAppendingPathComponent:tempDirectoryName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:dirPath isDirectory:&isDir]) {
        [[NSFileManager defaultManager] removeItemAtPath:dirPath error:&error];
    }
    return;
}

-(BOOL)whisperAppExists
{
    return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:whp_appURL]];
}

-(void)redirectToAppStore
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:whp_appStoreURL]];
}

-(void)promptForRedirect
{
    WHPWhisperAppClient *delegate = self;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Redirect Alert" message:redirectMessage delegate:delegate cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK!", nil];
    alert.alertViewStyle = UIAlertViewStyleDefault;
    [alert show];
}

-(void)promptForUpdate
{
    WHPWhisperAppClient *delegate = self;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Redirect Alert" message:updateMessage delegate:delegate cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK!", nil];
    alert.alertViewStyle = UIAlertViewStyleDefault;
    [alert show];
}

-(BOOL)isLegalImageSize:(UIImage *)image
{
    CGSize size = image.size;
    return size.width >= whp_minImageSize.width && size.height >= whp_minImageSize.height;
}

-(NSString *)getApplicationURLScheme
{
    NSArray *urlTypes = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleURLTypes"];
    if (urlTypes.count == 0)
        return nil;
    NSArray *urlSchemes = [[urlTypes objectAtIndex:0] objectForKey:@"CFBundleURLSchemes"];
    if (urlSchemes.count == 0)
        return nil;
    return [urlSchemes objectAtIndex:0];
}

-(BOOL)writeToCache:(NSData *)data error:(NSError **)error
{
    
    NSURL *directoryURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:tempDirectoryName] isDirectory:YES];
    [[NSFileManager defaultManager] createDirectoryAtURL:directoryURL withIntermediateDirectories:YES attributes:nil error:error];
    NSString *fileName = [NSString stringWithFormat:@"%@_%@", [[NSProcessInfo processInfo] globallyUniqueString], tempFileName];
    _fileURL = [directoryURL URLByAppendingPathComponent:fileName];
    
    *error = nil;
    return [data writeToFile:_fileURL.path options:NSDataWritingAtomic error:error];
}

-(BOOL)showFileOpenDialog:(NSURL *)url error:(NSError **)error
{
    BOOL result;
    NSString *urlScheme = [self getApplicationURLScheme];
    
    self.documentController = [UIDocumentInteractionController interactionControllerWithURL:url];
    _documentController.delegate = self;
    _documentController.UTI = @"sh.whisper.whisperimage";
    _documentController.annotation = @{@"CallbackURL": urlScheme};
    
    if (_item) {
        if (_optionsMenu) {
            result = [_documentController presentOptionsMenuFromBarButtonItem:_item animated:_animated];
        }
        else {
            result = [_documentController presentOpenInMenuFromBarButtonItem:_item animated:_animated];
        }
    }
    else if (_view) {
        if (_optionsMenu) {
            result = [_documentController presentOptionsMenuFromRect:_rect inView:_view animated:_animated];
        }
        else {
            result = [_documentController presentOpenInMenuFromRect:_rect inView:_view animated:_animated];
        }
    }
    else {
        *error = [NSError whp_ErrorNotConfigured];
        return NO;
    }
    if (!result) {
        [self promptForUpdate];
        return NO;
    }
    return YES;
}

#pragma mark - Accessors

-(void)setDocumentController:(UIDocumentInteractionController *)docController
{
    if (_documentController) {
        [_documentController dismissMenuAnimated:_autotakeToAppStore];
    }
    _documentController = docController;
}

#pragma mark - Dealloc

-(void)dealloc {
}

@end
