//
//  AudioStream.h
//  generator
//
//  Created by 이승희 on 8/1/16.
//  Copyright © 2016 이승희. All rights reserved.
//

#import <AudioToolbox/AudioToolbox.h>

@interface AudioStream : NSObject
{
    @protected
    AudioQueueRef _queueObject;
    AudioStreamBasicDescription _audioFormat;
}

@property (NS_NONATOMIC_IOSONLY, getter=isRunning, readonly) BOOL running;

-(instancetype)initWithAudioFormat:(AudioStreamBasicDescription)format;

@end
