//
//  NSData+ImageFormat.h
//  Whisper-iOS-SDK
//
//  Created by whisper on 6/27/14.
//  Copyright (c) 2014 Whisper. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  A Category class for NSData that allows for detecting
 *  image formats. This is done by reading the header bytes
 *  of the data.
 */
@interface NSData (WHPImageFormat)

/**
 *  Detects if the data is in a JPEG image format.
 *
 *  @return returns `YES` if the data is in a JPEG image format.
 */
-(BOOL)whp_isJPG;

/**
 *  Detects if the data is in a PNG image format.
 *
 *  @return returns `YES` if the data is in a PNG image format.
 */
-(BOOL)whp_isPNG;

@end
