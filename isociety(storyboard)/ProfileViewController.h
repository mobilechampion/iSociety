//
//  ProfileViewController.h
//  Seik
//
//  Created by Gavin on 10/26/14.
//  Copyright (c) 2014 Seik, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface ProfileViewController : UIViewController <UIGestureRecognizerDelegate>

@property (strong, nonatomic) PFUser *otherUser;
@property (strong, nonatomic) IBOutlet UIButton *requestButton;
@property (strong, nonatomic) IBOutlet UIButton *sendButton;

@property CGPoint from;
@property CGPoint to;
@property BOOL ignoreDrag;

@end
