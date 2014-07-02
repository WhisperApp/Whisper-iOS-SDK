//
//  WHPWhisperAppClient.h
//  Whisper-iOS-SDK
//
//  Created by whisper on 6/23/14.
//  Copyright (c) 2014 Whisper. All rights reserved.
//

#import <Foundation/Foundation.h>

//uncomment this line to enable debug logging
//#define WHISPER_DEBUG

extern struct CGSize const WHPMinimumSourceImageSize;

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
 *  Defines the order that the `WHPWhisperAppClient` delegate
 *  looks for an image source.
 */
typedef NS_ENUM(NSInteger, WHPImageSourceType) {
    /**
     *  Image source from an `UIImage`.
     */
    kWHPImageSourceType_Image,
    /**
     *  Image source from `NSData`.
     */
    kWHPImageSourceType_Data,
    /**
     *  Image source from a `NSString` file path.
     */
    kWHPImageSourceType_Path,
    /**
     *  Image source from a `NSURL` file URL.
     */
    kWHPImageSourceType_URL,
    /**
     *  The number of elements in this enumeration.
     */
    WHPImageSourceTypeCount
};

/**
 *  Defines the order that the `WHPWhisperAppClient` delegate
 *  looks for a source for its menu presentation.
 */
typedef NS_ENUM(NSInteger, WHPMenuPresentationType) {
    /**
     *  Menu Presentation from a `UIView`. The view's frame is 
     *  used for the bounds of the menu.
     */
    kWHPMenuPresentationType_View,
    /**
     *  Menu Presentation from a `UIBarButtonItem`.
     */
    kWHPMenuPresentationType_BarButtonItem,
    /**
     *  The number of elements in this enumeration.
     */
    WHPMenuPresentationTypeCount
};

/**
 *  Protocol Reference for the `WHPWhisperAppClient` delegate
 *  property. One of the four methods for image source must
 *  be defined.If more than one method is provided, the image
 *  source is chosen in the order specified by the 
 *  `WHPImageSourceType` enumerator.
 *
 *  Additionally, either one of the methods for Menu Presentation
 *  must be defined. If more than one method is provided, the menu
 *  source is chosen in the order specified by the `WHPMenuPresentationType`
 *  enumerator.
 */
@protocol WHPWhisperAppClientDelegate <NSObject>

@optional
/**
 *  Returns a `UIView` object for the `WHPWhisperAppClient` to present
 *  its menu from. The view's frame is used for the bounds of the menu.
 *  
 *  At least one of the `whisperAppClientViewForMenuPresentation` or the
 *  `whisperAppClientBarButtonItemForMenuPresentation` methods must be
 *  provided. If more than one method is provided, the menu
 *  source is chosen in the order specified by the `WHPMenuPresentationType`
 *  enumerator.
 *
 *  @return `UIView` object for the `WHPWhisperAppClient` to present
 *  its menu from.
 */
-(UIView *)whisperAppClientViewForMenuPresentation;

/**
 *  Returns a `UIBarButtonItem` object for the `WHPWhisperAppClient` to 
 *  present its menu from.
 *
 *  At least one of the `whisperAppClientViewForMenuPresentation` or the
 *  `whisperAppClientBarButtonItemForMenuPresentation` methods must be
 *  provided. If more than one method is provided, the menu
 *  source is chosen in the order specified by the `WHPMenuPresentationType`
 *  enumerator.
 *
 *  @return `UIBarButtonItem` object for the `WHPWhisperAppClient` to present
 *  its menu from.
 */
-(UIBarButtonItem *)whisperAppClientBarButtonItemForMenuPresentation;

/**
 *  Returns an `UIImage` object for the `WHPWhisperAppClient` to use as its
 *  image source.
 *
 *  At least one of the `whisperAppClientSourceImageForWhisper`, 
 *  `whisperAppClientSourceDataForWhisper`,
 *  `whisperAppClientSourcePathForWhisper`, or
 *  `whisperAppClientSourceURLForWhisper` methods must be provided. If more
 *  than one method is provided, the image source is chosen in the order
 *  specified by the `WHPImageSourceType` enumerator.
 *
 *  @return `UIImage` object for the `WHPWhisperAppClient` to use as its
 *  image source.
 */
-(UIImage *)whisperAppClientSourceImageForWhisper;

/**
 *  Returns a `NSData` object for the `WHPWhisperAppClient` to use as its
 *  image source.
 *
 *  At least one of the `whisperAppClientSourceImageForWhisper`,
 *  `whisperAppClientSourceDataForWhisper`,
 *  `whisperAppClientSourcePathForWhisper`, or
 *  `whisperAppClientSourceURLForWhisper` methods must be provided. If more
 *  than one method is provided, the image source is chosen in the order
 *  specified by the `WHPImageSourceType` enumerator.
 *
 *  @return `NSData` object for the `WHPWhisperAppClient` to use as its
 *  image source.
 */
-(NSData *)whisperAppClientSourceDataForWhisper;

/**
 *  Returns a `NSString` file path for the `WHPWhisperAppClient` to use 
 *  as its image source.
 *
 *  At least one of the `whisperAppClientSourceImageForWhisper`,
 *  `whisperAppClientSourceDataForWhisper`,
 *  `whisperAppClientSourcePathForWhisper`, or
 *  `whisperAppClientSourceURLForWhisper` methods must be provided. If more
 *  than one method is provided, the image source is chosen in the order
 *  specified by the `WHPImageSourceType` enumerator.
 *
 *  @return `NSString` file path for the `WHPWhisperAppClient` to use as its
 *  image source.
 */
-(NSString *)whisperAppClientSourcePathForWhisper;

/**
 *  Returns a `NSURL` file path for the `WHPWhisperAppClient` to use
 *  as its image source.
 *
 *  At least one of the `whisperAppClientSourceImageForWhisper`,
 *  `whisperAppClientSourceDataForWhisper`,
 *  `whisperAppClientSourcePathForWhisper`, or
 *  `whisperAppClientSourceURLForWhisper` methods must be provided. If more
 *  than one method is provided, the image source is chosen in the order
 *  specified by the `WHPImageSourceType` enumerator.
 *
 *  @return `NSURL` file path for the `WHPWhisperAppClient` to use as its
 *  image source.
 */
-(NSURL *)whisperAppClientSourceURLForWhisper;

/**
 *  Called when `WHPAppClient` encounters an error with the specified
 *  configuration.
 *
 *  @param error The `NSError` to be handled.
 */
-(void)whisperAppClientDidFailWithError:(NSError *)error;

@end

/**
  The `WHPWhisperAppClient` class allows you to prompt the user to create a
  Whisper using a given image.
 
  The prompt is done in two steps. First, call either of the
  configure methods: this defines the source of the prompt.
  Next, call one of the create methods to create the Whisper
  from any one of four data sources.
 
    UIImage* image = ...
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
 
  Alternatively, you can use the provided Whisper buttons
  instead of calling one of the create methods. In this case,
  you must provide a delegate property that implements at 
  least one of the methods for determining the image source, and
  one of the two methods for determining the menu source.
 */
@interface WHPWhisperAppClient : NSObject

///@name Properties

/**
 * Specifies whether the user is automatically directed
 * to the Whisper App Store page. If set to `NO`, a dialog
 * is shown to confirm the redirect. Defaults to `NO`.
 */
@property BOOL autotakeToAppStore;

/**
 * Specifies whether menu presentations and dismissals are 
 * animated. Defaults to `YES`.
 */
@property BOOL animated;

/**
 *  Specifies whether an options menu, rather than the default
 *  menu, is displayed. Defaults to `NO`.
 */
@property BOOL optionsMenu;

/**
 *  Specifies a custom Callback URL if your 
 *  application has a preferred URL that Whisper
 *  can call back from. If unspecified, Whisper
 *  will call the first available CFBundleURLSchemes in your
 *  app's Info.plist, or ignore if you do not have
 *  URLs set up.
 */
@property NSString *customCallbackURL;

/**
 *  Specifies a delegate handler that is used to specify
 *  image source when a Whisper Button is pressed. The 
 *  delegate must implement one of the four methods designated
 *  for retrieving image source. If more than one method
 *  is provided, the image source is chosen in the order
 *  specified by the `WHPImageSourceType` enumerator.
 */
@property id<WHPWhisperAppClientDelegate> delegate;

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

/// @name Whisper Buttons

/**
 *  Returns a custom Whisper button that you can
 *  use for your prompt, with a custom size.
 *
 *  @param size    A `CGSize` size.
 *  @param rounded A boolean denoting whether the button is rounded on the corners
 *
 *  @return A custom Whisper button.
 */
-(UIButton *)whisperButtonWithCustomSize:(CGSize)size rounded:(BOOL)rounded;

/**
 *  Returns a custom Whisper button that you can
 *  use for your prompt.
 *
 *  @param size    Size, as denoted by the `WHPWhisperAppClientButtonSize` enum.
 *  @param rounded A boolean denoting whether the button is rounded on the corners
 *
 *  @return A custom Whisper button.
 */
-(UIButton *)whisperButtonWithSize:(WHPWhisperAppClientButtonSize)size rounded:(BOOL)rounded;

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
-(BOOL)createWhisperWithData:(NSData *)data error:(NSError **)error;

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
-(BOOL)createWhisperWithImage:(UIImage *)image error:(NSError **)error;

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
-(BOOL)createWhisperWithURL:(NSURL *)url error:(NSError **)error;

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
-(BOOL)createWhisperWithPath:(NSString *)path error:(NSError **)error;

@end
