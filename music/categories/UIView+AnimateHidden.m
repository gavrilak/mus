//
//  UIView+AnimateHidden.m
//  music
//
//  Created by dima on 4/4/15.
//  Copyright (c) 2015 dima. All rights reserved.
//

#import "UIView+AnimateHidden.h"

@implementation UIView (AnimateHidden)

- (void)setHiddenAnimated:(BOOL)hide
                 editable:(BOOL)edit
                    delay:(NSTimeInterval)delay
                 duration:(NSTimeInterval)duration {
    [UIView animateWithDuration:duration
                          delay:delay
                        options:UIViewAnimationOptionAllowAnimatedContent
                     animations:^{
                         if (hide) {
                             self.alpha = 0;
                         } else {
                             self.alpha = 0;
                             self.hidden = NO; // We need this to see the animation 0 -> 1
                             if (edit){
                                 self.alpha = 1;
                             } else {
                                 self.alpha = 0.5;
                             }
                         }
                     } completion:^(BOOL finished) {
                         self.hidden = hide;
                     }];
    
}

- (void) setNotActiveWithDelay:(NSTimeInterval)delay
                  duration:(NSTimeInterval)duration
                         alhpa: (float) alpha {
    [UIView animateWithDuration:duration
                          delay:delay
                        options:UIViewAnimationOptionAllowAnimatedContent
                     animations:^{
                         
                             self.alpha = alpha;
                         
                     } completion:^(BOOL finished) {
                         
                     }];
}

@end
