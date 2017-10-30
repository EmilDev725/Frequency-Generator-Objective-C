//
//  SerialGenerator.h
//  generator
//
//  Created by iDeveloper on 8/1/16.
//  Copyright © 2016 iDeveloper. All rights reserved.
//

#import <AudioToolbox/AudioToolbox.h>
#import "AudioSource.h"
#import "ModemConfiguration.h"

@interface SerialGenerator : NSObject<AudioSource>

-(instancetype) initWithAudioFormat:(AudioStreamBasicDescription*)audioFormat configuration:(ModemConfiguration*)configuration;
-(void) writeData:(NSData*)data;

@end
