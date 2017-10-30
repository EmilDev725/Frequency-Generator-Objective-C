//
//  ModemConfiguration.m
//  generator
//
//  Created by iDeveloper on 8/1/16.
//  Copyright © 2016 iDeveloper. All rights reserved.
//

#import "ModemConfiguration.h"

@implementation ModemConfiguration

-(instancetype)initWithBaudRate:(UInt16)baudRate lowFrequency:(UInt16)lowFrequency highFrequency:(UInt16)highFrequency
{
    self = [super init];
    
    if(self)
    {
        _baudRate = baudRate;
        _highFrequency = highFrequency;
        _lowFrequency = lowFrequency;
        
        _highFrequencyWaveDuration = (double) NSEC_PER_SEC / (double) _highFrequency;
        _lowFrequencyWaveDuration = (double) NSEC_PER_SEC / (double) _lowFrequency;
        _bitDuration = (double) NSEC_PER_SEC / _baudRate;
    }
    
    return self;
}

+(ModemConfiguration*) lowSpeedConfiguration
{
    return [[ModemConfiguration alloc]initWithBaudRate:100 lowFrequency:800 highFrequency:1600];
}

+(ModemConfiguration*) mediumSpeedConfiguration
{
    return [[ModemConfiguration alloc]initWithBaudRate:600 lowFrequency:2666 highFrequency:4000];
}

+(ModemConfiguration*) highSpeedConfiguration
{
    return [[ModemConfiguration alloc]initWithBaudRate:1225 lowFrequency:4900 highFrequency:7350];
}

@end
