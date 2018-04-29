//
//  AVEngine.m
//  RoomTuningCH
//
//  Created by Christina Hardister on 8/7/17.
//  Copyright © 2017 Christina Hardister. All rights reserved.
//

#import "AVEngine.h"

@interface AVEngine()
{
    COMPLEX_SPLIT FFTData; // Original Recorded Response
    COMPLEX_SPLIT FFTDataSim; // Simulated Response
    COMPLEX_SPLIT FFTDataComp; // divided by the FR of the sweep
    COMPLEX_SPLIT FFTDataConj;
    COMPLEX_SPLIT FFTDataMul; // fftData * its conj
    COMPLEX_SPLIT FFTRegDenom; // denomenator of regularization
    COMPLEX_SPLIT inverseFilterReg; // correction filter freq response
    COMPLEX_SPLIT FFTDataSweep; // sine sweep frequency response
    COMPLEX_SPLIT FFTNewSweep; // filtered new sine sweep
    COMPLEX compSweepAudioComplex; // time domain compensated sine sweep
}

// FFT properties
//@property (nonatomic) float* hammingWindow;
//@property (nonatomic) float* windowedBuffer;

@end

@implementation AVEngine

// default initializer
- (id)initWithBufferSize:(int)bufferSize
{
    self = [super init];
    if (self)
    {
        self.sampleRate = 44100.0;
        // set the fftsize
        self.nonPadded = self.sampleRate*22; // 970200
        // nextPow2 is 1048576
        self.sigLength = pow(2, 20);
        self.zeroPad = self.sigLength - self.nonPadded;
        self.arrSize = self.sigLength/2;

        
        // and alloc-init the magnitudes array
        self.FFTmags = (float*) calloc(self.sigLength/2, sizeof(float));
        self.inverseMags = (float*) calloc(self.sigLength/2, sizeof(float));
        self.newSineSweepMags = (float*) calloc(self.sigLength/2, sizeof(float));
        self.simulatedResponseMags = (float*) calloc(self.sigLength/2, sizeof(float));
        
        self.inputMeterValueLeft = (float*) malloc(sizeof(float));
        self.inputMeterValueRight = (float*) malloc(sizeof(float));
        
        self.index = 0;
        self.recordedAudio = (float*) calloc(self.sigLength,sizeof(float));
        self.sweepAudio = (float*) calloc(self.sigLength,sizeof(float));
        self.compSweepAudiof = (float*) calloc(self.sigLength,sizeof(float));
        
        // FFT Setup
        self.log2N          = log2f(self.sigLength/2);
        self.FFTSettings    = vDSP_create_fftsetup(self.log2N, kFFTRadix2);
        
        FFTData.realp    = (float *) malloc(sizeof(float) * self.sigLength/2);
        FFTData.imagp    = (float *) malloc(sizeof(float) * self.sigLength/2);
        
        FFTDataSweep.realp    = (float *) malloc(sizeof(float) * self.sigLength/2);
        FFTDataSweep.imagp    = (float *) malloc(sizeof(float) * self.sigLength/2);
        
        FFTDataComp.realp    = (float *) malloc(sizeof(float) * self.sigLength/2);
        FFTDataComp.imagp    = (float *) malloc(sizeof(float) * self.sigLength/2);
        
        FFTDataConj.realp    = (float *) malloc(sizeof(float) * self.sigLength/2);
        FFTDataConj.imagp    = (float *) malloc(sizeof(float) * self.sigLength/2);
        
        FFTDataMul.realp    = (float *) malloc(sizeof(float) * self.sigLength/2);
        FFTDataMul.imagp    = (float *) malloc(sizeof(float) * self.sigLength/2);
        
        FFTRegDenom.realp    = (float *) malloc(sizeof(float) * self.sigLength/2);
        FFTRegDenom.imagp    = (float *) malloc(sizeof(float) * self.sigLength/2);
        
        FFTDataSim.realp    = (float *) malloc(sizeof(float) * self.sigLength/2);
        FFTDataSim.imagp    = (float *) malloc(sizeof(float) * self.sigLength/2);
        
        inverseFilterReg.realp    = (float *) malloc(sizeof(float) * self.sigLength/2);
        inverseFilterReg.imagp    = (float *) malloc(sizeof(float) * self.sigLength/2);
        
        FFTNewSweep.realp    = (float *) malloc(sizeof(float) * self.sigLength/2);
        FFTNewSweep.imagp    = (float *) malloc(sizeof(float) * self.sigLength/2);

        
        // end init
    }
    
    return self;
}

- (AVAudioPCMBuffer*)fileIntoBuffer:(AVAudioFile *)audioFile
{
    AVAudioFormat* format = audioFile.processingFormat;
    AVAudioFrameCount capacity = (AVAudioFrameCount)audioFile.length;
    
    AVAudioPCMBuffer* tempBuff = [[AVAudioPCMBuffer alloc] initWithPCMFormat:format frameCapacity:capacity];
    [audioFile readIntoBuffer:tempBuff error:nil];
    
    AVAudioFrameCount paddedCapacity = (AVAudioFrameCount)self.sigLength;
    self.paddedBuff = [[AVAudioPCMBuffer alloc] initWithPCMFormat:format frameCapacity:paddedCapacity];
    
    // zero pad the buffer
    for (int t = 0; t < self.nonPadded; t++)
    {
        self.paddedBuff.floatChannelData[0][t] = tempBuff.floatChannelData[0][t];
    }
    
    for (int t = self.nonPadded+1; t < self.sigLength; t++)
    {
        self.paddedBuff.floatChannelData[0][t] = 0.0;
    }
    
    return tempBuff;

}

- (BOOL)setUpEngine:(AVAudioPCMBuffer*)playBuffer
{
    if(playBuffer)
    {
        // start up audio session
        AVAudioSession *session = [AVAudioSession sharedInstance];
        NSError *error = nil;
        BOOL success = NO;
        
        self.sampleRate = 44100.0;
        
        success = [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
        if(error || !success){
            NSLog(@"set Audio Session Category Fail :%@", error);
        }
        
        success = [session setPreferredSampleRate:self.sampleRate error:&error];
        if(error || !success){
            NSLog(@"set Preferred sample rate Fail :%@", error);
        }
        
        error = nil;
        success = [session setPreferredIOBufferDuration:4096/self.sampleRate error:&error];
        if(error || !success){
            NSLog(@"set Preferred IO Buffer Duration Fail :%@", error);
        }
        
        error = nil;
        success = [session setActive:YES error:&error];
        if(error || !success){
            NSLog(@"Activated Fail :%@", error);
        }
        
        // load engine
        self.engine = [[AVAudioEngine alloc] init];
        
        // assign implicit nodes
        self.input = self.engine.inputNode;
        self.output = self.engine.outputNode;
        self.mixer = self.engine.mainMixerNode;
        
        // load player and attach
        self.player = [[AVAudioPlayerNode alloc] init];
        [self.engine attachNode:self.player];

        // make connections
        [self.engine connect:self.player to:self.mixer format:playBuffer.format];
        
        // schedule player
        [self.player scheduleBuffer:playBuffer atTime:nil options:0 completionHandler:nil];
        
        return YES;
    }
    return NO;
}



- (void)startAudioPlayer
{
    [self.player play];
}

- (void)stopAudioPlayer
{
    [self.player stop];

}

- (void) getInputAudioBuffer
{
    [self.input installTapOnBus:0 bufferSize:4096 format:self.paddedBuff.format block:^(AVAudioPCMBuffer* buffer, AVAudioTime* when)
     {
         
         // read into input audio vector
         for (int i = 0; i<4096; i++, self.index++)
         {
             if (self.index == self.sigLength)
                 break;
             self.recordedAudio[self.index] = buffer.floatChannelData[0][i];
         }
     }];
    

}

- (void) stopInputAudio
{
    [self.input removeTapOnBus:(0)];
}

- (float) getLeftMeterValueDB
{
    return *self.inputMeterValueLeft;
}

- (float) getRightMeterValueDB
{
    return *self.inputMeterValueRight;
}


- (float*) getMagnitudeResponse
{
    // Converting data into split complex form
    vDSP_ctoz((COMPLEX *) self.recordedAudio, 2, &(FFTData), 1, self.sigLength/2);
    
    // Doing the FFT
    vDSP_fft_zrip(self.FFTSettings, &(FFTData), 1, self.log2N, kFFTDirection_Forward);
    
    
    // read original sine sweep data from buffer
    for (int i = 0; i < self.sigLength; i++)
    {
        self.sweepAudio[i] = self.paddedBuff.floatChannelData[0][i];
    }
    
    // get sine sweep frequency response
    // Converting data into split complex form for sweep audio
    vDSP_ctoz((COMPLEX *) self.sweepAudio, 2, &(FFTDataSweep), 1, self.sigLength/2);
    
    // Doing the FFT for the sine sweep
    vDSP_fft_zrip(self.FFTSettings, &(FFTDataSweep), 1, self.log2N, kFFTDirection_Forward);

    // divide freq response by freq response of sine sweep
    vDSP_zvdiv(&(FFTDataSweep), 1, &(FFTData), 1, &(FFTDataComp), 1, self.sigLength/2);

    // get magnitude response
    vDSP_zvabs(&(FFTDataComp), 1, self.FFTmags, 1, self.sigLength/2);
    
    return _FFTmags;
}


- (float*) getInverseFilter
{

    // get window of applied regularization
    
    float regWin [524288] = { };
    
    float betaHigh_dB = -40.0;
    float betaLow_dB = -100.0;
    float ArThreshLow_Hz = 50.0;
    float ArThreshHigh_Hz = 18000.0;
 
    float betaHigh = powf(10,betaHigh_dB/20.0);
    float betaLow = powf(10,betaLow_dB/20.0);
    int ArThreshLow = floor(ArThreshLow_Hz*self.sigLength/44100);
    int ArThreshHigh = floor(ArThreshHigh_Hz*self.sigLength/44100);
    
    for (int p = 0; p < ArThreshLow; p++)
    {
        regWin[p] = betaHigh;
    }
    for (int r = ArThreshLow+1; r < ArThreshHigh; r++)
    {
        regWin[r] = betaLow;
    }
    for (int q = ArThreshHigh+1; q < self.sigLength/2; q++)
    {
        regWin[q] = betaHigh;
    }
    
    // Apply regularisation
    
    // get conjugate
    vDSP_zvconj(&(FFTDataComp), 1, &(FFTDataConj), 1, self.sigLength/2);
    
    // get denominator - conj(A)*B = C
    vDSP_zvcmul(&(FFTDataComp), 1, &(FFTDataComp), 1, &(FFTDataMul), 1, self.sigLength/2);
    
    // add Ar window
    vDSP_zrvadd(&(FFTDataMul), 1, regWin, 1, &(FFTRegDenom), 1, self.sigLength/2);
    
    // get whole regularized filter
    vDSP_zvdiv(&(FFTRegDenom), 1, &(FFTDataConj), 1, &(inverseFilterReg), 1, self.sigLength/2);
    
    // get magnitude response
    vDSP_zvabs(&(inverseFilterReg), 1, self.inverseMags, 1, self.sigLength/2);
    
    return _inverseMags;

}

- (float*) getSimulatedCorrectedResponse
{
    
    // simulated response = recorded in * inverse filter
    vDSP_zvmul(&(FFTData), 1, &(inverseFilterReg), 1, &(FFTDataSim), 1, self.sigLength/2, 1);
    
    // divide freq response by freq response of sine sweep
    vDSP_zvdiv(&(FFTDataSweep), 1, &(FFTDataSim), 1, &(FFTDataSim), 1, self.sigLength/2);
    
    // get magnitude response
    vDSP_zvabs(&(FFTDataSim), 1, self.simulatedResponseMags, 1, self.sigLength/2);

    return _simulatedResponseMags;
}

- (AVAudioPCMBuffer*)getNewSineSweep
{
    
     // compensated sine sweep = original sweep * inverse filter
     vDSP_zvmul(&(FFTDataSweep), 1, &(inverseFilterReg), 1, &(FFTNewSweep), 1, self.sigLength/2, 1);
     
     // get magnitude response
     vDSP_zvabs(&(FFTNewSweep), 1, self.newSineSweepMags, 1, self.sigLength/2);
     
     // Do IFFT to get sine sweep audio
     vDSP_fft_zrip(self.FFTSettings, &(FFTNewSweep), 1, self.log2N, kFFTDirection_Inverse);
     
     // Convert from split complex to interleaved - ?? do I need to do this?
     //vDSP_ztoc(&(FFTNewSweep), 1, &(compSweepAudioComplex), 2, self.sigLength/2);
     
     // do the scaling by 1/length
     float scale = 1.0/self.sigLength;
     vDSP_vsmul(FFTNewSweep.realp, 1, &scale, FFTNewSweep.realp, 1, self.sigLength/2);
     vDSP_vsmul(FFTNewSweep.imagp, 1, &scale, FFTNewSweep.imagp, 1, self.sigLength/2);
    
     AVAudioFrameCount capacity = (AVAudioFrameCount)self.sigLength;
     self.compSweepAudio = [[AVAudioPCMBuffer alloc] initWithPCMFormat:self.paddedBuff.format frameCapacity:capacity];
     
     // read real part of ifft into array
     for (int k = 0; k < self.sigLength; k++)
     {
     // from complex split to avAudio PCM Buffer
     self.compSweepAudio.floatChannelData[0][k] = FFTNewSweep.realp[k];
     // from PCM Buffer to float*
     self.compSweepAudiof[k] = self.compSweepAudio.floatChannelData[0][k];
     }

    return _compSweepAudio;

}



/*
 - (void) doMetering
 {
 
 if (buffer == NULL)
 return;
 
 float avg = 0.0;
 for (int i=0; i<self.N; i++)
 {
 float linear = buffer.floatChannelData[0][i];
 linear = fabsf(linear);
 avg = avg + powf(linear, 2);
 }
 avg = avg/self.N;
 float rms = sqrtf(avg);
 float db = 20.0*log10f(rms);
 *self.inputMeterValueLeft = db;
 *self.inputMeterValueRight = db;
 }
 */


























@end

