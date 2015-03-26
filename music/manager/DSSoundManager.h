//
//  DSSoundManager.h
//  music
//
//  Created by dima on 3/23/15.
//  Copyright (c) 2015 dima. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>


@protocol DSSoundManagerDelegate

- (void) statusChanged:(BOOL) playStatus;

@end

@interface DSSoundManager : NSObject

@property (assign) id <DSSoundManagerDelegate> delegate;

+ (DSSoundManager *)sharedManager;

- (void) playSong:(NSData*) song;
- (void) pause;
- (float) getCurrentProgress;
@end
