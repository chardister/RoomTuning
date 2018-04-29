//
//  FirstViewController.h
//  RoomTuningCH
//
//  Created by Christina Hardister on 8/7/17.
//  Copyright © 2017 Christina Hardister. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AVEngine.h"
#import "AudioFFTView.h"
#import "MeterView.h"
#import "AppDelegate.h"



// Test Mode - play and record sine sweep
@interface FirstViewController : UIViewController
{
    IBOutlet MeterView *LeftMeterView;
    IBOutlet MeterView *RightMeterView;
    IBOutlet AudioFFTView *FFTplot;
    
}

// local audio engine
@property (nonatomic) AVEngine *sweepPlayer;

- (IBAction)startTestButtonPressed:(UIButton *)sender;
- (IBAction)stopTestButtonPressed:(UIButton *)sender;
- (IBAction)plotFreqResponseButtonPressed:(UIButton *)sender;


@end

