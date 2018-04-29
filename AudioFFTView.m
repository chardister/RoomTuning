//
//  AudioFFTView.m
//  RoomTuningCH
//
//  Created by Christina Hardister on 8/7/17.
//  Copyright © 2017 Christina Hardister. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AudioFFTView.h"

@interface AudioFFTView()


@property (readonly) Float32 minFFTValue;
@property CGContextRef context;

@end

@implementation AudioFFTView


// initialize the AudioWaveView
- (id)initWithCoder:(NSCoder *)aDecoder
{
    // if the superclass initializes properly
    if (self = [super initWithCoder:aDecoder])
    {
        // set the minimum value (0 on the waveform)
        _minFFTValue = -80;
        
        self.plotColor = [[UIColor alloc] initWithRed:0.1 green:0.1 blue:0.8 alpha:0.9];
        
    }
    
    return self;
}

- (void)setFftSize:(int)fftSize
{
    _fftSize = fftSize;
    
    
    // if already allocated, remove old memory
    if(self.FFTmags != NULL) {
        NSLog(@"freeing FFTMags");
        free(self.FFTmags);
    }
    
    // allocate space
    self.FFTmags =  (float *) calloc(self.fftSize, sizeof(float));
    
}



// draws the AudioWaveView Histogram
- (void)drawRect:(CGRect)rect
{
    if (self.FFTmags != nil)
    {
        // get the current device context
        self.context = UIGraphicsGetCurrentContext();
        
        
        // experiment with different widths .... experiment
        CGContextSetLineWidth(self.context, 1.0);
        
        // get our width and height
        CGSize size = self.frame.size;
        
        ///you draw
        
        //get a scale factor from fft bin to pixel
        float freqScf = self.fftSize/size.width;
        
        // create some variables to hold points
        float lineHeight=0, prevLineHeight=0;
        
        // draw a line for each point in rmsPowerLevels
        for (int i = 1; i < size.width; i++)
        {
            // get nearest fft bin
            int j = round(freqScf*i);
            
            // grab the magnitude from that bin
            float val = self.FFTmags[j];
            
            // get next power level
            float newPower =  20*log10f(val);//-12;
            
            // clamp at -minWaveValue: this is y = 0, right on the x-axis
            newPower = (newPower < self.minFFTValue) ? self.minFFTValue : newPower;
            // I don't want to clamp everything over 0dB to 0
            //newPower = (newPower >0) ? 0 : newPower;
            
            // check for a nan
            if (isnan(newPower))
                newPower = self.minFFTValue;
            
            // set 0 dB line at exact middle of graph
            float zeroDB = size.height*0.5;
            lineHeight = (1-(newPower/self.minFFTValue)) * zeroDB;
            
            CGContextMoveToPoint(self.context, i-1, size.height - prevLineHeight);
            
            // add a line to a point below the middle of the view
            CGContextAddLineToPoint(self.context, i , size.height - lineHeight);
            
            // set the color for this line segment
            CGContextSetStrokeColorWithColor(self.context, self.plotColor.CGColor);
            
            // stroke
            CGContextStrokePath(self.context);
            
            prevLineHeight = lineHeight;
        }
        
    }
}



@end
