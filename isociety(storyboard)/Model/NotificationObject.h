//
//  NotificationObject.h
//  Seik
//
//  Created by Gavin on 10/26/14.
//  Copyright (c) 2014 Seik, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^ResultBlock) (NSArray* objects, NSError* error) ;
typedef enum {
    NotificationFriendQuest = 0,
    NotificationPostComment = 1
    
} NotificationType;

@interface NotificationObject : NSObject

@property(nonatomic, strong) UIImage* AvatarImg;
@property(nonatomic, strong) NSString* NotificationText;
@property(nonatomic, strong) NSString* PostId;
@property(nonatomic, strong) NSDate* CreateDate;
@property(nonatomic) NotificationType NoticeType;
//Static Methods
+ (void) getFriendRequestForUser:(NSString*)userId onDone: (ResultBlock) finishBlock;

@end
