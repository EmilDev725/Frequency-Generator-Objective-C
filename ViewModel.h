//
//  ViewModel.h
//  generator
//
//  Created by iDeveloper on 8/2/16.
//  Copyright © 2016 iDeveloper. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Modem;

@interface ViewModel : NSObject

@property (readonly) BOOL connected;
@property (nonatomic, strong, readonly) NSString* receivedText;

-(instancetype) initWithModem:(Modem *) modem;

-(void) sendMessage:(NSString*) message;
-(void) connect;
-(void) disconnect;

@end
