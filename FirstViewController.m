//
//  FirstViewController.m
//  RoomTuningCH
//
//  Created by Christina Hardister on 8/7/17.
//  Copyright © 2017 Christina Hardister. All rights reserved.
//

#import "FirstViewController.h"


@interface FirstViewController()
{
    //NSTimer *playbackMonitorTimer;
}

@end

@implementation FirstViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // init the engine
    self.sweepPlayer = [[AVEngine alloc] initWithBufferSize:4096];
    
    FFTplot.fftSize = self.sweepPlayer.sigLength/2;
 
}


- (IBAction)startTestButtonPressed:(UIButton *)sender
{
    // load audio file into engine
    NSString *audioFilePath = [[NSBundle mainBundle] pathForResource:@"SineSweepGood441_20sec" ofType:@"wav"];
    NSURL *url = [NSURL fileURLWithPath:audioFilePath];
    
    AVAudioFile* sweep = [[AVAudioFile alloc] initForReading:url error:nil];
    
    AVAudioPCMBuffer* bufferToPlay = [self.sweepPlayer fileIntoBuffer:sweep];
    bool succeeded = [self.sweepPlayer setUpEngine:bufferToPlay];
    if(!succeeded)
        NSLog(@"startAudioPlayerWithFile FAILED!");
    
    // save the buffer
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate storePaddedBuffer:bufferToPlay];

    // prepare engine
    [self.sweepPlayer.engine prepare];
    [self.sweepPlayer.engine startAndReturnError:nil];
    self.sweepPlayer.index = 0;

    // start the player
    [self.sweepPlayer startAudioPlayer];
    
    if (self.sweepPlayer.player.playing)
    {
        [self.sweepPlayer getInputAudioBuffer];
    }
        
}

- (IBAction)plotFreqResponseButtonPressed:(UIButton *)sender
{
    
    // store the recorded audio for the second view controller
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate storeRecordedAudio:self.sweepPlayer.recordedAudio];

    [self.sweepPlayer.engine stop];
    FFTplot.FFTmags = self.sweepPlayer.getMagnitudeResponse;
    [FFTplot setNeedsDisplay];
    
    // can clear recording tap once fft is plotted
    [self.sweepPlayer stopInputAudio];
    [self.sweepPlayer stopAudioPlayer];

}

- (IBAction)stopTestButtonPressed:(UIButton *)sender
{
    // stop the player
    [self.sweepPlayer stopAudioPlayer];
    
    // stop input audio data
    [self.sweepPlayer.input removeTapOnBus:(0)];
    
    // stop engine
    [self.sweepPlayer.engine stop];
}

#pragma mark - View lifecycle


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


@end
