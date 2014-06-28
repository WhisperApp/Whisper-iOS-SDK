//
//  WHPWhisperAppClient.h
//  WhisperImageTest
//
//  Created by whisper on 6/23/14.
//  Copyright (c) 2014 Whisper. All rights reserved.
//

#import <Foundation/Foundation.h>

extern struct CGSize const whp_minImageSize;

extern struct CGSize const whp_imageSizeSmall;
extern struct CGSize const whp_imageSizeMedium;
extern struct CGSize const whp_imageSizeLarge;

extern CGFloat const whp_buttonCornerRadius;

extern NSString *const whp_bundleID;
extern NSString *const whp_resourceBundle;
extern NSString *const whp_appURL;

/**
 *  Defines the default sizes of a Whisper button.
 */
typedef NS_ENUM(NSInteger, WHPWhisperAppClientButtonSize) {
    /**
     *  Default small size for a Whisper button.
     */
    kWHPWhisperAppClientButtonSize_Small,
    /**
     *  Default medium size for a Whisper button.
     */
    kWHPWhisperAppClientButtonSize_Medium,
    /**
     *  Default large size for a Whisper button.
     */
    kWHPWhisperAppClientButtonSize_Large
};

/**
  The `WHPWhisperAppClient` class allows you to prompt the user to create a
  Whisper using a given image.
 
  The prompt is done in two steps. First, call either of the
  configure methods: this defines the source of the prompt.
  Next, call one of the create methods to create the Whisper
  from any one of four data sources.
 
    NSImage* image = ...
    UIView* view = ...
 
    NSError* error;
    [[WHPWhisperAppClient sharedClient] prepareWithView:view inRect:view.bounds];
    [[WHPWhisperAppClient sharedClient] createWhisperWithImage:image error:&error];
 
  The create prompt can be presented in either a Menu or an
  Options menu style, and this is controlled by the
  `optionsMenu` property.

  The `WHPWhisperAppClient` supports opening images from one of
  the `UIImage`, `NSData`, `NSURL`, or `NSString` classes. Note
  that the data associated with each of the types must be an image
  in a JPEG format, with a size of at least 640 pixels wide by 920
  pixels high. Failure to comply to these requirements will result
  in an `NSError` and a return value of `NO`.
 */
@interface WHPWhisperAppClient : NSObject

///@name Class Methods

/**
 *  Returns the singleton client.
 *
 *  @return The singleton client.
 *  @discussion This method allocates and initializes a
 *  WHPWhisperAppClient object if one doesn't already exist.
 */
+(WHPWhisperAppClient *)sharedClient;

/**
 *  Returns a custom Whisper button that you can
 *  use for your prompt.
 *
 *  @param size    Size, as denoted by the `WHPWhisperAppClientButtonSize` enum.
 *  @param rounded A boolean denoting whether the button is rounded on the corners
 *
 *  @return A custom Whisper button.
 */
+(UIButton *)whisperButtonWithSize:(WHPWhisperAppClientButtonSize)size
                          rounded:(BOOL)rounded;

/**
 *  Given a `WHPWhisperAppClientButtonSize` enum, returns the
 *  corresponding CGSize.
 *
 *  @param size The button size enum.
 *
 *  @return The corresponding CGSize.
 */
+(CGSize)whisperButtonSizeForSize:(WHPWhisperAppClientButtonSize)size;

/**
 *  Performs operations necessary when the app launches from
 *  a Whisper app callback. Call this method from your 
 *  `AppDelegate`'s `- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation`
 *  method, with the corresponding parameters.
 *
 *  @param url               The url parameter called from AppDelegate
 *  @param sourceApplication The sourceApplication parameter called form AppDelegate
 *
 *  @return Returns `YES` if Whisper was able to read the URL callback.
 */
+(BOOL)handleOpenURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication;

///@name Properties

/**
 * Specifies whether the user is automatically directed 
 * to the Whisper App Store page. If set to `NO`, a dialog
 * is shown to confirm the redirect. Defaults to `NO`.
 */
@property BOOL autotakeToAppStore;

/**
 * Specifies whether menus are animated. Defaults to `YES`.
 */
@property BOOL animated;

/**
 *  Specifies whether an options menu, rather than the default
 *  menu, is displayed. Defaults to `NO`.
 */
@property BOOL optionsMenu;

/// @name Configure methods

/**
 *  Prepare the Document Controller, with a `UIBarButtonItem` to 
 *  present the view from. Note that you must call either one of 
 *  the configure methods prior to calling the create methods.
 *
 *  @param item The `UIBarButtonItem` to show the menu from.
 */
-(void)prepareWithBarButtonItem:(UIBarButtonItem *)item;

/**
 *  Prepare the Document Controller, with a `UIView` to
 *  present the view from, and a `CGRect` to define the 
 *  constraints of the menu. Note that you must call either one of
 *  the configure methods prior to calling the create methods.
 *
 *  @param view The `UIView` to show the menu in.
 *  @param rect The `CGRect` to constrain the menu to.
 */
-(void)prepareWithView:(UIView *)view inRect:(CGRect)rect;

/// @name Create methods

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
-(BOOL) createWhisperWithData:(NSData *)data error:(NSError **)error;

/**
 *  Attempts to open Whisper with the given image.
 *
 *  @warning You must call either one of the configure methods prior 
 *  to calling this method.
 *
 *  @param image The image to be used.
 *  @param error If there is an error creating the Whisper, upon
 *  return contains an `NSError` object that describes the problem.
 *
 *  @return returns `YES` if the operation succeeded without errors.
 */
-(BOOL) createWhisperWithImage:(UIImage *)image error:(NSError **)error;

/**
 *  Attempts to open Whisper with an image specified by the given
 *  URL.
 *
 *  @warning You must call either one of the configure methods prior
 *  to calling this method. The URL must point to a local file
 *  address.
 *
 *  @param url The URL of the image to be used.
 *  @param error If there is an error creating the Whisper, upon
 *  return contains an `NSError` object that describes the problem.
 *
 *  @return returns `YES` if the operation succeeded without errors.
 */
-(BOOL) createWhisperWithURL:(NSURL *)url error:(NSError **)error;

/**
 *  Attempts to open Whisper with an image specified by the given
 *  file path.
 *
 *  @warning You must call either one of the configure methods 
 *  prior to calling this method. The file path must point to a
 *  local file address.
 *
 *  @param path The file path to the image to be used.
 *  @param error If there is an error creating the Whisper, upon 
 *  return contains an `NSError` object that describes the 
 *  problem.
 *
 *  @return returns `YES` if the operation succeeded without errors.
 */
-(BOOL) createWhisperWithPath:(NSString *)path error:(NSError **)error;

@end
