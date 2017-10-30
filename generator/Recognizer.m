//
//  Recognizer.m
//  generator
//
//  Created by iDeveloper on 8/1/16.
//  Copyright © 2016 iDeveloper. All rights reserved.
//

#import "Recognizer.h"
#import "Queue.h"

typedef NS_ENUM(NSInteger, RecState)
{
    Start,
    Bits,
    Success,
    Fail
};

static const int SMOOTH = 3;
static const int SMOOTHER_COUNT = SMOOTH * (SMOOTH + 1) / 2;

@implementation Recognizer
{
    @private
    
    unsigned _recentLows;
    unsigned _recentHighs;
    unsigned _halfWaveHistory[SMOOTH];
    unsigned _bitPosition;
    unsigned _recentWidth;
    unsigned _recentAvrWidth;
    
    UInt8    _bits;
    RecState _state;
    Queue*   _queue;
    
    ModemConfiguration* _configuration;
}

-(instancetype) initWithConfiguration:(ModemConfiguration *)configuration
{
    self = [super init];
    
    if(self)
    {
        _configuration = configuration;
        
        _queue = [[Queue alloc] init];
        [self reset];
    }
    
    return self;
}

-(void) commitBytes
{
    while(_queue.count)
    {
        NSNumber *value = [_queue dequeueObject];
        UInt8 input = value.unsignedIntegerValue;
        [_delegate recognizer:self didReceiveByte:input];
    }
}

-(void) dataBit:(BOOL)one
{
    if(one)
    {
        _bits |= (1 << _bitPosition);
    }
    
    _bitPosition++;
}

-(void) determineStateForBit:(BOOL)isHigh
{
    RecState newState = Fail;
    switch (_state) {
        case Start:
        {
            // start bit
            if(!isHigh)
            {
                newState = Bits;
                _bits = 0;
                _bitPosition = 0;
            }
            else
            {
                newState = Start;
            }
            
            break;
        }
        case Bits:
        {
            if(_bitPosition <= 7)
            {
                newState = Bits;
                [self dataBit:isHigh];
            }
            else if(_bitPosition == 8)
            {
                newState = Start;
                [_queue enqueueObject:[NSNumber numberWithChar:_bits]];
                [self performSelectorOnMainThread:@selector(commitBytes) withObject:nil waitUntilDone:NO];
                _bits = 0;
                _bitPosition = 0;
            }
            break;
        }
            
        default:
        {
            
        }
    }
    
    _state = newState;
}

-(void) processHalfWave: (unsigned)width
{
    // calculate necessary values
    int discriminator = SMOOTHER_COUNT * (_configuration.highFrequencyWaveDuration + _configuration.lowFrequencyWaveDuration) / 4;
    
    // shift historic values to the next index
    for(int i = SMOOTH - 2; i >= 0; i--)
    {
        _halfWaveHistory[i + 1] = _halfWaveHistory[i];
    }
    
    _halfWaveHistory[0] = width;
    
    // smooth input
    unsigned waveSum = 0;
    
    for(int i = 0; i < SMOOTH; ++i)
    {
        waveSum += _halfWaveHistory[i] * (SMOOTH - i);
    }
    
    // determine frequency
    BOOL ishighFrequency = waveSum < discriminator;
    unsigned avgWidth = waveSum / SMOOTHER_COUNT;
    
    _recentWidth += width;
    _recentAvrWidth += avgWidth;
    
    if(_state == Start)
    {
        if(!ishighFrequency)
        {
            _recentLows += avgWidth;
        }
        else if(_recentLows)
        {
            _recentHighs += avgWidth;
            
            // high bit -> error -> reset
            if(_recentHighs > _recentLows)
            {
                _recentLows = _recentHighs = 0;
            }
        }
        
        if(_recentLows + _recentHighs >= _configuration.bitDuration)
        {
            // we have received the low bit that indicates the beginning of a byte
            [self determineStateForBit:NO];
            _recentWidth = _recentAvrWidth = 0;
            
            if (_recentLows < _configuration.bitDuration) {
                _recentLows = 0;
            }
            else
            {
                _recentLows -= _configuration.bitDuration;
            }
            
            if (!ishighFrequency) {
                _recentHighs = 0;
            }
        }
    }
    else
    {
        if(ishighFrequency)
        {
            _recentHighs += avgWidth;
        }
        else
        {
            _recentLows += avgWidth;
        }
        
        if (_recentLows + _recentHighs >= _configuration.bitDuration)
        {
            BOOL isHighFrequencyRegion = _recentHighs > _recentLows;
            [self determineStateForBit:isHighFrequencyRegion];
            
            _recentWidth -= _configuration.bitDuration;
            _recentAvrWidth -= _configuration.bitDuration;
            
            if(_state == Start)
            {
                // the byte ended, rest the accumulators
                _recentLows = _recentHighs = 0;
                return;
            }
            
            unsigned *matched = isHighFrequencyRegion ? &_recentHighs : &_recentLows;
            unsigned *unmatched = isHighFrequencyRegion ? &_recentLows : &_recentHighs;
            
            if(*matched < _configuration.bitDuration)
            {
                *matched = 0;
            }
            else
            {
                *matched -= _configuration.bitDuration;
            }
            
            if(ishighFrequency == isHighFrequencyRegion)
            {
                *unmatched = 0;
            }
        }
    }
}

-(void) edge:(int)height width:(UInt64)nsWidth interval:(UInt64)nsInterval
{
    if(nsInterval <= _configuration.lowFrequencyWaveDuration / 2 + _configuration.highFrequencyWaveDuration / 2)
    {
        [self processHalfWave:(unsigned)nsInterval];
    }
}

-(void) idle:(UInt64)nsInterval
{
    [self reset];
}

-(void) reset
{
    _bits = 0;
    _bitPosition = 0;
    _state = Start;
    
    for(int i = 0; i < SMOOTH; i++)
    {
        _halfWaveHistory[i] = (_configuration.highFrequencyWaveDuration + _configuration.lowFrequencyWaveDuration) / 4;
    }
    
    _recentLows = _recentHighs = 0;
}

@end
