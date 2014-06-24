//
//  ViewController.m
//  WhisperImageTest
//
//  Created by whisper on 6/23/14.
//  Copyright (c) 2014 Whisper. All rights reserved.
//

#import "ViewController.h"
#import "WHManager.h"

@interface ViewController () <UIDocumentInteractionControllerDelegate>
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) NSURL* url;
@property (strong, nonatomic) WHManager* manager;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.url = [[NSBundle mainBundle] URLForResource:@"beyonce" withExtension:@"jpg"];
    NSAssert(self.url, @"no url!");
    
    UIImage* image = [UIImage imageNamed:@"beyonce.jpg"];
    NSAssert(image, @"image is nil");
    self.imageView.clipsToBounds = YES;
    self.imageView.image = image;
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.imageView sizeToFit];
    
    self.manager = [[WHManager alloc] initWithView:self.imageView];
}

- (IBAction)openButton:(id)sender {
    BOOL result;
    result = [self.manager createWhisperWithURL:self.url];
//    result = [self.manager createWhisperWithImage:self.imageView.image];
//    result = [self.manager createWhisperWithData:UIImageJPEGRepresentation(self.image, 1.0)];

//    NSString* path = [[NSBundle mainBundle] pathForResource:@"beyonce" ofType:@"jpg"];
//    result = [self.manager createWhisperWithPath:path];
    
    if (!result) {
        NSLog(@"failed");
    }
}


- (UIView *)documentInteractionControllerViewForPreview:(UIDocumentInteractionController *)controller {
    return self.imageView;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
