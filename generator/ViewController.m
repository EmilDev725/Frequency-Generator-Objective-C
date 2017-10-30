//
//  ViewController.m
//  generator
//
//  Created by iDeveloper on 7/29/16.
//  Copyright © 2016 iDeveloper. All rights reserved.
//

#import "ViewController.h"
#import <AudioToolbox/AudioToolbox.h>


OSStatus RenderTone(
    void                        *inRefCon,
    AudioUnitRenderActionFlags  *ioActionFlags,
    const AudioTimeStamp        *inTimeStamp,
    UInt32                      inBusNumber,
    UInt32                      inNumberFrames,
    AudioBufferList             *ioData
)
{
    // Fixed amplitude is good enough for our purposes
    const double amplitude = 0.25;
    
    // get the tone parameters out of the view controller
    ViewController *viewController = (__bridge ViewController *)inRefCon;
    double theta = viewController->theta;
    double thetaIncrement = 2.0 * M_PI * viewController->frequency / viewController->sampleRate;
    
    // this is a mono tone generators out of the view controller
    const int channel = 0;
    Float32 *buffer = (Float32 *)ioData->mBuffers[channel].mData;
    
    // generate the samples
    for(UInt32 frame = 0; frame < inNumberFrames; frame++)
    {
        buffer[frame] = sin(theta) * amplitude;
        
        theta += thetaIncrement;
        if(theta > 2.0 * M_PI)
        {
            theta -= 2.0 * M_PI;
        }
    }
    
    // store the theta back in the view controller
    viewController->theta = theta;
    
    return noErr;
}

void ToneInterruptionListener(void *inClientData, UInt32 inInterruptionState)
{
    ViewController *viewController = (__bridge ViewController *)inClientData;
    
    [viewController stop];
}

@implementation ViewController
@synthesize frequencyLabel, generate, frequencySlider;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self sliderChanged:frequencySlider];
    sampleRate = 44100;
    
    
    OSStatus result = AudioSessionInitialize(NULL, NULL, ToneInterruptionListener, (__bridge void *)(self));
    
    if(result == kAudioSessionNoError)
    {
        UInt32 sessionCategory = kAudioSessionCategory_MediaPlayback;
        AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(sessionCategory), &sessionCategory);
    }
    
    AudioSessionSetActive(true);
}

-(void)viewDidUnload
{
    self.frequencyLabel = nil;
    self.generate = nil;
    self.frequencySlider = nil;
    
    AudioSessionSetActive(false);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)toggleButton:(UIButton *)sender {
    if(toneUnit)
    {
        AudioOutputUnitStop(toneUnit);
        AudioUnitUninitialize(toneUnit);
        AudioComponentInstanceDispose(toneUnit);
        toneUnit = nil;
        
        [sender setTitle:NSLocalizedString(@"generate", nil) forState:0];
    }
    else
    {
        [self gernerateUnit];
        
        // stop changing parameters on the unit
        OSErr err = AudioUnitInitialize(toneUnit);
        NSAssert1(err == noErr, @"Error initializing unit: %ld", (long)err);
        
        // start playback
        err = AudioOutputUnitStart(toneUnit);
        NSAssert1(err == noErr, @"Error starting unit: %ld", (long)err);
        
        [sender setTitle:NSLocalizedString(@"stop", nil) forState:0];
    }
}

- (IBAction)sliderChanged:(UISlider *)slider {
    frequency = slider.value;
    frequencyLabel.text = [NSString stringWithFormat:@"%4.1f Hz", frequency];
}

-(void)gernerateUnit
{
    /*
     * configure the search parameters to find the default playback output unit
     * (called the kAudioUnitSubType_RemoteIO on iOS but
     * kAudioUnitSubType_DefualtOutput on Mac OS X)
     */
    
    AudioComponentDescription defaultOutputDescription;
    defaultOutputDescription.componentType = kAudioUnitType_Output;
    defaultOutputDescription.componentSubType = kAudioUnitSubType_RemoteIO;
    defaultOutputDescription.componentManufacturer = kAudioUnitManufacturer_Apple;
    defaultOutputDescription.componentFlags = 0;
    defaultOutputDescription.componentFlagsMask = 0;
    
    // get the defualt playback output unit
    AudioComponent defaultOutput = AudioComponentFindNext(NULL, &defaultOutputDescription);
    NSAssert(defaultOutput, @"Can't find default output");
    
    // create a new unit based on this that we'll use for output
    OSErr err = AudioComponentInstanceNew(defaultOutput, &toneUnit);
    NSAssert1(toneUnit, @"Error creating unit: %ld", (long)err);
    
    // set our tone rendering function on the unit
    AURenderCallbackStruct input;
    input.inputProc = RenderTone;
    input.inputProcRefCon = (__bridge void * _Nullable)(self);
    err = AudioUnitSetProperty(toneUnit, kAudioUnitProperty_SetRenderCallback, kAudioUnitScope_Input, 0, &input, sizeof(input));
    NSAssert1(err == noErr, @"Error setting callback: %ld", (long)err);
    
    // set the format to 32 bit, single channel, floating point, linear PCM
    const int four_bytes_per_float = 4;
    const int eight_bits_per_byte = 8;
    AudioStreamBasicDescription streamFormat;
    streamFormat.mSampleRate = sampleRate;
    streamFormat.mFormatID = kAudioFormatLinearPCM;
    streamFormat.mFormatFlags = kAudioFormatFlagsNativeFloatPacked | kAudioFormatFlagIsNonInterleaved;
    streamFormat.mBytesPerPacket = four_bytes_per_float;
    streamFormat.mFramesPerPacket = 1;
    streamFormat.mBytesPerFrame = four_bytes_per_float;
    streamFormat.mChannelsPerFrame = 1;
    streamFormat.mBitsPerChannel = four_bytes_per_float * eight_bits_per_byte;
    err = AudioUnitSetProperty(toneUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, 0, &streamFormat, sizeof(AudioStreamBasicDescription));
    //NSAssert1(err = noErr, @"Error setting stream format: %ld", err);
}

- (void)stop
{
    if(toneUnit)
    {
        [self toggleButton:generate];
    }
    
}

@end
