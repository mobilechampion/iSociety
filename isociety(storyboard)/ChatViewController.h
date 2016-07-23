//
//  ChatViewController.h
//  Seik
//
//  Created by Gavin on 10/26/14.
//  Copyright (c) 2014 Seik, Inc. All rights reserved.
//

#import "JSQMessagesViewController.h"
#import <Parse/Parse.h>
@interface ChatViewController : JSQMessagesViewController

@property (nonatomic, copy) NSString *titleStr;
@property (nonatomic, copy) NSString *chatRoomID;
@property (nonatomic, strong) PFUser *user;
@end
