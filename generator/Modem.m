//
//  Modem.m
//  generator
//
//  Created by iDeveloper on 8/1/16.
//  Copyright © 2016 iDeveloper. All rights reserved.
//

#import "Modem.h"
#import <AudioToolbox/AudioToolbox.h>

#import "SerialGenerator.h"
#import "AudioOutputStream.h"
#import "AudioInputStream.h"
#import "Recognizer.h"
#import "ProtocolDecoder.h"
#import "ProtocolDecoderDelegate.h"
#import "ProtocolEncoder.h"

static const int SAMPLE_RATE = 44100;
static const int NUM_CHANNELS = 1;
static const int BITS_PER_CHANNEL = 16;
static const int BYTES_PER_FRAME = (NUM_CHANNELS * (BITS_PER_CHANNEL / 8));

@interface Modem () <ProtocolDecoderDelegate>

@end

@implementation Modem
{
    @private
    
    ModemConfiguration*             _configuration;
    AudioStreamBasicDescription*    _audioFormat;
    
    AudioInputStream*               _inputStream;
    AudioOutputStream*              _outputStream;
    SerialGenerator*                _generator;
    ProtocolDecoder*                _decoder;
    ProtocolEncoder*                _encoder;
    
    dispatch_once_t                 _setupToken;
}

-(instancetype) initWithConfiguration:(ModemConfiguration *)configuration
{
    self = [super init];
    
    if (self) {
        _configuration = configuration;
    }
    
    return self;
}

-(void) dealloc
{
    [self disconnect:NULL];
    
    if (_audioFormat) {
        //delete _audioFormat;
    }
}

-(void) setupAudioFormat
{
    _audioFormat = (AudioStreamBasicDescription*) malloc(sizeof(AudioStreamBasicDescription));
    
    _audioFormat->mSampleRate = SAMPLE_RATE;
    _audioFormat->mFormatID = kAudioFormatLinearPCM;
    _audioFormat->mFormatFlags = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
    _audioFormat->mFramesPerPacket = 1;
    _audioFormat->mChannelsPerFrame = NUM_CHANNELS;
    _audioFormat->mBitsPerChannel = BITS_PER_CHANNEL;
    _audioFormat->mBytesPerPacket = BYTES_PER_FRAME;
    _audioFormat->mBytesPerFrame = BYTES_PER_FRAME;
}

-(void) setup
{
    __weak typeof(self) weakSelf = self;
    
    dispatch_once(&_setupToken, ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        [strongSelf setupAudioFormat];
        
        strongSelf->_encoder = [[ProtocolEncoder alloc]init];
        strongSelf->_outputStream = [[AudioOutputStream alloc]initWithAudioFormat:*_audioFormat];
        strongSelf->_inputStream = [[AudioInputStream alloc]initWithAudioFormat:*_audioFormat];
        strongSelf->_generator = [[SerialGenerator alloc]initWithAudioFormat:strongSelf->_audioFormat configuration:strongSelf->_configuration];
        strongSelf->_outputStream.audioSource = _generator;
        
        strongSelf->_decoder = [[ProtocolDecoder alloc]init];
        strongSelf->_decoder.delegate = self;
        
        Recognizer* recognizer = [[Recognizer alloc]initWithConfiguration:strongSelf->_configuration];
        recognizer.delegate = _decoder;
        
        [strongSelf->_inputStream addRecognizer:recognizer];
        
    });
}

-(void) connect
{
    [self connect:NULL];
}

-(void) connect:(void (^)(BOOL))completion
{
    if(!_connected)
    {
        __weak typeof(self) weakSelf = self;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            
            [strongSelf setup];
            
            if([AVAudioSession sharedInstance].availableInputs.count > 0)
            {
                [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
                [strongSelf->_inputStream record];
            }
            else
            {
                [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
            }
            
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(routeChanged:) name:AVAudioSessionRouteChangeNotification object:nil];
            
            NSError* error = nil;
            [[AVAudioSession sharedInstance] setActive:YES error:&error];
            
            if (error)
            {
                if (completion)
                {
                    completion(YES);
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [strongSelf->_delegate modemDidDisconnect:strongSelf];
                });
                
                return ;
            }
            
            [strongSelf->_outputStream play];
            
            strongSelf->_connected = YES;
            
            if (completion)
            {
                completion(NO);
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [strongSelf->_delegate modemDidConnect:strongSelf];
            });
        });
    }
}

-(void)disconnect
{
    [self disconnect:NULL];
}

-(void)disconnect:(void (^)(BOOL))completion
{
    if (_connected)
    {
        __weak typeof(self) weakSelf = self;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            
            [strongSelf->_inputStream stop];
            [strongSelf->_outputStream stop];
            
            [[NSNotificationCenter defaultCenter] removeObserver:self name:AVAudioSessionRouteChangeNotification object:nil];
            
            NSError* error = nil;
            [[AVAudioSession sharedInstance] setActive:NO error:&error];
            
            if (error)
            {
                if (completion)
                {
                    completion(YES);
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [strongSelf->_delegate modemDidConnect:strongSelf];
                });
                
                return ;
            }
            
            strongSelf->_connected = NO;
            
            if (completion)
            {
                completion(NO);
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                 [strongSelf->_delegate modemDidDisconnect:strongSelf];
            });
        });
    }
}

-(void)sendData:(NSData *)data
{
    if (_connected)
    {
        [_generator writeData:[_encoder encodeData:data]];
    }
}

#pragma mark - Protocol decoder delegate

-(void)decoder:(ProtocolDecoder *)decoder didDecodeData:(NSData *)data
{
    [_delegate modem:self didReceiveData:data];
}

#pragma mark - Notifications

-(void)routeChanged:(NSNotification *)notification
{
    if (_connected)
    {
        [self disconnect:NULL];
        
        [self connect:NULL];
    }
}

@end
