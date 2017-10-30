//
//  ViewModel.m
//  generator
//
//  Created by iDeveloper on 8/2/16.
//  Copyright © 2016 iDeveloper. All rights reserved.
//

#import "ViewModel.h"
#import "Modem.h"

@interface ViewModel () <ModemDelegate>

@end

@implementation ViewModel
{
    @private
    Modem* _modem;
}

-(instancetype) initWithModem:(Modem *)modem
{
    self = [super init];
    
    if (self)
    {
        _modem = modem;
        _modem.delegate = self;
        _receivedText = @"";
    }
    
    return self;
}

-(void) sendMessage:(NSString *)message
{
    NSData* data = [message dataUsingEncoding:NSASCIIStringEncoding];
    [_modem sendData:data];
}

-(void) connect
{
    [_modem connect];
}

-(void) disconnect
{
    [_modem disconnect];
}

-(void) setConnected:(BOOL)connected
{
    [self willChangeValueForKey:@"connected"];
    _connected = connected;
    
    [self didChangeValueForKey:@"connected"];
}

#pragma mark - Delegate

-(void) modem:(Modem *)modem didReceiveData:(NSData *)data
{
    NSString* text = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    
    [self willChangeValueForKey:@"receivedText"];
    
    _receivedText = [_receivedText stringByAppendingFormat:@"%@\n", text];
    
    [self didChangeValueForKey:@"receivedText"];
}

-(void) modemDidConnect:(Modem *)modem
{
    [self setConnected:YES];
}

-(void) modemDidDisconnect:(Modem *)modem
{
    [self setConnected:NO];
}

@end
