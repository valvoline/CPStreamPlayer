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

@property(nonatomic, weak) id delegate;
@property(nonatomic, strong) NSString *artistTitle;
@property(nonatomic, strong) NSString *songTitle;
@property(nonatomic, strong) NSString *separatorString;
@property(nonatomic, strong) NSString *channelTitle;

- (void)startPlay;
- (id)initWithStream:(NSString *)aStream;

@end

@protocol CPStreamPlayerDelegate

@optional
- (void)CPStreamPlayerDidStarted:(CPStreamPlayer *)actPlayer;
- (void)CPStreamPlayerDidPaused:(CPStreamPlayer *)actPlayer;
- (void)CPStreamPlayerMetadataDidUpdated:(CPStreamPlayer *)actPlayer;

@end
