//
//  NSData+ImageFormat.m
//  WhisperImageTest
//
//  Created by whisper on 6/27/14.
//  Copyright (c) 2014 Whisper. All rights reserved.
//

#import "NSData+ImageFormat.h"

static unsigned char wh_jpgImageHeaderBytes[3] =
{
    0xff, 0xd8, 0xff
};
#define wh_jpgImageHeaderLength 3

static unsigned char wh_pngImageHeaderBytes[4] =
{
    0x89, 0x50, 0x4e, 0x47
};
#define wh_pngImageHeaderLength 4

@implementation NSData (ImageFormat)

-(BOOL)whp_isJPG
{
    return [self whp_matchesHeaderWithBytes:wh_jpgImageHeaderBytes length:wh_jpgImageHeaderLength];
}

-(BOOL)whp_isPNG
{
    return [self whp_matchesHeaderWithBytes:wh_pngImageHeaderBytes length:wh_pngImageHeaderLength];
}

-(BOOL)whp_matchesHeaderWithBytes:(unsigned char[]) bytes length:(unsigned int) length
{
    if (self.length < length)
        return NO;
    
    unsigned char buffer[length];
    [self getBytes:&buffer length:length];
    for (unsigned int i=0; i<length; i++) {
        if (buffer[i] != bytes[i])
            return NO;
    }
    return YES;
}

@end
