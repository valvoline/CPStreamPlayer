//
//  CPStreamPlayer.m
//  CPStreamPlayer
//
//  Created by Costantino Pistagna on 2/20/12.
//  Copyright (c) 2012 iPhoneSmartApps.org - All rights reserved.
//

#import "CPStreamPlayer.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <MediaPlayer/MediaPlayer.h>

@implementation CPStreamPlayer
@synthesize artistTitle, songTitle, separatorString, delegate, channelTitle;


- (id)initWithStream:(NSString *)aStream {
    if (self = [super init]) {
        isPlaying = FALSE;
        separatorString = @" - ";
        
        //Set AudioSession
        NSError *sessionError = nil;
        [[AVAudioSession sharedInstance] setDelegate:self];
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&sessionError];
        
        //Changing the default output audio route
        UInt32 doChangeDefaultRoute = 1;
        AudioSessionSetProperty(kAudioSessionProperty_OverrideCategoryDefaultToSpeaker, sizeof(doChangeDefaultRoute), &doChangeDefaultRoute);

        AudioSessionSetActive(YES);

        player = [[AVPlayer alloc] init];
        player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
        self.songTitle = @"";
        streamAddress = [[NSString alloc] initWithString:aStream];
    }
    return self;
}

- (void)dealloc {
    [separatorString release];
    [streamAddress release];
    [player release];
    [artistTitle release];
    [songTitle release];
    [super dealloc];
}

#pragma mark -
#pragma mark Accessor Methods

- (BOOL)isPlaying {
    return player.currentItem.asset.isPlayable;
}

- (void)setArtistTitle:(NSString *)aString {
    artistTitle = [[NSString stringWithString:aString] retain];
}

- (void)setSongTitle:(NSString *)aString {
    songTitle = [[NSString stringWithString:aString] retain];
}

- (NSString *)channelTitle {
    return [NSString stringWithString:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"]];
}

- (void)startPlay {
    if(!player.currentItem.asset.isPlayable) {
        isPlaying = TRUE;
        self.artistTitle = @"Buffering";
        self.songTitle = @"";
        [player.currentItem.asset removeObserver:self forKeyPath:@"playable"];
        [player.currentItem removeObserver:self forKeyPath:@"timedMetadata"];
        [player.currentItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
        [player.currentItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
        [player.currentItem removeObserver:self forKeyPath:@"playbackBufferFull"];

        NSURL *streamUrl = [NSURL URLWithString:streamAddress];
        AVPlayerItem *anItem = [AVPlayerItem playerItemWithURL:streamUrl];
        [anItem addObserver:self forKeyPath:@"timedMetadata" options:NSKeyValueObservingOptionNew context:NULL];
        [anItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
        [anItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
        [anItem addObserver:self forKeyPath:@"playbackBufferFull" options:NSKeyValueObservingOptionNew context:nil];
        [anItem.asset addObserver:self forKeyPath:@"playable" options:NSKeyValueObservingOptionNew context:nil];
        
        [player replaceCurrentItemWithPlayerItem:anItem];
        [player play];
        if([delegate respondsToSelector:@selector(CPStreamPlayerDidStarted:)]) {
            [delegate performSelector:@selector(CPStreamPlayerDidStarted:) withObject:self];
        }
    } else {
        isPlaying = FALSE;
        self.artistTitle = @"";
        self.songTitle = @"";
        [player pause];
        if([delegate respondsToSelector:@selector(CPStreamPlayerDidPaused:)]) {
            [delegate performSelector:@selector(CPStreamPlayerDidPaused:) withObject:self];
        }
    }
    [self setGlobalmetadata];
}

#pragma mark -
#pragma mark AVAudioSession Delegate
/* the interruption is over */
- (void)endInterruptionWithFlags:(NSUInteger)flags {
    if(isPlaying) 
        [player play]; 
}

/* something has caused your audio session to be interrupted */
- (void)beginInterruption {
    NSLog(@"begin interruption");
}

#pragma mark -
#pragma mark KVO tracks and player status
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    NSLog(@"keypath: %@, change: %@", keyPath, change);

    if([keyPath rangeOfString:@"playbackBufferEmpty"].location != NSNotFound && self.isPlaying) {
        [player pause];
        if([delegate respondsToSelector:@selector(CPStreamPlayerDidPaused:)]) {
            [delegate performSelector:@selector(CPStreamPlayerDidPaused:) withObject:self];
        }
    }
    if([keyPath rangeOfString:@"playbackLikelyToKeepUp"].location != NSNotFound) {
        [player play];
        if([delegate respondsToSelector:@selector(CPStreamPlayerDidStarted:)]) {
            [delegate performSelector:@selector(CPStreamPlayerDidStarted:) withObject:self];
        }
    }
    else if([keyPath rangeOfString:@"timedMetadata"].location != NSNotFound) {
        if([[change objectForKey:@"new"] isKindOfClass:[NSArray class]]) {
            NSArray *anArray = [change objectForKey:@"new"];
            if([anArray count] > 0) {
                AVMetadataItem *firstItem = [anArray objectAtIndex:0];
                NSString *title = [firstItem stringValue];
                NSArray *components = [title componentsSeparatedByString:separatorString];
                if([components count] > 1) {
                    self.artistTitle = [components objectAtIndex:0];
                    NSMutableString *song = [[NSMutableString alloc] init];
                    for(int i=1;i<[components count];i++) {
                        [song appendString:[components objectAtIndex:i]];
                    }
                    self.songTitle = [NSString stringWithString:song];
                    [song release];
                }
                [self setGlobalmetadata];
            }
        }
    }
}

- (void)setGlobalmetadata {
    NSMutableDictionary *metadataNowPlaying = [[NSMutableDictionary alloc] init];
    
    [metadataNowPlaying setObject:[NSString stringWithString:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"]] 
                           forKey:MPMediaItemPropertyAlbumTitle];
    
    [metadataNowPlaying setObject:[NSString stringWithString:self.artistTitle] 
                           forKey:MPMediaItemPropertyArtist];
    
    [metadataNowPlaying setObject:[NSString stringWithString:self.songTitle] 
                           forKey:MPMediaItemPropertyTitle];
    
    [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:metadataNowPlaying];
    [metadataNowPlaying release];

    if([delegate respondsToSelector:@selector(CPStreamPlayerMetadataDidUpdated:)]) {
        [delegate performSelector:@selector(CPStreamPlayerMetadataDidUpdated:) withObject:self];
    }
}

@end
