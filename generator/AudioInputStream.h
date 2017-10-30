//
//  AudioInputStream.h
//  generator
//
//  Created by 이승희 on 8/1/16.
//  Copyright © 2016 이승희. All rights reserved.
//

#import "AudioStream.h"
#import "PatternRecognizer.h"

@interface AudioInputStream : AudioStream

-(void) addRecognizer: (id<PatternRecognizer>)recognizer;
-(void) removeRecognizer: (id<PatternRecognizer>)recognizer;

-(void) record;
-(void) stop;

@end
