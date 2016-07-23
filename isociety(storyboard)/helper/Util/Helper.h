//
//  Helper.h
//  Seik
//
//  Created by Gavin on 10/26/14.
//  Copyright (c) 2014 Seik, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface Helper : NSObject

//Static methods

+ (void) sendPushNotificationToUser:(PFUser*) user withMessage :(NSString*) msg;
+ (void) sendMessageNotificationToUser:(PFUser*) user withMessage :(NSString*) msg;
+ (void) sendFeedNotificationToAllUserWithMessage :(NSString*) msg toPostObject:(PFObject*) postObject;
+ (void) sendFeedNotificationToAllUserWithMessage1 :(NSString*) msg toPostObject:(PFObject*) postObject;

@end
