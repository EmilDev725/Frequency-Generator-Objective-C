//
//  AudioOutputStream.m
//  generator
//
//  Created by 이승희 on 8/1/16.
//  Copyright © 2016 이승희. All rights reserved.
//

#import "AudioOutputStream.h"
#import <AudioToolbox/AudioToolbox.h>

static const int NUMBER_AUDIO_DATA_BUFFERS = 3;
static const int BUFFER_BYTE_SIZE = 1024;

@interface AudioOutputStream ()

@property (readonly) AudioStreamBasicDescription* packetDescriptions;
@property (readonly) BOOL stopped;
@property (readonly) BOOL audioPlayerShouldStopImmediately;
@property (readonly) UInt32 bufferByteSize;
@property (readonly) UInt32 bufferPacketCount;

@end

static void playbackCallback(void* inUserData, AudioQueueRef inAudioQueue, AudioQueueBufferRef bufferRef)
{
    AudioOutputStream *player = (__bridge AudioOutputStream*) inUserData;
    
    if(player.stopped)
    {
        return;
    }
    
    [player.audioSource outputStream:player fillBuffer:bufferRef->mAudioData bufferSize:player.bufferByteSize];
    
    bufferRef->mAudioDataByteSize = player.bufferByteSize;
    
    AudioQueueEnqueueBuffer(inAudioQueue, bufferRef, player.bufferPacketCount, player.packetDescriptions);
}

@implementation AudioOutputStream
{
    @private
    AudioQueueBufferRef buffers[NUMBER_AUDIO_DATA_BUFFERS];
}

-(instancetype) initWithAudioFormat:(AudioStreamBasicDescription)format
{
    self = [super initWithAudioFormat:format];
    
    if(self)
    {
        [self setupPlaybackAudioQueueObject];
        
        _stopped = NO;
        _audioPlayerShouldStopImmediately = NO;
        _bufferByteSize = BUFFER_BYTE_SIZE;
    }
    
    return self;
}

-(void) setupPlaybackAudioQueueObject
{
    AudioQueueNewOutput(&_audioFormat, playbackCallback, (__bridge void*)(self), nil, nil, 0, &_queueObject);
    AudioQueueSetParameter(_queueObject, kAudioQueueParam_Volume, 1.0f);
}

-(void) setupAudioQueueBuffers
{
    /*
     * prime the queue with some data before starting
     * allocate and enqueue buffers
     */
    
    for(int bufferIndex = 0; bufferIndex < NUMBER_AUDIO_DATA_BUFFERS; ++bufferIndex)
    {
        AudioQueueAllocateBuffer(_queueObject, _bufferByteSize, &buffers[bufferIndex]);
        
        playbackCallback((__bridge void*)(self), _queueObject, buffers[bufferIndex]);
        
        if(_stopped)
        {
            break;
        }
    }
}

-(void) play
{
    [self setupAudioQueueBuffers];
    
    AudioQueueStart(_queueObject, NULL);
}

-(void) stop
{
    AudioQueueStop(_queueObject, self.audioPlayerShouldStopImmediately);
}

-(void) pause
{
    AudioQueuePause(_queueObject);
}

-(void) resume
{
    AudioQueueDispose(_queueObject, YES);
}
@end
