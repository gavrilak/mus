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

# pragma mark - work with data

- (void) deleteSong:(NSString*) ID {
    
    NSMutableArray* array = [[NSMutableArray alloc] init];
    array = [[DSSong  MR_findAllSortedBy:@"idSong"
                               ascending:YES
                           withPredicate:[NSPredicate predicateWithFormat:@"idSong contains[c] %@", ID]
                               inContext:[NSManagedObjectContext MR_defaultContext]] mutableCopy];
    if ( [array count] > 0) {
    
        DSSong* song = array[0];
        [self removeFile:song.link];
        [song MR_deleteEntity];
        
    }
    
}

- (void)removeFile:(NSString *) filePath
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSError *error;
    BOOL success = [fileManager removeItemAtPath:filePath error:&error];
    if (success) {
        NSLog(@"File deleted %@",filePath);
    }
    else
    {
        NSLog(@"Could not delete file -:%@ ",[error localizedDescription]);
    }
}

- (BOOL) existsSongInDownloads: (NSString*) ID {
    
    NSMutableArray* array = [[NSMutableArray alloc] init];
    array = [[DSSong  MR_findAllSortedBy:@"idSong"
                                    ascending:YES
                                withPredicate:[NSPredicate predicateWithFormat:@"idSong contains[c] %@", ID]
                                    inContext:[NSManagedObjectContext MR_defaultContext]] mutableCopy];
    if ( [array count] > 0) {
        return TRUE;
    } else {
        return FALSE;
    }

}

- (NSMutableArray*) getDownloads {
    
    NSMutableArray* array = [[NSMutableArray alloc] init];
    array = [[DSSong  MR_findAllSortedBy:@"name"
                               ascending:YES
                               inContext:[NSManagedObjectContext MR_defaultContext]] mutableCopy];
    
    return array;
}
- (void) addSongToDownloads: (PFObject *) object fileUrl:(NSString*)  Url {
    
    DSSong* song = [DSSong MR_createEntity];
    song.idSong = object.objectId;
    song.author = [object objectForKey:@"author"];
    song.name = [object objectForKey:@"name"];
    song.rate = [object objectForKey:@"rate"];
    song.link = Url;
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];

    
    
}
- (void) addLikeforSongID: (NSString*) ID{
    
    DSLikesSong* like = [DSLikesSong MR_createEntity];
    like.idSong = ID;
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    
}

- (BOOL) existsLikeForSongID:(NSString*) ID{
    
    
    NSMutableArray* array = [[NSMutableArray alloc] init];
    array = [[DSLikesSong  MR_findAllSortedBy:@"idSong"
                                ascending:YES
                            withPredicate:[NSPredicate predicateWithFormat:@"idSong contains[c] %@", ID]
                                inContext:[NSManagedObjectContext MR_defaultContext]] mutableCopy];
    if ( [array count] > 0) {
        return TRUE;
    } else {
        return FALSE;
    }
}
@end
