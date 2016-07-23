//
//  Helper.m
//  Seik
//
//  Created by Gavin on 10/26/14.
//  Copyright (c) 2014 Seik, Inc. All rights reserved.
//

#import "Helper.h"
#import <Parse/Parse.h>

@implementation Helper

/*
 * Notification to user with a message through Parse SDK
 */
+ (void) sendPushNotificationToUser:(PFUser*) user withMessage :(NSString*) msg {
    NSDictionary* dic = @{@"alert" : msg,
                          @"sound" : @"default",
                          @"badge" : @"Increment"};
    PFQuery* query = [PFInstallation query];
    [query whereKey:@"User" equalTo:user];
    PFPush* push = [[PFPush alloc] init];
    [push setQuery:query];
    [push setData:dic];
    [push sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"Delivery notification successfully!!");
        } else {
            NSLog(@"Delivery notification failure!!");
        }
    }];
}

+ (void) sendMessageNotificationToUser:(PFUser*) user withMessage :(NSString*) msg {
    NSDictionary* dic = @{@"alert" : msg,
                          @"sound" : @"default",
                          @"NotificationType" : @"Message",
                          @"UserChat" : [PFUser currentUser].objectId};
    PFQuery* query = [PFInstallation query];
    [query whereKey:@"User" equalTo:user];
    PFPush* push = [[PFPush alloc] init];
    [push setQuery:query];
    [push setData:dic];
    [push sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"Delivery notification successfully!!");
        } else {
            NSLog(@"Delivery notification failure!!");
        }
    }];
}

//This is method for send notification

+ (void) sendFeedNotificationToAllUserWithMessage :(NSString*) msg toPostObject:(PFObject*) postObject {
    NSDictionary* dic = @{@"alert" : msg,
                          @"sound" : @"default",
                          @"NotificationType" : @"Post",
                          @"PostObject" : postObject.objectId};//Keep Post Object Id for redirect
    PFQuery* query = [PFInstallation query];
   [query whereKey:@"User" notEqualTo:[PFUser currentUser]];
    PFPush* push = [[PFPush alloc] init];
    [push setQuery:query];
    [push setData:dic];
    [push sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"Delivery notification successfully!!");
        } else {
            NSLog(@"Delivery notification failure!!");
        }
    }];
}

//This is method send
+ (void) sendFeedNotificationToAllUserWithMessage1 :(NSString*) msg toPostObject:(PFObject*) postObject {
    NSDictionary* dic = @{@"alert" : msg,
                          @"sound" : @"default",
                          @"NotificationType" : @"Post",
                          @"StayAtPost" : @"YES",
                          @"PostObject" : postObject.objectId};//Keep Post Object Id for redirect
    PFQuery* query = [PFInstallation query];
    [query whereKey:@"User" notEqualTo:[PFUser currentUser]];
    PFPush* push = [[PFPush alloc] init];
    [push setQuery:query];
    [push setData:dic];
    [push sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"Delivery notification successfully!!");
        } else {
            NSLog(@"Delivery notification failure!!");
        }
    }];
}

@end
