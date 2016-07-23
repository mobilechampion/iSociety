//
//  FriendsController.h
//  Seik
//
//  Created by Gavin on 10/26/14.
//  Copyright (c) 2014 Seik, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface FriendsController : UIViewController<UITableViewDelegate,UITableViewDataSource, UISearchControllerDelegate, UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UIView *usernameLabelParent;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (strong, nonatomic) IBOutlet UIGestureRecognizer *usernameLabelGestureRecognizer;

@property CGPoint from;
@property CGPoint to;
@property BOOL ignoreDrag;
@property (nonatomic, retain) NSString *keyString;

@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSString *usernameLabelOriginalText;

@end