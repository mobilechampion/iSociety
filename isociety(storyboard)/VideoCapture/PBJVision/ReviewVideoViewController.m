//
//  PBJViewController.m
//  Vision
//
//  Created by Patrick Piemonte on 7/23/13.
//  Copyright (c) 2013-present, Patrick Piemonte, http://patrickpiemonte.com
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of
//  this software and associated documentation files (the "Software"), to deal in
//  the Software without restriction, including without limitation the rights to
//  use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
//  the Software, and to permit persons to whom the Software is furnished to do so,
//  subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
//  FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
//  COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
//  IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
//  CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "ReviewVideoViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <GLKit/GLKit.h>
#import "UIView+Toast.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>


@interface ReviewVideoViewController()

- (IBAction)close:(id)sender;

@end

@implementation ReviewVideoViewController
{
    // bottom dock
    UIView *captureDock;
    float *margin;
}

#pragma mark - view lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

//    self.view.backgroundColor = [UIColor colorWithRed:40/255.0 green:188/255.0 blue:186/255.0 alpha:1.0];//[UIColor blackColor];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    
    [PBJVision sharedInstance].videoFrameRate = 30;
    [PBJVision sharedInstance].videoBitRate = PBJVideoBitRate480X360;

    
    // KJM
    captureDock = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.bounds) - 150.0f, CGRectGetWidth(self.view.bounds), 100.0f)];
    
    captureDock.backgroundColor = [UIColor clearColor];
    captureDock.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview:captureDock];
    
    // KJM Play/Pause Button
    float buttonWidth = 70.0;
    playPauseButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [playPauseButton setImage:[UIImage imageNamed:@"PlayButton-40x40.png"] forState:UIControlStateNormal];
    playPauseButton.frame = CGRectMake(135.0, 180.0, buttonWidth, buttonWidth);//width and height should be same value
    playPauseButton.clipsToBounds = YES;
    playPauseButton.layer.cornerRadius = buttonWidth / 2;//half of the width
    playPauseButton.layer.borderWidth=2.0f;
    CGRect buttonFrame = playPauseButton.frame;
    buttonFrame.origin = CGPointMake((CGRectGetWidth(self.view.bounds) * 0.5f) - (buttonWidth * 0.5f), (captureDock.frame.size.height - buttonWidth) / 2);
    playPauseButton.frame = buttonFrame;
    [playPauseButton addTarget:self action:@selector(handlePlayPauseButton:) forControlEvents:UIControlEventTouchUpInside];
    [captureDock addSubview:playPauseButton];
    
    // RETAKE button
    retakeButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [retakeButton setTitle:@"Retake" forState:UIControlStateNormal];
    [retakeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    retakeButton.titleLabel.font = [UIFont systemFontOfSize:18];
    [retakeButton sizeToFit];
    CGRect retakeFrame = retakeButton.frame;
    retakeFrame.origin = CGPointMake(20.0f, (captureDock.frame.size.height - retakeButton.frame.size.height) / 2);
    retakeButton.frame = retakeFrame;
    [retakeButton addTarget:self action:@selector(handleRetakeButton:) forControlEvents:UIControlEventTouchUpInside];
    [captureDock addSubview:retakeButton];
    
    // PUBLISH button
    publishButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [publishButton setTitle:@"Publish" forState:UIControlStateNormal];
    [publishButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    publishButton.titleLabel.font = [UIFont systemFontOfSize:18];
    [publishButton sizeToFit];
    CGRect publishFrame = publishButton.frame;
    publishFrame.origin = CGPointMake(captureDock.frame.size.width - 20.0f - publishButton.frame.size.width, (captureDock.frame.size.height - publishButton.frame.size.height) / 2);
    publishButton.frame = publishFrame;
    [publishButton addTarget:self action:@selector(handlePublishButton:) forControlEvents:UIControlEventTouchUpInside];
    [captureDock addSubview:publishButton];
    
    self.navigationController.navigationBarHidden = YES;

    // Movie Player
    NSURL *url = [NSURL fileURLWithPath:self.videoPath isDirectory:NO];
    self.moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:url];
    [self.moviePlayer setMovieSourceType:MPMovieSourceTypeFile];
    [self.moviePlayer prepareToPlay];
    self.moviePlayer.view.frame = CGRectMake(0, 60.0f, CGRectGetWidth(self.view.frame), CGRectGetWidth(self.view.frame));
    self.moviePlayer.shouldAutoplay = NO;
    self.moviePlayer.controlStyle = MPMovieControlStyleNone;
    [self.view addSubview:self.moviePlayer.view];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackDidFinish:) name:MPMoviePlayerPlaybackDidFinishNotification object:self.moviePlayer];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:self.moviePlayer];
    [self.moviePlayer stop];

}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void) playbackDidFinish:(NSNotification*)notification {
    int reason = [[[notification userInfo] valueForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey] intValue];
    if (reason == MPMovieFinishReasonPlaybackEnded) {
        [playPauseButton setImage:[UIImage imageNamed:@"PlayButton-40x40.png"] forState:UIControlStateNormal];

    }else if (reason == MPMovieFinishReasonUserExited) {
        //user hit the done button
    }else if (reason == MPMovieFinishReasonPlaybackError) {
        //error
    }
}

#pragma mark - UIButton
- (void)handlePlayPauseButton:(UIButton *)button
{
    if (!self.moviePlayer.playbackState || self.moviePlayer.playbackState == MPMoviePlaybackStatePaused)
    {
        [self.moviePlayer play];
        [playPauseButton setImage:[UIImage imageNamed:@"PauseButton-40x40.png"] forState:UIControlStateNormal];

    }
    else
    {
        [self.moviePlayer pause];
        [playPauseButton setImage:[UIImage imageNamed:@"PlayButton-40x40.png"] forState:UIControlStateNormal];
    }
}

- (void)handleRetakeButton:(UIButton *)button
{
    [self.delegate retakeVideo];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)handlePublishButton:(UIButton *)button
{

}

@end
