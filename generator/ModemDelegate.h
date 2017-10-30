//
//  ModemDelegate.h
//  generator
//
//  Created by iDeveloper on 8/1/16.
//  Copyright © 2016 iDeveloper. All rights reserved.
//

@class Modem;
@protocol ModemDelegate <NSObject>

-(void) modemDidConnect:(Modem*)modem;
-(void) modemDidDisconnect:(Modem*)modem;
-(void) modem:(Modem*)modem didReceiveData:(NSData*)data;

@end
