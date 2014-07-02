//
//  PostViewController.h
//  Whisper-iOS-SDKTest
//
//  Created by whisper on 6/30/14.
//  Copyright (c) 2014 Whisper. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PostViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (strong, nonatomic) NSURL *imageURL;
@end
