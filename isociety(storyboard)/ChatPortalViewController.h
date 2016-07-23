//
//  ChatPortalViewController.h
//  Seik
//
//  Created by Gavin on 10/26/14.
//  Copyright (c) 2014 Seik, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "Constant.h"

@interface ChatPortalViewController : UIViewController

@property (nonatomic, copy) NSString *titleStr;
@property (nonatomic, copy) NSString *chatRoomID;
@property (nonatomic, strong) PFUser *user;
@property (nonatomic, strong) PFObject *object;

@end
