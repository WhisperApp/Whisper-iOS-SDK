//
//  PostViewController.m
//  Whisper-iOS-SDKTest
//
//  Created by whisper on 6/30/14.
//  Copyright (c) 2014 Whisper. All rights reserved.
//

#import "PostViewController.h"
#import <Whisper-iOS-SDK/WHPWhisperAppClient.h>

#define kSegmentedControlImage 0
#define kSegmentedControlData 1
#define kSegmentedControlPath 2
#define kSegmentedControlURL 3

@interface PostViewController () <WHPWhisperAppClientDelegate>
@property (weak, nonatomic) IBOutlet UIBarButtonItem *postButton;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@end

@implementation PostViewController

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (_imageURL) {
        NSData *imageData = [NSData dataWithContentsOfURL:_imageURL];
        UIImage *image = [UIImage imageWithData:imageData];
        _imageView.image = image;
        [_imageView sizeToFit];
    }
    
    UIButton *smallButton = [[WHPWhisperAppClient sharedClient] whisperButtonWithSize:kWHPWhisperAppClientButtonSize_Small rounded:YES];
    smallButton.center = CGPointMake(80, 450);
    [self.view addSubview:smallButton];
    
    UIButton *mediumButton = [[WHPWhisperAppClient sharedClient] whisperButtonWithSize:kWHPWhisperAppClientButtonSize_Medium rounded:YES];
    mediumButton.center = CGPointMake(160, 450);
    [self.view addSubview:mediumButton];
    
    UIButton *largeButton = [[WHPWhisperAppClient sharedClient] whisperButtonWithSize:kWHPWhisperAppClientButtonSize_Large rounded:YES];
    largeButton.center = CGPointMake(260, 450);
    [self.view addSubview:largeButton];
    
    [WHPWhisperAppClient sharedClient].delegate = self;
    [[WHPWhisperAppClient sharedClient] prepareWithView:self.view inRect:self.view.bounds];
}

#pragma mark - IBAction

- (IBAction)postButtonPressed:(id)sender
{
    NSError *error = nil;
    switch (_segmentedControl.selectedSegmentIndex) {
        case kSegmentedControlImage:
        {
            NSData *data = [NSData dataWithContentsOfURL:_imageURL];
            UIImage *image = [UIImage imageWithData:data];
            [[WHPWhisperAppClient sharedClient] prepareWithBarButtonItem:_postButton];
            [[WHPWhisperAppClient sharedClient] createWhisperWithImage:image error:&error];
            break;
        }
        case kSegmentedControlData:
        {
            NSData *data = [NSData dataWithContentsOfURL:_imageURL];
            [[WHPWhisperAppClient sharedClient] prepareWithBarButtonItem:_postButton];
            [[WHPWhisperAppClient sharedClient] createWhisperWithData:data error:&error];
            break;
        }
        case kSegmentedControlPath:
        {
            NSString *path = _imageURL.path;
            [[WHPWhisperAppClient sharedClient] prepareWithBarButtonItem:_postButton];
            [[WHPWhisperAppClient sharedClient] createWhisperWithPath:path error:&error];
            break;
        }
        case kSegmentedControlURL:
        {
            [[WHPWhisperAppClient sharedClient] prepareWithBarButtonItem:_postButton];
            [[WHPWhisperAppClient sharedClient] createWhisperWithURL:_imageURL error:&error];
            break;
        }
        default:
            break;
    }
    if (error) {
        [[[UIAlertView alloc] initWithTitle:error.userInfo[NSLocalizedDescriptionKey] message:[NSString stringWithFormat:@"%@ - %@", error.userInfo[NSLocalizedFailureReasonErrorKey], error.userInfo[NSLocalizedRecoverySuggestionErrorKey]] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil] show];
    }
}

#pragma mark - WHPWhisperAppClient

-(UIImage *)whisperAppClientSourceImageForWhisper
{
    NSData *data = [NSData dataWithContentsOfURL:_imageURL];
    return [UIImage imageWithData:data];
}

-(NSData *)whisperAppClientSourceDataForWhisper
{
    return [NSData dataWithContentsOfURL:_imageURL];
}

-(NSString *)whisperAppClientSourcePathForWhisper
{
    return _imageURL.path;
}

-(NSURL *)whisperAppClientSourceURLForWhisper
{
    return _imageURL;
}

-(void)whisperAppClientDidFailWithError:(NSError *)error
{
    [[[UIAlertView alloc] initWithTitle:error.userInfo[NSLocalizedDescriptionKey] message:[NSString stringWithFormat:@"%@ - %@", error.userInfo[NSLocalizedFailureReasonErrorKey], error.userInfo[NSLocalizedRecoverySuggestionErrorKey]] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil] show];
}

@end
