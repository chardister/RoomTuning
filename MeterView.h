//
//  MeterView.h
//  RoomTuningCH
//
//  Created by Christina Hardister on 8/7/17.
//  Copyright © 2017 Christina Hardister. All rights reserved.
//

#ifndef MeterView_h
#define MeterView_h

#import <UIKit/UIKit.h>


@interface MeterView : UIView


- (void)updateMeter:(float)fdB;
- (void)clearMeter;

@end

#endif /* MeterView_h */
