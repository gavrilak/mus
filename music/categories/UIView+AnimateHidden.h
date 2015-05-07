//
//  UIView+AnimateHidden.h
//  music
//
//  Created by dima on 4/4/15.
//  Copyright (c) 2015 dima. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (AnimateHidden)

- (void)setHiddenAnimated:(BOOL)hide
                 editable:(BOOL) edit
                    delay:(NSTimeInterval)delay
                 duration:(NSTimeInterval)duration;

- (void) setNotActiveWithDelay:(NSTimeInterval)delay
                      duration:(NSTimeInterval)duration
                         alhpa:(float) alpha;
@end
