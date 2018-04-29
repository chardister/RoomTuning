//
//  AudioFFTView.h
//  RoomTuningCH
//
//  Created by Christina Hardister on 8/7/17.
//  Copyright © 2017 Christina Hardister. All rights reserved.
//


#import <UIKit/UIKit.h>

@interface AudioFFTView : UIView

@property (nonatomic) float* FFTmags;
@property (nonatomic) UIColor* plotColor;
@property (nonatomic) int fftSize;



@end


