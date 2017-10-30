//
//  AudioStream.m
//  generator
//
//  Created by 이승희 on 8/1/16.
//  Copyright © 2016 이승희. All rights reserved.
//

#import "AudioStream.h"

@implementation AudioStream

-(instancetype)initWithAudioFormat:(AudioStreamBasicDescription)format
{
    self = [super init];
    
    if(self)
    {
        _audioFormat = format;
    }
    
    return self;
}

-(BOOL) isRunning
{
    UInt32      outData;
    UInt32      propertySize = sizeof(UInt32);
    OSStatus    result;
    
    result = AudioQueueGetProperty(_queueObject, kAudioQueueProperty_IsRunning, &outData, &propertySize);
    
    if(result != noErr)
    {
        return NO;
    }

    return outData;
}

@end
