//
//  WHManager.h
//  WhisperImageTest
//
//  Created by whisper on 6/23/14.
//  Copyright (c) 2014 Whisper. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString* const WHManagerErrorDomain = @"sh.whisper.WHManager";

@interface WHManager : NSObject

typedef NS_ENUM(NSInteger, WHManagerErrorCode){
    WHManagerErrorCodeItemIsNil,
    WHManagerErrorCodeRectIsNil,
    WHManagerErrorCodeViewIsNil,
    WHManagerErrorCodeCouldNotInitializeImageFromData,
    WHManagerErrorCodeImageIsTooSmall
};

/**
 * Specifies whether the user is automatically directed 
 * to the Whisper App Store page. If set to NO, a dialog 
 * is shown to confirm the redirect.
 */
@property BOOL autotakeToAppStore;

/**
 * Specifies whether menus are animated.
 */
@property BOOL animated;


typedef NS_ENUM(NSInteger, WHManagerMode) {
    WHManagerModeMenuFromBarButtonItem,
    WHManagerModeMenuFromView,
    WHManagerModeOptionsMenuFromBarButtonItem,
    WHManagerModeOptionsMenuFromView
};

/**
 *  The mode that the Whisper Manager is currently set in.
 *  This specifies whether the open prompt is shown from a Menu
 *  or an OptionsMenu, and whether the prompt is shown from inside
 *  a UIView or a UIBarButtonItem.
 *
 *  Note that when setting the Mode that WHManager runs in, you must
 *  also set the barButtonItem or view properties, depending on what
 *  mode you have set to.
 */
@property WHManagerMode mode;

/**
 *  The BarButtonItem that the prompt menu will open from.
 *  Note that the mode property must also be set to the 
 *  corresponding WHManagerMode value.
 */
@property (nonatomic, weak) UIBarButtonItem* item;

/**
 *  The View that the prompt menu will open in.
 *  Note that the mode property must also be set to the 
 *  corresponding WHManagerMode value.
 */
@property (nonatomic, weak) UIView* view;

/**
 *  The location (in the coordinate system of view) at which
 *  to anchor the prompt menu.
 *  Note that the mode property must also be set to the
 *  corresponding WHManagerMode value.
 */
@property CGRect rect;

/**
 *  Returns the singleton manager.
 *
 *  @return The singleton manager.
 *  @discussion This method allocates and initializes a WHManager
 *  object if one doesn't already exist.
 */
+(WHManager*) sharedManager;

/**
 *  The minimum image size that can be passed into Whisper.
 *
 *  @return a CGSize struct containing the minimum width and height.
 */
+(CGSize) minImageSize;

/// @name Property-dependent methods

/**
 *  Attempts to open Whisper with the given image data.
 *  
 *  @warning When calling this default method, all relevant properties
 *  must be set beforehand.
 *
 *  @param data The image data to be used.
 *  @param error If there is an error creating the Whisper, upon
 *  return contains an NSError object that describes the problem.
 *
 *  @return returns YES if the operation succeeded without errors.
 */
-(BOOL) createWhisperWithData:(NSData*) data error:(NSError**)error;

/**
 *  Attempts to open Whisper with the given image.
 *
 *  @warning When calling this default method, all relevant properties
 *  must be set beforehand.
 *
 *  @param image The image to be used.
 *  @param error If there is an error creating the Whisper, upon
 *  return contains an NSError object that describes the problem.
 *
 *  @return returns YES if the operation succeeded without errors.
 */
-(BOOL) createWhisperWithImage:(UIImage*)image error:(NSError**)error;

/**
 *  Attempts to open Whisper with an image specified by the given
 *  URL.
 *
 *  @warning When calling this default method, all relevant properties
 *  must be set beforehand. The URL must point to a local file 
 *  address.
 *
 *  @param url The URL of the image to be used.
 *  @param error If there is an error creating the Whisper, upon
 *  return contains an NSError object that describes the problem.
 *
 *  @return returns YES if the operation succeeded without errors.
 */
-(BOOL) createWhisperWithURL:(NSURL*)url error:(NSError**)error;

/**
 *  Attempts to open Whisper with an image specified by the given
 *  file path.
 *
 *  @warning When calling this default method, all relevant properties
 *  must be set beforehand.
 *
 *  @param path The file path to the image to be used.
 *  @param error If there is an error creating the Whisper, upon 
 *  return contains an NSError object that describes the problem.
 *
 *  @return returns YES if the operation succeeded without errors.
 */
-(BOOL) createWhisperWithPath:(NSString*)path error:(NSError**)error;

/// @name MenuFromBarButtonItem

-(BOOL) createWhisperWithData:(NSData *)data withMenuFromBarButtonItem:(UIBarButtonItem*)item animated:(BOOL)animated error:(NSError**)error;
-(BOOL) createWhisperWithImage:(UIImage *)image withMenuFromBarButtonItem:(UIBarButtonItem*)item animated:(BOOL)animated error:(NSError**)error;
-(BOOL) createWhisperWithPath:(NSString *)path withMenuFromBarButtonItem:(UIBarButtonItem*)item animated:(BOOL)animated error:(NSError**)error;
-(BOOL) createWhisperWithURL:(NSURL *)url withMenuFromBarButtonItem:(UIBarButtonItem*)item animated:(BOOL)animated error:(NSError**)error;

/// @name MenuFromRectInView

-(BOOL) createWhisperWithData:(NSData *)data withMenuFromRect:(CGRect)rect inView:(UIView*)view animated:(BOOL)animated error:(NSError**)error;
-(BOOL) createWhisperWithImage:(UIImage *)image withMenuFromRect:(CGRect)rect inView:(UIView*)view animated:(BOOL)animated error:(NSError**)error;
-(BOOL) createWhisperWithPath:(NSString *)path withMenuFromRect: (CGRect)rect inView:(UIView*)view animated:(BOOL)animated error:(NSError**)error;
-(BOOL) createWhisperWithURL:(NSURL *)url withMenuFromRect: (CGRect)rect inView:(UIView*)view animated:(BOOL)animated error:(NSError**)error;

/// @name OptionsMenuFromBarButtonItem

-(BOOL) createWhisperWithData:(NSData *)data withOptionsMenuFromBarButtonItem:(UIBarButtonItem*)item animated:(BOOL)animated error:(NSError**)error;
-(BOOL) createWhisperWithImage:(UIImage *)image withOptionsMenuFromBarButtonItem:(UIBarButtonItem*)item animated:(BOOL)animated error:(NSError**)error;
-(BOOL) createWhisperWithPath:(NSString *)path withOptionsMenuFromBarButtonItem:(UIBarButtonItem*)item animated:(BOOL)animated error:(NSError**)error;
-(BOOL) createWhisperWithURL:(NSURL *)url withOptionsMenuFromBarButtonItem:(UIBarButtonItem*)item animated:(BOOL)animated error:(NSError**)error;

/// @name OptionsMenuFromRectInView

-(BOOL) createWhisperWithData:(NSData *)data withOptionsMenuFromRect:(CGRect)rect inView:(UIView *)view animated:(BOOL)animated error:(NSError**)error;
-(BOOL) createWhisperWithImage:(UIImage *)image withOptionsMenuFromRect:(CGRect)rect inView:(UIView *)view animated:(BOOL)animated error:(NSError**)error;
-(BOOL) createWhisperWithPath:(NSString *)path withOptionsMenuFromRect:(CGRect)rect inView:(UIView *)view animated:(BOOL)animated error:(NSError**)error;
-(BOOL) createWhisperWithURL:(NSURL *)url withOptionsMenuFromRect:(CGRect)rect inView:(UIView *)view animated:(BOOL)animated error:(NSError**)error;

@end
