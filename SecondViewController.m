//
//  SecondViewController.m
//  RoomTuningCH
//
//  Created by Christina Hardister on 8/7/17.
//  Copyright © 2017 Christina Hardister. All rights reserved.
//

#import "SecondViewController.h"

@interface SecondViewController ()

@end

@implementation SecondViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom Initialization
        
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // init the engine
    self.analyzerEngine = [[AVEngine alloc] initWithBufferSize:4096];

    InverseFilterPlot.fftSize = self.analyzerEngine.sigLength/2;
    NewFFTPlot.fftSize = self.analyzerEngine.sigLength/2;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// find and plot inverse filter
- (IBAction)CorrectAndTestButtonPressed:(UIButton *)sender
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.analyzerEngine.recordedAudio = appDelegate.recordedAudio;
    self.analyzerEngine.paddedBuff = appDelegate.paddedBuffer;

    // run this function for this engine, it has only been run for VC1 engine
    [self.analyzerEngine getMagnitudeResponse];

    // get inverse filter magnitudes and plot
    InverseFilterPlot.FFTmags = [self.analyzerEngine getInverseFilter];
    [InverseFilterPlot setNeedsDisplay];    
}

- (IBAction)PlotNewFreqRespButtonPressed:(UIButton *)sender
{
    // get simulated corrected response
    NewFFTPlot.FFTmags = [self.analyzerEngine getSimulatedCorrectedResponse];
    [NewFFTPlot setNeedsDisplay];
}


/*
- (IBAction)TestNewSineSweepButtonPressed:(UIButton *)sender
{
    //NewFFTPlot.FFTmags = self.analyzerEngine.getNewSineSweep;
    // set up engine with new sweep
    AVAudioPCMBuffer* newSweep = [self.analyzerEngine getNewSineSweep];
    [self.analyzerEngine setUpEngine:newSweep];
    
    // prepare engine
    [self.analyzerEngine.engine prepare];
    [self.analyzerEngine.engine startAndReturnError:nil];
    self.analyzerEngine.index = 0;
    
    // start the player
    [self.analyzerEngine startAudioPlayer];
    
    if (self.analyzerEngine.player.playing)
    {
        [self.analyzerEngine getInputAudioBuffer];
    }
        
}*/
@end




