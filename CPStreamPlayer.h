//
//  CPStreamPlayer.h
//  CPStreamPlayer
//
//  Created by Costantino Pistagna on 2/20/12.
//  Copyright (c) 2012 iPhoneSmartApps.org - All rights reserved.
//

#import <UIKit/UIKit.h>

@class AVPlayer;
@class AVPlayerItem;

@interface CPStreamPlayer : NSObject {
    AVPlayer *player;
    NSString *streamAddress;
    BOOL isPlaying;
}

@property(nonatomic, assign) id delegate;
@property(nonatomic, retain) NSString *artistTitle;
@property(nonatomic, retain) NSString *songTitle;
@property(nonatomic, retain) NSString *separatorString;
@property(nonatomic, retain) NSString *channelTitle;

- (void)startPlay;
- (id)initWithStream:(NSString *)aStream;

@end

@protocol CPStreamPlayerDelegate

@optional
- (void)CPStreamPlayerDidStarted:(CPStreamPlayer *)actPlayer;
- (void)CPStreamPlayerDidPaused:(CPStreamPlayer *)actPlayer;
- (void)CPStreamPlayerMetadataDidUpdated:(CPStreamPlayer *)actPlayer;

@end
