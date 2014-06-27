//
//  NSError+WHPErrors.h
//  WhisperImageTest
//
//  Created by whisper on 6/27/14.
//  Copyright (c) 2014 Whisper. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString* const WHPWhisperAppClientErrorDomain = @"sh.whisper.WHPWhisperAppClient";

@interface NSError (WHPErrors)

typedef NS_ENUM(NSInteger, WHPWhisperAppClientErrorCode){
    kWHPWhisperAppClientErrorCode_ItemIsNil,
    kWHPWhisperAppClientErrorCode_RectIsNil,
    kWHPWhisperAppClientErrorCode_ViewIsNil,
    kWHPWhisperAppClientErrorCode_CouldNotInitializeImageFromData,
    kWHPWhisperAppClientErrorCode_ImageIsTooSmall,
    kWHPWhisperAppClientErrorCode_WrongImageFormat
};

+(NSError*)WHPErrorItemIsNil;
+(NSError*)WHPErrorRectIsNil;
+(NSError*)WHPErrorViewIsNil;
+(NSError*)WHPErrorCouldNotInitializeImageFromData;
+(NSError*)WHPErrorImageIsTooSmall;
+(NSError*)WHPErrorWrongImageFormat;

@end
