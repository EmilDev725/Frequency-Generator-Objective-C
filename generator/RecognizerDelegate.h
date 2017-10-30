//
//  RecognizerDelegate.h
//  generator
//
//  Created by iDeveloper on 8/1/16.
//  Copyright © 2016 iDeveloper. All rights reserved.
//

@class Recognizer;

@protocol RecognizerDelegate

-(void) recognizer: (Recognizer*) recognizer didReceiveByte:(UInt8) input;

@end
