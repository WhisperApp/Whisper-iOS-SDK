//
//  NSError+WHPErrors.m
//  Whisper-iOS-SDK
//
//  Created by whisper on 6/27/14.
//  Copyright (c) 2014 Whisper. All rights reserved.
//

#import "NSError+WHPErrors.h"

@implementation NSError (WHPErrors)

#pragma mark Errors

+(NSError *)whp_ErrorNotConfigured
{
    NSDictionary *userInfo = @{
                               NSLocalizedDescriptionKey: NSLocalizedString(@"DocumentInteractionController prompt was unsuccessful.", nil),
                               NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"WHPWhisperAppClient is in an unconfigured state.", nil),
                               NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Call one of the configure methods prior to creating a Whisper", nil)
                               };
    NSError *error = [NSError errorWithDomain:WHPWhisperAppClientErrorDomain code: kWHPWhisperAppClientErrorCode_NotConfigured userInfo:userInfo];
    return error;
}

+(NSError *)whp_ErrorCouldNotInitializeImageFromData
{
    NSDictionary *userInfo = @{
                               NSLocalizedDescriptionKey: NSLocalizedString(@"UIImage creation was unsuccessful", nil),
                               NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Could not initialize the image from the specified data", nil),
                               NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Check image data for corruption", nil)
                               };
    NSError *error = [NSError errorWithDomain:WHPWhisperAppClientErrorDomain code:kWHPWhisperAppClientErrorCode_CouldNotInitializeImageFromData userInfo:userInfo];
    return error;
}

+(NSError *)whp_ErrorImageIsTooSmall
{
    NSDictionary *userInfo = @{
                               NSLocalizedDescriptionKey: NSLocalizedString(@"Whisper creation unsuccessful", nil),
                               NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Image is too small", nil),
                               NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Resize image to be at least whp_minImageSize", nil)
                               };
    NSError *error = [NSError errorWithDomain:WHPWhisperAppClientErrorDomain code:kWHPWhisperAppClientErrorCode_ImageIsTooSmall userInfo:userInfo];
    return error;
}

+(NSError *)whp_ErrorWrongImageFormat
{
    NSDictionary *userInfo = @{
                               NSLocalizedDescriptionKey: NSLocalizedString(@"Whisper creation unsuccessful", nil),
                               NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Data is not in JPEG image format", nil),
                               NSLocalizedRecoverySuggestionErrorKey:
                                   NSLocalizedString(@"Use the JPEG image format", nil)
                               };
    NSError *error = [NSError errorWithDomain:WHPWhisperAppClientErrorDomain code: kWHPWhisperAppClientErrorCode_WrongImageFormat userInfo:userInfo];
    return error;
}

+(NSError *)whp_ErrorDelegateMethodNotImplemented
{
    NSDictionary *userInfo = @{
                               NSLocalizedDescriptionKey: NSLocalizedString(@"Whisper creation unsuccessful", nil),
                               NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"delegate methods not implemented", nil),
                               NSLocalizedRecoverySuggestionErrorKey:
                                   NSLocalizedString(@"Implement one or more of the WHPWhisperAppClientDelegate SourceType methods", nil)
                               };
    NSError *error = [NSError errorWithDomain:WHPWhisperAppClientErrorDomain code: kWHPWhisperAppClientErrorCode_WrongImageFormat userInfo:userInfo];
    return error;
}

@end
