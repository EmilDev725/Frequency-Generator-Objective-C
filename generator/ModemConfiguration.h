//
//  ModemConfiguration.h
//  generator
//
//  Created by iDeveloper on 8/1/16.
//  Copyright © 2016 iDeveloper. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ModemConfiguration : NSObject

@property (readonly) UInt16 highFrequency;
@property (readonly) UInt16 lowFrequency;
@property (readonly) UInt16 baudRate;

@property (readonly) NSTimeInterval highFrequencyWaveDuration;
@property (readonly) NSTimeInterval lowFrequencyWaveDuration;
@property (readonly) NSTimeInterval bitDuration;

+(ModemConfiguration*) lowSpeedConfiguration;
+(ModemConfiguration*) mediumSpeedConfiguration;
+(ModemConfiguration*) highSpeedConfiguration;

@end
