//
//  ProtocolEncoder.m
//  generator
//
//  Created by iDeveloper on 8/1/16.
//  Copyright © 2016 iDeveloper. All rights reserved.
//

#import "ProtocolEncoder.h"

static const UInt8 START_BYTE = 0xFF;
static const UInt8 ESCAPE_BYTE = 0x33;
static const UInt8 END_BYTE = 0x77;

@implementation ProtocolEncoder

-(NSData*) encodeData:(NSData *)data
{
    NSMutableData* encodedData = [NSMutableData dataWithCapacity:data.length];
    
    // append start byte
    [encodedData appendBytes:&START_BYTE length:1];
    
    // escape byte
    const UInt8* dataBytes = data.bytes;
    
    for(int i = 0; i < data.length; i++)
    {
        UInt8 dataByte = dataBytes[i];
        
        if(dataByte == START_BYTE || dataByte == END_BYTE || dataByte == ESCAPE_BYTE)
        {
            [encodedData appendBytes:&ESCAPE_BYTE length:1];
        }
        
        [encodedData appendBytes:&dataByte length:1];
    }
    
    // append end byte
    [encodedData appendBytes:&END_BYTE length:1];
    
    return encodedData;
}
@end
