//
//  AppDelegate.h
//  RoomTuningCH
//
//  Created by Christina Hardister on 8/7/17.
//  Copyright © 2017 Christina Hardister. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <time.h>
#import "AVEngine.h"
#import "FirstViewController.h"
#import "SecondViewController.h"
#import "TabBarViewController.h"



@interface AppDelegate : UIResponder <UIApplicationDelegate>

//@property (strong, nonatomic) AVEngine *mainEngine;

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic) float* recordedAudio;
@property (nonatomic) AVAudioPCMBuffer* paddedBuffer;
@property (nonatomic) int index;

// public fft properties
@property (nonatomic) int sigLength;
@property (nonatomic) float sampleRate;
@property (nonatomic) int arrSize;
@property (nonatomic) float* FFTmags;
@property (nonatomic) float* inverseMags;

@property (nonatomic) float* inputMeterValueLeft;
@property (nonatomic) float* inputMeterValueRight;


- (void) storeRecordedAudio:(float*)recorded;
- (void) storePaddedBuffer:(AVAudioPCMBuffer*)paddedBuffer;
- (void) storeInverseFilter:(COMPLEX_SPLIT) inverseFilter;
- (void) storeRecordedFreq:(COMPLEX_SPLIT) recordedFreq;


@end

