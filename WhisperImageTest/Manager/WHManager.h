//
//  WHManager.h
//  WhisperImageTest
//
//  Created by whisper on 6/23/14.
//  Copyright (c) 2014 Whisper. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString* const WHManagerErrorDomain = @"sh.whisper.WHManager";

/**
  The `WHManager` class allows you to prompt the user to create a
  Whisper using a given image.
 
  You can call the prompt in one of two ways. The
  first is to set the relevant properties of the `WHManager` before
  calling one of the property-dependent create methods:

    NSImage* image = ...
    UIView* view = ...
 
    WHManager* manager = [WHManager sharedManager];
    manager.mode = WHManagerModeMenuFromView
    manager.view = view;
    manager.rect = view.bounds;

    NSError* error;
    [manager createWhisperWithImage:image error:&error];

  Alternatively, you can call one of the shorthand methods, that
  encapsulates the `mode` and relevant properties in its method name
  and parameters:

    NSImage* image = ...
    UIView* view = ...
 
    NSError* error;
    [[WHManager sharedManager] createWhisperWithImage:image
                                     withMenuFromRect:view.bounds
                                               inView:view
                                             animated:YES
                                                error:error];
 
  The create prompt can be presented in four different modes,
  as defined in the `mode` property. This controls whether the open
  menu is presented from a `UIView` or a `UIBarButtonItem`, and
  the style of the underlying `UIDocumentInteractionController`.

  The WHManager supports opening images from one of the `UIImage`,
  `NSData`, `NSURL`, or `NSString` classes. Note that the data
  associated with each of the types must be an image in a JPEG format,
  with a size of at least 640 pixels wide by 920 pixels high. 
  Failure to comply to these requirements will result in an `NSError`
  and a return value of `NO`.
 */
@interface WHManager : NSObject

typedef NS_ENUM(NSInteger, WHManagerErrorCode){
    WHManagerErrorCodeItemIsNil,
    WHManagerErrorCodeRectIsNil,
    WHManagerErrorCodeViewIsNil,
    WHManagerErrorCodeCouldNotInitializeImageFromData,
    WHManagerErrorCodeImageIsTooSmall
};

///@name Class Methods

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

typedef NS_ENUM(NSInteger, WHManagerButtonSize) {
    WHManagerButtonSizeSmall,
    WHManagerButtonSizeMedium,
    WHManagerButtonSizeLarge
};

/**
 *  Returns a custom Whisper button that you can
 *  use for your prompt.
 *
 *  @param size    Size, as denoted by the `WHManagerButtonSize` enum.
 *  @param rounded A boolean denoting whether the button is rounded on the corners
 *
 *  @return A custom Whisper button.
 */
+(UIButton*)whisperButtonWithSize:(WHManagerButtonSize)size
                          rounded:(BOOL)rounded;

/**
 *  Get the default small size for a Whisper button.
 *
 *  @return The default small size for a Whisper button.
 */
+(CGSize)whisperButtonSmallSize;

/**
 *  Get the default medium size for a Whisper button.
 *
 *  @return The default medium size for a Whisper button.
 */
+(CGSize)whisperButtonMediumSize;

/**
 *  Get the default large size for a Whisper button.
 *
 *  @return The default small size for a Whisper button.
 */
+(CGSize)whisperButtonLargeSize;

///@name Properties

/**
 * Specifies whether the user is automatically directed 
 * to the Whisper App Store page. If set to `NO`, a dialog
 * is shown to confirm the redirect.
 */
@property BOOL autotakeToAppStore;

/**
 * Specifies whether menus are animated.
 */
@property BOOL animated;

/**
 *  Denotes the current `mode` that the `WHManager` is set in. This
 *  controls whether the open menu is presented in a `UIView`, or from
 *  a `UIBarButtonItem`, and the style of the underlying
 *  `UIDocumentInteractionController`.
 */
typedef NS_ENUM(NSInteger, WHManagerMode) {
    /**
     *  A standard menu is presented from a `UIBarButtonItem`.
     *  Note that you must set the `item` property before calling any
     *  one of the property-dependent create methods.
     */
    WHManagerModeMenuFromBarButtonItem,
    /**
     *  A standard menu is presented from a `UIView`.
     *  Note that you must set the `view` and `rect` properties before
     *  calling any one of the property-dependent create methods.
     */
    WHManagerModeMenuFromView,
    /**
     *  An options menu is presented from a `UIBarButtonItem`.
     *  Note that you must set the `item` property before calling any
     *  one of the property-dependent create methods.
     */
    WHManagerModeOptionsMenuFromBarButtonItem,
    /**
     *  An options menu is presented from a `UIView`.
     *  Note that you must set the `view` and `rect` properties before
     *  calling any one of the property-dependent create methods.
     */
    WHManagerModeOptionsMenuFromView
};

/**
 *  The `mode` that the `WHManager` is currently set in.
 *  This specifies whether the open prompt is shown from a Menu
 *  or an OptionsMenu, and whether the prompt is shown from inside
 *  a `UIView` or a `UIBarButtonItem`.
 *
 *  Note that when setting the `mode` that `WHManager` runs in, you 
 *  must also set the `item`, `view`, and/or `rect` properties, depending on what
 *  `mode` you have set to.
 */
@property WHManagerMode mode;

/**
 *  The `UIBarButtonItem` that the prompt menu will open from.
 *  Note that the `mode` property must also be set to the 
 *  corresponding `WHManagerMode` value.
 */
@property (nonatomic, weak) UIBarButtonItem* item;

/**
 *  The `UIView` that the prompt menu will open in.
 *  Note that the `mode` property must also be set to the 
 *  corresponding `WHManagerMode` value.
 */
@property (nonatomic, weak) UIView* view;

/**
 *  The location (in the coordinate system of view) at which
 *  to anchor the prompt menu.
 *  Note that the `mode` property must also be set to the
 *  corresponding `WHManagerMode` value.
 */
@property CGRect rect;

/// @name Property-dependent methods

/**
 *  Attempts to open Whisper with the given image data.
 *  
 *  @warning When calling this default method, all relevant properties
 *  must be set beforehand.
 *
 *  @param data The image data to be used.
 *  @param error If there is an error creating the Whisper, upon
 *  return contains an `NSError` object that describes the problem.
 *
 *  @return returns `YES` if the operation succeeded without errors.
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
 *  return contains an `NSError` object that describes the problem.
 *
 *  @return returns `YES` if the operation succeeded without errors.
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
 *  return contains an `NSError` object that describes the problem.
 *
 *  @return returns `YES` if the operation succeeded without errors.
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
 *  return contains an `NSError` object that describes the problem.
 *
 *  @return returns `YES` if the operation succeeded without errors.
 */
-(BOOL) createWhisperWithPath:(NSString*)path error:(NSError**)error;

/// @name Shorthand methods - MenuFromBarButtonItem

-(BOOL) createWhisperWithData:(NSData *)data withMenuFromBarButtonItem:(UIBarButtonItem*)item animated:(BOOL)animated error:(NSError**)error;
-(BOOL) createWhisperWithImage:(UIImage *)image withMenuFromBarButtonItem:(UIBarButtonItem*)item animated:(BOOL)animated error:(NSError**)error;
-(BOOL) createWhisperWithPath:(NSString *)path withMenuFromBarButtonItem:(UIBarButtonItem*)item animated:(BOOL)animated error:(NSError**)error;
-(BOOL) createWhisperWithURL:(NSURL *)url withMenuFromBarButtonItem:(UIBarButtonItem*)item animated:(BOOL)animated error:(NSError**)error;

/// @name Shorthand methods - MenuFromRectInView

-(BOOL) createWhisperWithData:(NSData *)data withMenuFromRect:(CGRect)rect inView:(UIView*)view animated:(BOOL)animated error:(NSError**)error;
-(BOOL) createWhisperWithImage:(UIImage *)image withMenuFromRect:(CGRect)rect inView:(UIView*)view animated:(BOOL)animated error:(NSError**)error;
-(BOOL) createWhisperWithPath:(NSString *)path withMenuFromRect: (CGRect)rect inView:(UIView*)view animated:(BOOL)animated error:(NSError**)error;
-(BOOL) createWhisperWithURL:(NSURL *)url withMenuFromRect: (CGRect)rect inView:(UIView*)view animated:(BOOL)animated error:(NSError**)error;

/// @name Shorthand methods - OptionsMenuFromBarButtonItem

-(BOOL) createWhisperWithData:(NSData *)data withOptionsMenuFromBarButtonItem:(UIBarButtonItem*)item animated:(BOOL)animated error:(NSError**)error;
-(BOOL) createWhisperWithImage:(UIImage *)image withOptionsMenuFromBarButtonItem:(UIBarButtonItem*)item animated:(BOOL)animated error:(NSError**)error;
-(BOOL) createWhisperWithPath:(NSString *)path withOptionsMenuFromBarButtonItem:(UIBarButtonItem*)item animated:(BOOL)animated error:(NSError**)error;
-(BOOL) createWhisperWithURL:(NSURL *)url withOptionsMenuFromBarButtonItem:(UIBarButtonItem*)item animated:(BOOL)animated error:(NSError**)error;

/// @name Shorthand methods - OptionsMenuFromRectInView

-(BOOL) createWhisperWithData:(NSData *)data withOptionsMenuFromRect:(CGRect)rect inView:(UIView *)view animated:(BOOL)animated error:(NSError**)error;
-(BOOL) createWhisperWithImage:(UIImage *)image withOptionsMenuFromRect:(CGRect)rect inView:(UIView *)view animated:(BOOL)animated error:(NSError**)error;
-(BOOL) createWhisperWithPath:(NSString *)path withOptionsMenuFromRect:(CGRect)rect inView:(UIView *)view animated:(BOOL)animated error:(NSError**)error;
-(BOOL) createWhisperWithURL:(NSURL *)url withOptionsMenuFromRect:(CGRect)rect inView:(UIView *)view animated:(BOOL)animated error:(NSError**)error;

@end
