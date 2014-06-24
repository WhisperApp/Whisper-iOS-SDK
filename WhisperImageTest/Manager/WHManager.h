//
//  WHManager.h
//  WhisperImageTest
//
//  Created by whisper on 6/23/14.
//  Copyright (c) 2014 Whisper. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WHManager : NSObject

@property BOOL autotakeToAppStore;

+(CGSize) minImageSize;

-(id) initWithView:(UIView*) view;

-(BOOL) createWhisperWithData:(NSData*) data;
-(BOOL) createWhisperWithImage:(UIImage*)image;
-(BOOL) createWhisperWithURL:(NSURL*)url;
-(BOOL) createWhisperWithPath:(NSString*)path;

@end
