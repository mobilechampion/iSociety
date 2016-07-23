//
//  NotificationObject.m
//  Seik
//
//  Created by Gavin on 10/26/14.
//  Copyright (c) 2014 Seik, Inc. All rights reserved.
//

#import "NotificationObject.h"
#import <Parse/Parse.h>
#import "Constant.h"

@implementation NotificationObject

#pragma -mark Impl Static methods

+ (void) getFriendRequestForUser:(NSString*)userId onDone: (ResultBlock) finishBlock {

    PFQuery* friendRequest = [PFQuery queryWithClassName:@"FriendRequest"];
    [friendRequest whereKey:PF_TO_USER_ID equalTo:userId];
    [friendRequest findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(objects && objects.count > 0) {
            NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:NO];
            finishBlock([objects sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]], error);
        } else {
            finishBlock(nil, error);
        }
        
    }];
}
@end
