//
//  ProtocolDecoderDelegate.h
//  generator
//
//  Created by iDeveloper on 8/1/16.
//  Copyright © 2016 iDeveloper. All rights reserved.
//

@class ProtocolDecoder;

@protocol ProtocolDecoderDelegate <NSObject>

-(void) decoder: (ProtocolDecoder*)decoder didDecodeData:(NSData*) data;

@end
