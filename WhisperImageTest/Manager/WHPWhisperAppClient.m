//
//  WHPWhisperAppClient.m
//  WhisperImageTest
//
//  Created by Yujin Ariza on 6/23/14.
//  Copyright (c) 2014 Whisper. All rights reserved.
//

#import "WHPWhisperAppClient.h"
#import "NSData+WHPImageFormat.h"
#import "NSError+WHPErrors.h"

CGSize const WHPMinimumSourceImageSize = {640.0f, 920.0f};
CGSize const WHPButtonSizeSmall = {44.0f, 44.0f};
CGSize const WHPButtonSizeMedium = {60.0f, 60.0f};
CGSize const WHPButtonSizeLarge = {80.0f, 80.0f};

CGFloat const WHPButtonCornerRadius = 10.0f;
CGFloat const WHPSourceImageQuality = 1.0f;

NSString *const WHPWhisperBundleIdentifier = @"sh.whisper.whisperapp";
NSString *const WHPResourceBundleName = @"WhisperResources";
NSString *const WHPAppStoreURL = @"itms://itunes.apple.com/us/app/whisper-share-express-meet/id506141837";
NSString *const WHPWhisperAppURL = @"whisperapp://";

NSString *const WHPTemporaryDirectoryName = @"whisperTmp";
NSString *const WHPTemporaryFileName = @"whisperTemp.whimage";
NSString *const WHPWhisperIconResourceName = @"whisper_appicon152";
NSString *const WHPWhisperIconResourceType = @"png";

NSString *const WHPWhisperImageUTI = @"sh.whisper.whimage";

NSString *const WHPRedirectMessage = @"You don't have Whisper Installed. You are about to be taken to the Whisper App Store page. Continue?";
NSString *const WHPUpdateMessage = @"Your Whisper App is not up to date. You are about to be taken to the Whisper App Store page. Continue?";
NSString *const WHPCannotOpenAppStoreMessage = @"Cannot open Whisper App Store Page.";

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

#pragma mark - Initialization

-(id)init
{
    if (self = [super init]) {
        _animated = YES;
        [self cleanUpTempDirectory];
    }
    return self;
}

#pragma mark - Public

+(UIButton *)whisperButtonWithSize:(WHPWhisperAppClientButtonSize)size rounded:(BOOL)rounded
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    NSBundle *whisperBundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:WHPResourceBundleName ofType:@"bundle"]];
    NSString *buttonPath = [whisperBundle pathForResource:WHPWhisperIconResourceName ofType:WHPWhisperIconResourceType];
    
    UIImage *buttonImage = [UIImage imageWithContentsOfFile:buttonPath];
    
    CGSize buttonSize = [WHPWhisperAppClient whisperButtonSizeForSize:size];
    button.frame = CGRectMake(0, 0, buttonSize.width, buttonSize.height);
    
    if (rounded) {
        button.layer.cornerRadius = WHPButtonCornerRadius;
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
    [[WHPWhisperAppClient sharedClient] cleanUpTempDirectory];
    
    if ([sourceApplication isEqualToString:WHPWhisperBundleIdentifier]) {

        return YES;
    }
    return NO;
}

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
    
    return [self createWhisperWithCachedURL:_fileURL error:error];
}

-(BOOL)createWhisperWithImage:(UIImage *)image error:(NSError **)error
{
    NSData *data = UIImageJPEGRepresentation(image, WHPSourceImageQuality);
    return [self createWhisperWithData:data error:error];
}

-(BOOL)createWhisperWithPath:(NSString *)path error:(NSError **)error
{
    NSURL *url = [NSURL URLWithString:path relativeToURL:[NSURL URLWithString:@"file://"]];
    return [self createWhisperWithURL:url error:error];
}

-(BOOL)createWhisperWithURL:(NSURL *)url error:(NSError **)error
{

    NSData *imageData = [NSData dataWithContentsOfURL:url options:NSDataReadingUncached error:error];
    if (!imageData)
        return NO;
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

#pragma mark - UIAlertView

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

#pragma mark - Private

-(void)cleanUpTempDirectory
{
    BOOL isDir;
    NSError *error = nil;
    NSString *dirPath = [NSTemporaryDirectory() stringByAppendingPathComponent:WHPTemporaryDirectoryName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:dirPath isDirectory:&isDir]) {
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
    if (urlScheme) {
        _documentController.annotation = @{@"CallbackURL": urlScheme};
    }
    
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

@end
