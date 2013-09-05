//
//  MainViewController.m
//  CPPlayerTest
//
//  Created by Costantino Pistagna on 05/05/12.
//  Copyright (c) 2012 iPhoneSmartApps.org. All rights reserved.
//

#import "MainViewController.h"

@interface MainViewController () {
    IBOutlet UIButton *aButton;
    IBOutlet UILabel *songTitle;
    IBOutlet UILabel *songArtist;
    IBOutlet UILabel *channel;
    
    CPStreamPlayer *streamPlayer;
}

- (IBAction)buttonDidPressed:(id)sender;

@end

@implementation MainViewController

- (void)dealloc {
    [streamPlayer release];
    [super dealloc];
}

/* the following two methods are required in order to use remote control functionality */
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];
}

/* required for remote control */
- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    streamPlayer = [[CPStreamPlayer alloc] initWithStream:@"http://voxsc1.somafm.com:3000"];
    [streamPlayer setDelegate:self];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (IBAction)buttonDidPressed:(id)sender {
    [streamPlayer startPlay];
}

#pragma mark - 
#pragma mark Remote Control Event Handling
- (void)remoteControlReceivedWithEvent: (UIEvent *) receivedEvent {
    if (receivedEvent.type == UIEventTypeRemoteControl) {
        NSLog(@"subtype: %d", receivedEvent.subtype);
        switch (receivedEvent.subtype) {
            case UIEventSubtypeRemoteControlPlay:
                [streamPlayer startPlay];
                break;
            case UIEventSubtypeRemoteControlPause:
                [streamPlayer startPlay];
                break;
            case UIEventSubtypeRemoteControlStop:
                [streamPlayer startPlay];
                break;
            case UIEventSubtypeRemoteControlTogglePlayPause:
                [streamPlayer startPlay];
                break;
            default:
                break;
        }
    }
}

#pragma mark -
#pragma mark CPStreamPlayerDelegate
- (void)CPStreamPlayerDidStarted:(CPStreamPlayer *)actPlayer {
    NSLog(@"CPStreamPlayerDidStarted");
    [aButton setTitle:@"Buffering" forState:UIControlStateNormal];
}
- (void)CPStreamPlayerDidPaused:(CPStreamPlayer *)actPlayer {
    NSLog(@"CPStreamPlayerDidPaused");
    [aButton setTitle:@"Play" forState:UIControlStateNormal];
}
- (void)CPStreamPlayerMetadataDidUpdated:(CPStreamPlayer *)actPlayer {
    NSLog(@"songTitle: %@\n, songArtist: %@", actPlayer.songTitle, actPlayer.artistTitle);
    [aButton setTitle:@"Stop" forState:UIControlStateNormal];
    songTitle.text = actPlayer.songTitle;
    songArtist.text = actPlayer.artistTitle;
    channel.text = actPlayer.channelTitle;
}

@end
