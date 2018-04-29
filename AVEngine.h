//
//  AVEngine.h
//  RoomTuningCH
//
//  Created by Christina Hardister on 8/7/17.
//  Copyright © 2017 Christina Hardister. All rights reserved.
//

//#ifndef AVEngine_h
//#define AVEngine_h

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <Accelerate/Accelerate.h>
#import <time.h>


@interface AVEngine : NSObject


// default initializer
- (id)initWithBufferSize:(int) bufferSize;

- (BOOL)setUpEngine:(AVAudioPCMBuffer*)playBuffer;

// start/stop functions; if you have multuple players you need to index them
- (void)startAudioPlayer;
- (void)stopAudioPlayer;

- (float)getLeftMeterValueDB;
- (float)getRightMeterValueDB;

- (AVAudioPCMBuffer*)fileIntoBuffer:(AVAudioFile*)audioFile;

- (void)getInputAudioBuffer;
- (void)stopInputAudio;

- (float*)getMagnitudeResponse;
- (float*)getInverseFilter;
- (float*)getSimulatedCorrectedResponse;
- (AVAudioPCMBuffer*)getNewSineSweep;


// engine properties
@property (strong,nonatomic) AVAudioEngine* engine;
@property (strong,nonatomic) AVAudioPlayerNode* player;
@property (strong,nonatomic) AVAudioMixerNode* mixer;
@property (strong,nonatomic) AVAudioInputNode* input;
@property (strong,nonatomic) AVAudioOutputNode* output;
@property (strong,nonatomic) AVAudioFile* sweep;

// used for reading in audio files
@property (nonatomic) float* recordedAudio;
@property (nonatomic) float* sweepAudio;
@property (nonatomic) float* compSweepAudiof;
@property (nonatomic) int index;
//@property (strong,nonatomic) AVAudioPCMBuffer *buff;
@property (strong,nonatomic) AVAudioPCMBuffer *paddedBuff;
@property (strong,nonatomic) AVAudioPCMBuffer *compSweepAudio;

// public fft properties
@property (nonatomic) UInt32 log2N;
@property (nonatomic) FFTSetup FFTSettings;

@property (nonatomic) int sigLength;
@property (nonatomic) int zeroPad;
@property (nonatomic) int nonPadded;
@property (nonatomic) float sampleRate;
@property (nonatomic) int arrSize;
@property (nonatomic) float* FFTmags;
@property (nonatomic) float* inverseMags;
@property (nonatomic) float* newSineSweepMags;
@property (nonatomic) float* simulatedResponseMags;

@property (nonatomic) float* inputMeterValueLeft;
@property (nonatomic) float* inputMeterValueRight;


@end



