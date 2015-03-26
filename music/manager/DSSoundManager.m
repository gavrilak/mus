//
//  DSSoundManager.m
//  music
//
//  Created by dima on 3/23/15.
//  Copyright (c) 2015 dima. All rights reserved.
//

#import "DSSoundManager.h"


@interface DSSoundManager () <AVAudioPlayerDelegate>

@property (strong, nonatomic) AVAudioSession *audioSession;
@property (strong, nonatomic) AVAudioPlayer *backgroundMusicPlayer;


@end



@implementation DSSoundManager

+ (DSSoundManager *)sharedManager {
    
    static DSSoundManager *manager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSError *setCategoryError = nil;
        manager = [[DSSoundManager alloc]init];
        manager.audioSession = [AVAudioSession sharedInstance];
        [manager.audioSession setCategory:AVAudioSessionCategoryPlayback error:&setCategoryError];

    });
    
    return manager;
}

- (void) playSong:(NSData*) song {
     NSError *playError = nil;
     self.backgroundMusicPlayer = [[AVAudioPlayer alloc] initWithData:song  error:&playError];
     self.backgroundMusicPlayer.delegate = self;  // We need this so we can restart after interruptions
     self.backgroundMusicPlayer.numberOfLoops = -1;	// Negative number means loop forever
    [self.backgroundMusicPlayer play];
    [self.delegate statusChanged:YES];
}

- (void) pause {
    
    [self.backgroundMusicPlayer pause];
    [self.delegate statusChanged:NO];
    
}
- (void) play {
    
    [self.backgroundMusicPlayer play];
    [self.delegate statusChanged:YES];
    
}
- (BOOL) isPlaying {
    
    return self.backgroundMusicPlayer.isPlaying;
    
}

- (float) getCurrentProgress {
  
    return self.backgroundMusicPlayer.currentTime / self.backgroundMusicPlayer.duration;
}

#pragma mark - AVAudioPlayerDelegate methods

- (void) audioPlayerBeginInterruption: (AVAudioPlayer *) player {
    
    [self.delegate statusChanged:NO];
   
}



@end
