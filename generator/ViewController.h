//
//  ViewController.h
//  generator
//
//  Created by iDeveloper on 7/29/16.
//  Copyright © 2016 iDeveloper. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioUnit/AudioUnit.h>

@interface ViewController : UIViewController
{
    UILabel                 *freqeuncyLabel;
    __weak UIButton         *generate;
    __weak UISlider         *frequencySlider;
    AudioComponentInstance  toneUnit;
    
    @public
    double frequency;
    double sampleRate;
    double theta;
}


@property (weak, nonatomic) IBOutlet UILabel *frequencyLabel;
@property (weak, nonatomic) IBOutlet UISlider *frequencySlider;
@property (weak, nonatomic) IBOutlet UIButton *generate;


- (IBAction)toggleButton:(UIButton *)sender;
- (IBAction)sliderChanged:(UISlider *)sender;
-(void)stop;

@end

