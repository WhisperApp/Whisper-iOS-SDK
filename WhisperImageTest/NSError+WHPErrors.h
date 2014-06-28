//
//  NSError+WHPErrors.h
//  WhisperImageTest
//
//  Created by whisper on 6/27/14.
//  Copyright (c) 2014 Whisper. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString* const WHPWhisperAppClientErrorDomain = @"sh.whisper.WHPWhisperAppClient";

/**
 *  Defines error codes within the 
 *  `WHPWhisperAppClientErrorDomain`.
 */
typedef NS_ENUM(NSInteger, WHPWhisperAppClientErrorCode){
    /**
     *  The client has not been configured.
     */
    kWHPWhisperAppClientErrorCode_NotConfigured,
    /**
     *  An image cannot be initialized from the given data.
     */
    kWHPWhisperAppClientErrorCode_CouldNotInitializeImageFromData,
    /**
     *  The image does not meet the minimum size restrictions.
     */
    kWHPWhisperAppClientErrorCode_ImageIsTooSmall,
    /**
     *  The image is not in the proper JPEG image format.
     */
    kWHPWhisperAppClientErrorCode_WrongImageFormat
};

/**
 *  This class category defines a few class methods for creating
 *  NSErrors in the `WHPWhisperAppClientErrorDomain`, complete
 *  with an error description and recovery suggestions.
 */
@interface NSError (WHPErrors)

/**
 *  Error when the client has not been configured.
 *
 *  @return An `NSError` object with the specified information.
 */
+(NSError *)whp_ErrorNotConfigured;

/**
 *  Error when the image could not be initialized from the given
 *  data.
 *
 *  @return An `NSError` object with the specified information.
 */
+(NSError *)whp_ErrorCouldNotInitializeImageFromData;

/**
 *  Error when the image does not meet the minimum size 
 *  requirements.
 *
 *  @return An `NSError` object with the specified information.
 */
+(NSError *)whp_ErrorImageIsTooSmall;

/**
 *  Error when the image is not in the proper JPEG image format.
 *
 *  @return An `NSError` object with the specified information.
 */
+(NSError *)whp_ErrorWrongImageFormat;

@end
