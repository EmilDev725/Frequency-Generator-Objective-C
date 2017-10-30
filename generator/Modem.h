//
//  Modem.h
//  generator
//
//  Created by iDeveloper on 8/1/16.
//  Copyright © 2016 iDeveloper. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "ModemConfiguration.h"
#import "ModemDelegate.h"

@interface Modem : NSObject

@property (nonatomic, weak) id<ModemDelegate> delegate;
@property (readonly) BOOL connected;

-(instancetype)initWithConfiguration:(ModemConfiguration*)configuration;

-(void) connect;
-(void) connect:(void (^)(BOOL error))completion;

-(void) disconnect;
-(void) disconnect:(void (^)(BOOL error))completion;

-(void) sendData:(NSData*)data;

@end
