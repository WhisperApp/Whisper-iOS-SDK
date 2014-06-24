//
//  WHManager.m
//  WhisperImageTest
//
//  Created by Yujin Ariza on 6/23/14.
//  Copyright (c) 2014 Whisper. All rights reserved.
//

#import "WHManager.h"
#import "AppDelegate.h"

NSString* const dataFile = @"whisperTemp.img";

#define kImageQuality 1.0
#define kMinWidth 640.0f
#define kMinHeight 920.0f

NSString* const redirectMessage = @"You don't have Whisper Installed. You are about to be taken to the Whisper App Store page. Continue?";

@interface WHManager () <UIDocumentInteractionControllerDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) NSData* data;
@property (nonatomic, strong) UIView* view;
@property (nonatomic, strong) UIDocumentInteractionController* docController;
@property (nonatomic, strong) NSURL* fileURL;

@end

@implementation WHManager

+(CGSize) minImageSize {
    return CGSizeMake(kMinWidth, kMinHeight);
}

-(id) initWithView:(UIView*) view {
    if (self = [super init]) {
        self.view = view;
        self.autotakeToAppStore = NO;
    }
    return self;
}

-(BOOL) createWhisperWithData:(NSData *)data {
    
    if (!data)
        return NO;
    if (![self writeToCache:data])
        return NO;
    
    return [self createWhisperWithURL:self.fileURL];
}

-(BOOL) createWhisperWithImage:(UIImage *)image {
    NSData* data = UIImageJPEGRepresentation(image, kImageQuality);
    return [self createWhisperWithData:data];
}

-(BOOL) writeToCache:(NSData *)data {
    
    //create cache path
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString* cachePath = [paths objectAtIndex:0];
    BOOL isDir = NO;
    NSError* error;
    if (![[NSFileManager defaultManager] fileExistsAtPath:cachePath isDirectory:&isDir] && isDir == NO) {
        [[NSFileManager defaultManager] createDirectoryAtURL:[NSURL URLWithString:cachePath] withIntermediateDirectories:NO attributes:nil error:&error];
    }
    if (error) {
        return NO;
    }
    NSString* cacheFile = [cachePath stringByAppendingPathComponent:dataFile];
    
    self.fileURL = [NSURL URLWithString:cacheFile relativeToURL:[NSURL URLWithString:@"file://"]];
    
    return [data writeToFile:cacheFile atomically:YES];
}

-(BOOL) createWhisperWithPath:(NSString *)path {
//    NSURL* url = [[NSBundle mainBundle] URLForResource:path withExtension:nil];
    UIImage* image = [UIImage imageWithContentsOfFile:path];
    if (!image) {
        NSLog(@"failed to load image");
        return NO;
    }
    return [self createWhisperWithImage:image];
}

-(BOOL) createWhisperWithURL:(NSURL *)url {
    //assumes all URL's are local - if you do a network call this WILL hang
    NSData* imageData = [NSData dataWithContentsOfURL:url];
    UIImage* image = [UIImage imageWithData:imageData];
    if (!image) {
        return NO;
    }
    if (![self isLegalImageSize:image]) {
        CGSize imageSize = image.size;
        NSLog(@"WHManager: image too small (%f, %f) - must be at least (%f, %f)", imageSize.width, imageSize.height, kMinWidth, kMinHeight);
        return NO;
    }
    if ([self whisperAppExists]) {
        [self showFileOpenDialog:url];
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

-(BOOL) whisperAppExists {
    return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"whisperapp://"]];
}

-(void) redirectToAppStore {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://itunes.apple.com/us/app/whisper-share-express-meet/id506141837"]];
}

-(void) promptForRedirect {
    WHManager* delegate = self;
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Redirect Alert" message:redirectMessage delegate:delegate cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK!", nil];
    alert.alertViewStyle = UIAlertViewStyleDefault;
    [alert show];
}

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        // cancelled
    }
    else {
        // ok!
        [self redirectToAppStore];
    }
}

-(BOOL) isLegalImageSize:(UIImage*) image {
    CGSize size = image.size;
    return size.width >= kMinWidth && size.height >= kMinHeight;
}

-(void) showFileOpenDialog:(NSURL*) url {
    
    self.docController = [UIDocumentInteractionController interactionControllerWithURL:url];
    self.docController.delegate = self;
    
    [self.docController presentOpenInMenuFromRect:self.view.bounds inView:self.view animated:YES];
}

-(void) dealloc {
    NSLog(@"dealloc!");
    if (self.fileURL) {
        //remove cached file (not really necessary but still)
        NSError* error;
//        [[NSFileManager defaultManager] removeItemAtPath:self.cacheFile error:&error];
        [[NSFileManager defaultManager] removeItemAtURL:self.fileURL error:&error];
    }
}

@end
