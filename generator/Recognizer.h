//
//  Recognizer.h
//  generator
//
//  Created by iDeveloper on 8/1/16.
//  Copyright © 2016 iDeveloper. All rights reserved.
//

#import "PatternRecognizer.h"
#import "RecognizerDelegate.h"
#import "ModemConfiguration.h"

@interface Recognizer : NSObject <PatternRecognizer>

@property (nonatomic, weak) NSObject<RecognizerDelegate> *delegate;

-(instancetype) initWithConfiguration:(ModemConfiguration*) configuration;

@end
