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
    
    UIImage* image = [UIImage imageNamed:@"beyonce.jpg"];
    NSAssert(image, @"image is nil");
    self.imageView.clipsToBounds = YES;
    self.imageView.image = image;
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    self.url = [[NSBundle mainBundle] URLForResource:@"beyonce" withExtension:@"jpg"];
    NSAssert(self.url, @"no url!");
    
    self.manager = [WHManager whisperManagerForView:self.imageView];
}

- (IBAction)openButton:(id)sender {
    [self.manager createWhisperWithURL:self.url];
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
