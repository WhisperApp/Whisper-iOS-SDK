//
//  ViewController.m
//  Whisper-iOS-SDKTest
//
//  Created by whisper on 6/30/14.
//  Copyright (c) 2014 Whisper. All rights reserved.
//

#import "RootViewController.h"
#import "PostViewController.h"

NSString *const badImageName = @"doge";
NSString *const badImageType = @"png";
NSString *const goodImageName = @"yosemite";
NSString *const goodImageType = @"jpg";

@interface RootViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (strong, nonatomic) NSURL *fileURL;

@end

@implementation RootViewController

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

#pragma mark - IBAction

- (IBAction)legalImageButtonPressed:(id)sender
{
    [self loadImageWithName:goodImageName type:goodImageType];
    [self performSegueWithIdentifier:@"pushToPost" sender:sender];
}

- (IBAction)illegalImageButtonPressed:(id)sender
{
    [self loadImageWithName:badImageName type:badImageType];
    [self performSegueWithIdentifier:@"pushToPost" sender:sender];
}

- (IBAction)cameraRollButtonPressed:(id)sender
{
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

#pragma mark - UIImagePickerController

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    [self writeImageToCache:image];
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        [self performSegueWithIdentifier:@"pushToPost" sender:self];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    PostViewController *postViewController = segue.destinationViewController;
    postViewController.imageURL = _fileURL;
}

#pragma mark - Private

- (void)loadImageWithName:(NSString *)name type:(NSString *)type
{
    _fileURL = [[NSBundle mainBundle] URLForResource:name withExtension:type];
}

- (void)writeImageToCache:(UIImage *)image
{
    _fileURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:@"temp"] isDirectory:NO];
    NSError *error = nil;
    [UIImageJPEGRepresentation(image, 1.0) writeToFile:_fileURL.path options:NSDataWritingAtomic error:&error];
}

@end
