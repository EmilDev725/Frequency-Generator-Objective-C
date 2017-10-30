//
//  ProtocolDecoder.h
//  generator
//
//  Created by iDeveloper on 8/1/16.
//  Copyright © 2016 iDeveloper. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ProtocolDecoderDelegate.h"
#import "RecognizerDelegate.h"

@interface ProtocolDecoder : NSObject<RecognizerDelegate>

@property (nonatomic, weak) id<ProtocolDecoderDelegate> delegate;

@end
