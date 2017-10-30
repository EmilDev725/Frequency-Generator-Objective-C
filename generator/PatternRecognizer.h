//
//  PatternRecognizer.h
//  generator
//
//  Created by iDeveloper on 8/1/16.
//  Copyright © 2016 iDeveloper. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PatternRecognizer <NSObject>

-(void) edge: (int)height width:(UInt64)nsWidth interval:(UInt64)nsInterval;
-(void) idle: (UInt64)nsInterval;
-(void) reset;

@end
