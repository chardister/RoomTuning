//
//  SecondViewController.h
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


@interface SecondViewController : UIViewController
{
    
    IBOutlet AudioFFTView *InverseFilterPlot;
    IBOutlet AudioFFTView *NewFFTPlot;
}

// local audio engine
@property (nonatomic) AVEngine *analyzerEngine;

- (IBAction)CorrectAndTestButtonPressed:(UIButton *)sender;
- (IBAction)PlotNewFreqRespButtonPressed:(UIButton *)sender;
//- (IBAction)TestNewSineSweepButtonPressed:(UIButton *)sender;

@end

