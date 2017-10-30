//
//  AudioSource.h
//  generator
//
//  Created by iDeveloper on 8/1/16.
//  Copyright © 2016 iDeveloper. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AudioOutputStream;

@protocol AudioSource <NSObject>

-(void) outputStream: (AudioOutputStream*)stream fillBuffer:(void*)buffer bufferSize:(NSUInteger)bufferSize;

@end
