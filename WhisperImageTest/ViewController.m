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
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.url = [[NSBundle mainBundle] URLForResource:@"beyonce2" withExtension:@"jpg"];
    NSAssert(self.url, @"no url!");
    
    UIImage* image = [UIImage imageWithContentsOfFile:self.url.path];
    NSAssert(image, @"image is nil");
    self.imageView.clipsToBounds = YES;
    self.imageView.image = image;
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.imageView sizeToFit];
}

- (IBAction)openButton:(id)sender {
    BOOL result;
    
    NSError* error;
    result = [[WHManager sharedManager] createWhisperWithURL:self.url withMenuFromRect:self.imageView.bounds inView:self.imageView animated:YES error:&error];

    if (!result) {
        NSLog(@"%@", error.description);
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
