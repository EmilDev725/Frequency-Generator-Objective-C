//
//  SerialGenerator.m
//  generator
//
//  Created by iDeveloper on 8/1/16.
//  Copyright © 2016 iDeveloper. All rights reserved.
//

#import "SerialGenerator.h"
#import "Queue.h"
#import "ModemConfiguration.h"

static const int SAMPLE_LIMIT_FACTOR = 100;

static const int NUMBER_OF_DATA_BITS = 8;
static const int NUMBER_OF_START_BITS = 1;
static const int NUMBER_OF_STOP_BITS = 1;

@implementation SerialGenerator
{
    @private
    int                         _sineTableLength;
    SInt16*                     _sineTable;
    float                       _nsBitProgress;
    unsigned                    _sineTableIndex;
    unsigned                    _bitCount;
    UInt16                      _bits;
    BOOL                        _idle;
    BOOL                        _sendCarrier;
    Queue*                      _queue;
    AudioStreamBasicDescription _audioFormat;
    ModemConfiguration*         _configuration;
}

-(instancetype) initWithAudioFormat:(AudioStreamBasicDescription *)audioFormat configuration:(ModemConfiguration *)configuration
{
    self = [super init];
    
    if(self)
    {
        _configuration = configuration;
        _audioFormat = *audioFormat;
        _queue = [[Queue alloc] init];
        _idle = YES;
        _sineTableLength = _audioFormat.mSampleRate / SAMPLE_LIMIT_FACTOR;
        _sineTable = (SInt16*) malloc(sizeof(SInt16) * _sineTableLength);
        
        int maxValuePerChannel = (1 << (_audioFormat.mBitsPerChannel - 1)) - 1;
        
        for(int i = 0; i < _sineTableLength; i++)
        {
            // transfer values between -1.0 and 1.0 to integer values between -sample amx and sample max
            _sineTable[i] = (SInt16)(sin(i * 2 * M_PI / _sineTableLength) * maxValuePerChannel);
        }
    }
    
    return self;
}

-(void) dealloc
{
    //delete _sineTable;
}

-(BOOL) hasNextByte
{
    // set the output bit HIGH to indicate that here is no data transmission
    _bits = 1;
    
    if(_idle)
    {
        if(_queue.count > 0)
        {
            int preCarrierBitsCount = _configuration.baudRate / 25 + 1;
            
            _bitCount = preCarrierBitsCount;
            _sendCarrier = YES;
            _idle = NO;
            
            return YES;
        }
    }
    else
    {
        if(_queue.count > 0)
        {
            NSNumber* value = [_queue dequeueObject];
            UInt8 byte = value.unsignedIntValue;
            _bits = byte;
            
            // set start bits to LOW
            _bits <<= NUMBER_OF_START_BITS;
            
            // set stop bits to HIGH
            _bits |= UINT16_MAX << (NUMBER_OF_START_BITS + NUMBER_OF_DATA_BITS);
            
            _bitCount = NUMBER_OF_DATA_BITS + NUMBER_OF_START_BITS + NUMBER_OF_STOP_BITS;
            _sendCarrier = NO;
        }
        else
        {
            int postCarrierBitsCount = _configuration.baudRate / 200 + 1;
            
            _bitCount = postCarrierBitsCount;
            _sendCarrier = YES;
            _idle = YES;
        }
        
        return YES;
    }
    return NO;
}

-(void) outputStream:(AudioOutputStream *)stream fillBuffer:(void *)buffer bufferSize:(NSUInteger)bufferSize
{
    SInt16* sample = (SInt16*)buffer;
    BOOL underflow = NO;
    
    if(!_bitCount)
    {
        underflow = ![self hasNextByte];
    }
    
    for(int i = 0; i < bufferSize; i += _audioFormat.mBytesPerFrame, sample++)
    {
        // send next bit
        if(_nsBitProgress >= _configuration.bitDuration)
        {
            if(_bitCount)
            {
                --_bitCount;
                
                if(!_sendCarrier)
                {
                    _bits >>= 1;
                }
            }
            
            
            _nsBitProgress -= _configuration.bitDuration;
            
            if(!_bitCount)
            {
                underflow = ![self hasNextByte];
            }
        }
        
        *sample = [self modulate:underflow];
        
        if(_bitCount)
        {
            float sampleDuration = NSEC_PER_SEC / _audioFormat.mSampleRate;
            _nsBitProgress += sampleDuration;
        }
    }
}

-(SInt16) modulate:(BOOL) underflow
{
    if(underflow)
    {
        // no more bits to send
        return 0;
    }
    
    // modulate bits to high and low frequencies
    int highFrequencyThreshold = _configuration.highFrequency / SAMPLE_LIMIT_FACTOR;
    int lowFrequencyThreshold = _configuration.lowFrequency / SAMPLE_LIMIT_FACTOR;
    
    _sineTableIndex += (_bits & 1) ? highFrequencyThreshold:lowFrequencyThreshold;
    _sineTableIndex %= _sineTableLength;
    
    return _sineTable[_sineTableIndex];
}

-(void) writeData:(NSData *)data
{
    const char* bytes = (const char*) [data bytes];
    
    for(int i = 0; i < data.length; i++)
    {
        [_queue enqueueObject:[NSNumber numberWithChar:bytes[i]]];
    }
}

@end
