//
//  AudioOutputStream.h
//  generator
//
//  Created by 이승희 on 8/1/16.
//  Copyright © 2016 이승희. All rights reserved.
//

#import "AudioSource.h"
#import "AudioStream.h"

@interface AudioOutputStream : AudioStream

@property (nonatomic, strong) id<AudioSource> audioSource;

-(void) play;
-(void) stop;
-(void) pause;
-(void) resume;

@end
