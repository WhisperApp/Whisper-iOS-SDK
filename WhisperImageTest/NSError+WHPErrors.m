//
//  NSError+WHPErrors.m
//  WhisperImageTest
//
//  Created by whisper on 6/27/14.
//  Copyright (c) 2014 Whisper. All rights reserved.
//

#import "NSError+WHPErrors.h"

@implementation NSError (WHPErrors)

#pragma mark Errors

+(NSError*)WHPErrorItemIsNil {
    NSDictionary* userInfo = @{
                               NSLocalizedDescriptionKey: NSLocalizedString(@"DocumentInteractionController prompt was unsuccessful.", nil),
                               NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Property 'item' is nil.", nil),
                               NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Set property 'item'", nil)
                               };
    NSError* error = [NSError errorWithDomain:WHPWhisperAppClientErrorDomain code: kWHPWhisperAppClientErrorCode_ItemIsNil userInfo:userInfo];
    return error;
}

+(NSError*)WHPErrorRectIsNil {
    NSDictionary* userInfo = @{
                               NSLocalizedDescriptionKey: NSLocalizedString(@"DocumentInteractionController prompt was unsuccessful.", nil),
                               NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Property 'rect' is nil.", nil),
                               NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Set property 'rect'", nil)
                               };
    NSError* error = [NSError errorWithDomain:WHPWhisperAppClientErrorDomain code: kWHPWhisperAppClientErrorCode_RectIsNil userInfo:userInfo];
    return error;
}

+(NSError*)WHPErrorViewIsNil {
    NSDictionary* userInfo = @{
                               NSLocalizedDescriptionKey: NSLocalizedString(@"DocumentInteractionController prompt was unsuccessful.", nil),
                               NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Property 'view' is nil.", nil),
                               NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Set property 'view'", nil)
                               };
    NSError* error = [NSError errorWithDomain:WHPWhisperAppClientErrorDomain code: kWHPWhisperAppClientErrorCode_ViewIsNil userInfo:userInfo];
    return error;
}

+(NSError*)WHPErrorCouldNotInitializeImageFromData {
    NSDictionary* userInfo = @{
                               NSLocalizedDescriptionKey: NSLocalizedString(@"UIImage creation was unsuccessful", nil),
                               NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Could not initialize the image from the specified data", nil),
                               NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Check image data for corruption", nil)
                               };
    NSError* error = [NSError errorWithDomain:WHPWhisperAppClientErrorDomain code:kWHPWhisperAppClientErrorCode_CouldNotInitializeImageFromData userInfo:userInfo];
    return error;
}

+(NSError*)WHPErrorImageIsTooSmall {
    NSDictionary* userInfo = @{
                               NSLocalizedDescriptionKey: NSLocalizedString(@"Whisper creation unsuccessful", nil),
                               NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Image is too small", nil),
                               NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Resize image to be at least minImageSize", nil)
                               };
    NSError* error = [NSError errorWithDomain:WHPWhisperAppClientErrorDomain code:kWHPWhisperAppClientErrorCode_ImageIsTooSmall userInfo:userInfo];
    return error;
}

+(NSError*)WHPErrorWrongImageFormat {
    NSDictionary* userInfo = @{
                               NSLocalizedDescriptionKey: NSLocalizedString(@"Whisper creation unsuccessful", nil),
                               NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Data is not in JPEG image format", nil),
                               NSLocalizedRecoverySuggestionErrorKey:
                                   NSLocalizedString(@"Use the JPEG image format", nil)
                               };
    NSError* error = [NSError errorWithDomain:WHPWhisperAppClientErrorDomain code: kWHPWhisperAppClientErrorCode_WrongImageFormat userInfo:userInfo];
    return error;
}

@end
