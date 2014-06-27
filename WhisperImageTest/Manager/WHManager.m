//
//  WHManager.m
//  WhisperImageTest
//
//  Created by Yujin Ariza on 6/23/14.
//  Copyright (c) 2014 Whisper. All rights reserved.
//

#import "WHManager.h"
#import "AppDelegate.h"
#import "NSData+ImageFormat.h"

NSString* const tempDirectoryName = @"whisperTmp";
NSString* const tempFileName = @"whisperTemp.wh";
NSString* const whisperIconName = @"whisper_appicon152";
NSString* const whisperIconType = @"png";
NSString* const resourceBundle = @"WhisperResources.bundle";

#define kButtonSmallWidth 50.0f
#define kButtonSmallHeight 50.0f

#define kButtonMediumWidth 60.0f
#define kButtonMediumHeight 60.0f

#define kButtonLargeWidth 75.0f
#define kButtonLargeHeight 75.0f

#define kButtonCornerRadius 10.0f

#define kImageQuality 1.0
#define kMinWidth 640.0f
#define kMinHeight 920.0f

NSString* const redirectMessage = @"You don't have Whisper Installed. You are about to be taken to the Whisper App Store page. Continue?";

@interface WHManager () <UIDocumentInteractionControllerDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) UIDocumentInteractionController* docController;
@property (nonatomic, strong) NSURL* fileURL;

@end

@implementation WHManager

-(void) setDocController:(UIDocumentInteractionController *)docController {
    if (_docController) {
        [_docController dismissMenuAnimated:self.autotakeToAppStore];
    }
    _docController = docController;
}

-(void) setItem:(UIBarButtonItem *)item {
    if (_item) {
        _view = nil;
        _rect = CGRectMake(0, 0, 0, 0);
    }
    _item = item;
}

-(void) setView:(UIView *)view {
    if (_view) {
        _item = nil;
    }
    _view = view;
}

+(CGSize) minImageSize {
    return CGSizeMake(kMinWidth, kMinHeight);
}

static WHManager* singleton = nil;
+(WHManager*) sharedManager {
    @synchronized(self) {
        if (!singleton) {
            singleton = [[WHManager alloc] init];
        }
        return singleton;
    }
}

+(UIButton*) whisperButtonWithSize:(WHManagerButtonSize)size rounded:(BOOL)rounded {
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    NSString* resourceName = [NSString stringWithFormat:@"%@/%@", resourceBundle, whisperIconName];
    NSString* buttonPath = [[NSBundle mainBundle] pathForResource:resourceName ofType:whisperIconType];
    
    UIImage* buttonImage = [UIImage imageWithContentsOfFile:buttonPath];
    
    CGSize buttonSize = [WHManager buttonSizeForEnum:size];
    button.frame = CGRectMake(0, 0, buttonSize.width, buttonSize.height);
    
    if (rounded) {
        button.layer.cornerRadius = kButtonCornerRadius;
        button.clipsToBounds = YES;
    }
    
    [button setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [button.imageView setContentMode:UIViewContentModeScaleAspectFit];
    return button;
}

+(CGSize)buttonSizeForEnum:(WHManagerButtonSize)size
{
    switch (size) {
        case WHManagerButtonSizeSmall:
            return [WHManager whisperButtonSmallSize];
            break;
        case WHManagerButtonSizeMedium:
            return [WHManager whisperButtonMediumSize];
        case WHManagerButtonSizeLarge:
            return [WHManager whisperButtonLargeSize];
        default:
            return [WHManager whisperButtonMediumSize];
    }
}

+(CGSize)whisperButtonSmallSize {
    return CGSizeMake(kButtonSmallWidth, kButtonSmallHeight);
}

+(CGSize)whisperButtonMediumSize {
    return CGSizeMake(kButtonMediumWidth, kButtonMediumHeight);
}

+(CGSize)whisperButtonLargeSize {
    return CGSizeMake(kButtonLargeWidth, kButtonLargeHeight);
}

-(id)init {
    if (self=[super init]) {
        _animated = YES;
        _item = nil;
        _view = nil;
        _rect = CGRectNull;
        _docController = nil;
        _autotakeToAppStore = NO;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
    }
    return self;
}

#pragma mark - NSNotificationCenter

-(void)applicationWillEnterForeground {
    BOOL isDir;
    NSError* error;
    NSString* dirPath = [NSTemporaryDirectory() stringByAppendingPathComponent:tempDirectoryName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:dirPath isDirectory:&isDir]) {
        [[NSFileManager defaultManager] removeItemAtPath:dirPath error:&error];
    }
    return;
}

#pragma mark Property-dependent methods

-(BOOL) createWhisperWithData:(NSData *)data error:(NSError**)error {
    
    if (!data) {
        *error = [WHManager errorCouldNotInitializeImageFromData];
        return NO;
    }
    if (![data isJPG]) {
        *error = [WHManager errorWrongImageFormat];
        return NO;
    }
    if (![self writeToCache:data error:error])
        return NO;
    
    return [self createWhisperWithCachedURL:self.fileURL error:error];
}

-(BOOL) createWhisperWithImage:(UIImage *)image error:(NSError**)error {
    NSData* data = UIImageJPEGRepresentation(image, kImageQuality);
    return [self createWhisperWithData:data error:error];
}

-(BOOL) createWhisperWithPath:(NSString *)path error:(NSError**)error {
    NSURL* url = [NSURL URLWithString:path relativeToURL:[NSURL URLWithString:@"file://"]];
    return [self createWhisperWithURL:url error:error];
}

-(BOOL) createWhisperWithURL:(NSURL *)url error:(NSError**)error {

    NSData* imageData = [NSData dataWithContentsOfURL:url options:NSDataReadingUncached error:error];
    if (!imageData)
        return NO;
    return [self createWhisperWithData:imageData error:error];
}

-(BOOL) createWhisperWithCachedURL:(NSURL*)url error:(NSError**)error {
    
    NSData* imageData = [NSData dataWithContentsOfURL:url];
    UIImage* image = [UIImage imageWithData:imageData];
    if (!image) {
        *error = [WHManager errorCouldNotInitializeImageFromData];
        return NO;
    }
    if (![self isLegalImageSize:image]) {
        *error = [WHManager errorImageIsTooSmall];
        return NO;
    }
    if ([self whisperAppExists]) {
        if (![self showFileOpenDialog:url error:error])
            return NO;
    }
    else {
        if (self.autotakeToAppStore) {
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

#pragma mark Using MenuFromBarButtonItem

-(BOOL) createWhisperWithData:(NSData *)data withMenuFromBarButtonItem:(UIBarButtonItem *)item animated:(BOOL)animated error:(NSError**)error {
    self.mode = WHManagerModeMenuFromBarButtonItem;
    self.item = item;
    self.animated = animated;
    return [self createWhisperWithData:data error:error];
}

-(BOOL) createWhisperWithImage:(UIImage *)image withMenuFromBarButtonItem:(UIBarButtonItem *)item animated:(BOOL)animated error:(NSError**)error {
    self.mode = WHManagerModeMenuFromBarButtonItem;
    self.item = item;
    self.animated = animated;
    return [self createWhisperWithImage:image error:error];
}

-(BOOL) createWhisperWithPath:(NSString *)path withMenuFromBarButtonItem:(UIBarButtonItem *)item animated:(BOOL)animated error:(NSError**)error {
    self.mode = WHManagerModeMenuFromBarButtonItem;
    self.item = item;
    self.animated = animated;
    return [self createWhisperWithPath:path error:error];
}

-(BOOL) createWhisperWithURL:(NSURL *)url withMenuFromBarButtonItem:(UIBarButtonItem *)item animated:(BOOL)animated error:(NSError**)error {
    self.mode = WHManagerModeMenuFromBarButtonItem;
    self.item = item;
    self.animated = animated;
    return [self createWhisperWithURL:url error:error];
}

#pragma mark Using MenuFromRectInView

-(BOOL) createWhisperWithData:(NSData *)data withMenuFromRect:(CGRect)rect inView:(UIView *)view animated:(BOOL)animated error:(NSError**)error {
    self.mode = WHManagerModeMenuFromView;
    self.rect = rect;
    self.view = view;
    self.animated = animated;
    return [self createWhisperWithData:data error:error];
}

-(BOOL) createWhisperWithImage:(UIImage *)image withMenuFromRect:(CGRect)rect inView:(UIView *)view animated:(BOOL)animated error:(NSError**)error {
    self.mode = WHManagerModeMenuFromView;
    self.rect = rect;
    self.view = view;
    self.animated = animated;
    return [self createWhisperWithImage:image error:error];
}

-(BOOL) createWhisperWithPath:(NSString *)path withMenuFromRect:(CGRect)rect inView:(UIView *)view animated:(BOOL)animated error:(NSError**)error {
    self.mode = WHManagerModeMenuFromView;
    self.rect = rect;
    self.view = view;
    self.animated = animated;
    return [self createWhisperWithPath:path error:error];
}

-(BOOL) createWhisperWithURL:(NSURL *)url withMenuFromRect:(CGRect)rect inView:(UIView *)view animated:(BOOL)animated error:(NSError**)error {
    self.mode = WHManagerModeMenuFromView;
    self.rect = rect;
    self.view = view;
    self.animated = animated;
    return [self createWhisperWithURL:url error:error];
}

#pragma mark Using OptionsMenuFromBarButtonItem

-(BOOL) createWhisperWithData:(NSData *)data withOptionsMenuFromBarButtonItem:(UIBarButtonItem *)item animated:(BOOL)animated error:(NSError**)error {
    self.mode = WHManagerModeOptionsMenuFromBarButtonItem;
    self.item = item;
    self.animated = animated;
    return [self createWhisperWithData:data error:error];
}

-(BOOL) createWhisperWithImage:(UIImage *)image withOptionsMenuFromBarButtonItem:(UIBarButtonItem *)item animated:(BOOL)animated error:(NSError**)error {
    self.mode = WHManagerModeOptionsMenuFromBarButtonItem;
    self.item = item;
    self.animated = animated;
    return [self createWhisperWithImage:image error:error];
}

-(BOOL) createWhisperWithPath:(NSString *)path withOptionsMenuFromBarButtonItem:(UIBarButtonItem *)item animated:(BOOL)animated error:(NSError**)error {
    self.mode = WHManagerModeOptionsMenuFromBarButtonItem;
    self.item = item;
    self.animated = animated;
    return [self createWhisperWithPath:path error:error];
}

-(BOOL) createWhisperWithURL:(NSURL *)url withOptionsMenuFromBarButtonItem:(UIBarButtonItem *)item animated:(BOOL)animated error:(NSError**)error {
    self.mode = WHManagerModeOptionsMenuFromBarButtonItem;
    self.item = item;
    self.animated = animated;
    return [self createWhisperWithURL:url error:error];
}

#pragma mark Using OptionsMenuFromRectInView

-(BOOL) createWhisperWithData:(NSData *)data withOptionsMenuFromRect:(CGRect)rect inView:(UIView *)view animated:(BOOL)animated error:(NSError**)error {
    self.mode = WHManagerModeOptionsMenuFromView;
    self.rect = rect;
    self.view = view;
    self.animated = animated;
    return [self createWhisperWithData:data error:error];
}

-(BOOL) createWhisperWithImage:(UIImage *)image withOptionsMenuFromRect:(CGRect)rect inView:(UIView *)view animated:(BOOL)animated error:(NSError**)error {
    self.mode = WHManagerModeOptionsMenuFromView;
    self.rect = rect;
    self.view = view;
    self.animated = animated;
    return [self createWhisperWithImage:image error:error];
}

-(BOOL) createWhisperWithPath:(NSString *)path withOptionsMenuFromRect:(CGRect)rect inView:(UIView *)view animated:(BOOL)animated error:(NSError**)error {
    self.mode = WHManagerModeOptionsMenuFromView;
    self.rect = rect;
    self.view = view;
    self.animated = animated;
    return [self createWhisperWithPath:path error:error];
}

-(BOOL) createWhisperWithURL:(NSURL *)url withOptionsMenuFromRect:(CGRect)rect inView:(UIView *)view animated:(BOOL)animated error:(NSError**)error {
    self.mode = WHManagerModeOptionsMenuFromView;
    self.rect = rect;
    self.view = view;
    self.animated = animated;
    return [self createWhisperWithURL:url error:error];
}

#pragma mark UIAlertView

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        // cancelled
    }
    else {
        // ok!
        [self redirectToAppStore];
    }
}

#pragma mark misc

-(BOOL) writeToCache:(NSData *)data error:(NSError**)error{
    
    NSURL* directoryURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:tempDirectoryName] isDirectory:YES];
    [[NSFileManager defaultManager] createDirectoryAtURL:directoryURL withIntermediateDirectories:YES attributes:nil error:error];
    NSString *fileName = [NSString stringWithFormat:@"%@_%@", [[NSProcessInfo processInfo] globallyUniqueString], tempFileName];
    self.fileURL = [directoryURL URLByAppendingPathComponent:fileName];
    
    return [data writeToFile:self.fileURL.path options:NSDataWritingAtomic error:error];
}

-(BOOL) whisperAppExists {
    return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"whisperapp://"]];
}

-(void) redirectToAppStore {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://itunes.apple.com/us/app/whisper-share-express-meet/id506141837?mt=8"]];
}

-(void) promptForRedirect {
    WHManager* delegate = self;
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Redirect Alert" message:redirectMessage delegate:delegate cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK!", nil];
    alert.alertViewStyle = UIAlertViewStyleDefault;
    [alert show];
}

-(BOOL) isLegalImageSize:(UIImage*) image {
    CGSize size = image.size;
    return size.width >= kMinWidth && size.height >= kMinHeight;
}

-(NSString*)getApplicationURLScheme {
    NSArray* urlTypes = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleURLTypes"];
    if (urlTypes.count == 0)
        return nil;
    NSArray* urlSchemes = [[urlTypes objectAtIndex:0] objectForKey:@"CFBundleURLSchemes"];
    if (urlSchemes.count == 0)
        return nil;
    return [urlSchemes objectAtIndex:0];
}

-(BOOL) showFileOpenDialog:(NSURL*) url error:(NSError**)error {
    
    NSString* urlScheme = [self getApplicationURLScheme];
    
    self.docController = [UIDocumentInteractionController interactionControllerWithURL:url];
    _docController.delegate = self;
    _docController.UTI = @"sh.whisper.whisperimage";
    _docController.annotation = @{@"CallbackURL": urlScheme};
    
    if (self.mode == WHManagerModeMenuFromBarButtonItem) {
        if (!self.item) {
            *error = [WHManager errorItemIsNil];
            _docController = nil;
            return NO;
        }
        [self.docController presentOpenInMenuFromBarButtonItem:self.item animated:self.animated];
    }
    else if (self.mode == WHManagerModeMenuFromView) {
        if (!self.view) {
            *error = [WHManager errorViewIsNil];
            _docController = nil;
            return NO;
        }
        if (CGRectIsNull(self.rect)) {
            *error = [WHManager errorRectIsNil];
            _docController = nil;
            return NO;
        }
        [self.docController presentOpenInMenuFromRect:self.rect inView:self.view animated:self.animated];
    }
    else if (self.mode == WHManagerModeOptionsMenuFromBarButtonItem) {
        if (!self.item) {
            *error = [WHManager errorItemIsNil];
            _docController = nil;
            return NO;
        }
        [self.docController presentOptionsMenuFromBarButtonItem:self.item animated:self.animated];
    }
    else if (self.mode == WHManagerModeOptionsMenuFromView) {
        if (!self.view) {
            *error = [WHManager errorViewIsNil];
            _docController = nil;
            return NO;
        }
        if (CGRectIsNull(self.rect)) {
            *error = [WHManager errorRectIsNil];
            _docController = nil;
            return NO;
        }
        [self.docController presentOptionsMenuFromRect:self.rect inView:self.view animated:self.animated];
    }
    return YES;
}

#pragma mark Errors

+(NSError*) errorItemIsNil {
    NSDictionary* userInfo = @{
                               NSLocalizedDescriptionKey: NSLocalizedString(@"DocumentInteractionController prompt was unsuccessful.", nil),
                               NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Property 'item' is nil.", nil),
                               NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Set property 'item'", nil)
                                };
    NSError* error = [NSError errorWithDomain:WHManagerErrorDomain code: WHManagerErrorCodeItemIsNil userInfo:userInfo];
    return error;
}

+(NSError*) errorRectIsNil {
    NSDictionary* userInfo = @{
                               NSLocalizedDescriptionKey: NSLocalizedString(@"DocumentInteractionController prompt was unsuccessful.", nil),
                               NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Property 'rect' is nil.", nil),
                               NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Set property 'rect'", nil)
                               };
    NSError* error = [NSError errorWithDomain:WHManagerErrorDomain code: WHManagerErrorCodeRectIsNil userInfo:userInfo];
    return error;
}

+(NSError*) errorViewIsNil {
    NSDictionary* userInfo = @{
                               NSLocalizedDescriptionKey: NSLocalizedString(@"DocumentInteractionController prompt was unsuccessful.", nil),
                               NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Property 'view' is nil.", nil),
                               NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Set property 'view'", nil)
                               };
    NSError* error = [NSError errorWithDomain:WHManagerErrorDomain code: WHManagerErrorCodeViewIsNil userInfo:userInfo];
    return error;
}

+(NSError*) errorCouldNotInitializeImageFromData {
    NSDictionary* userInfo = @{
                               NSLocalizedDescriptionKey: NSLocalizedString(@"UIImage creation was unsuccessful", nil),
                               NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Could not initialize the image from the specified data", nil),
                               NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Check image data for corruption", nil)
                               };
    NSError* error = [NSError errorWithDomain:WHManagerErrorDomain code:WHManagerErrorCodeCouldNotInitializeImageFromData userInfo:userInfo];
    return error;
}

+(NSError*) errorImageIsTooSmall {
    NSDictionary* userInfo = @{
                               NSLocalizedDescriptionKey: NSLocalizedString(@"Whisper creation unsuccessful", nil),
                               NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Image is too small", nil),
                               NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Resize image to be at least minImageSize", nil)
                               };
    NSError* error = [NSError errorWithDomain:WHManagerErrorDomain code:WHManagerErrorCodeImageIsTooSmall userInfo:userInfo];
    return error;
}

+(NSError*) errorWrongImageFormat {
    NSDictionary* userInfo = @{
                               NSLocalizedDescriptionKey: NSLocalizedString(@"Whisper creation unsuccessful", nil),
                               NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Data is not in JPEG image format", nil),
                               NSLocalizedRecoverySuggestionErrorKey:
                                   NSLocalizedString(@"Use the JPEG image format", nil)
                               };
    NSError* error = [NSError errorWithDomain:WHManagerErrorDomain code: WHManagerErrorCodeWrongImageFormat userInfo:userInfo];
    return error;
}


-(void) dealloc {
    NSLog(@"dealloc!");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
