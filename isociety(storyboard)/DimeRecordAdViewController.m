//
//  DimeRecordAdViewController.m
//  Seik
//
//  Created by Gavin on 10/26/14.
//  Copyright (c) 2014 Seik, Inc. All rights reserved.
//

#import "DimeRecordAdViewController.h"
#import "DimeReviewVideoViewController.h"

#define VIDEO_LENGTH 20

@interface DimeRecordAdViewController ()

@end

@implementation DimeRecordAdViewController
- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Set the maximum recorded video length
    [PBJVision sharedInstance].maximumCaptureDuration = CMTimeMake(VIDEO_LENGTH, 1);
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [super prepareForSegue:segue sender:self];
    
    if ([segue.identifier isEqualToString:@"RecordToReview"]) {
        DimeReviewVideoViewController *rvc = segue.destinationViewController;
        rvc.videoPath = self.videoPath;
    }
}

@end
