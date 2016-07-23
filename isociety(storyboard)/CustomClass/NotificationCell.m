//
//  NotificationCell.m
//  Seik
//
//  Created by Gavin on 10/26/14.
//  Copyright (c) 2014 Seik, Inc. All rights reserved.
//

#import "NotificationCell.h"

@implementation NotificationCell

- (void)awakeFromNib {
    _AvatarImageView.layer.masksToBounds = FALSE;
    _AvatarImageView.layer.cornerRadius = _AvatarImageView.frame.size.width/2;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

#pragma -mark Impl Public methods

- (void) blindDataToShow:(NotificationObject*) notificationObj {
    if (!notificationObj.AvatarImg) {
        _AvatarImageView.backgroundColor = [UIColor clearColor];
    } else {
        _AvatarImageView.image = notificationObj.AvatarImg;
    }
    _NotificationLbl.text = notificationObj.NotificationText;
    _CreateDateLbl.text = [self formatNotificationCreateDate:notificationObj.CreateDate];
    //Calculate height
    CGSize maxSize = CGSizeMake([UIScreen mainScreen].bounds.size.width - _AvatarImageView.bounds.size.width - 10, CGFLOAT_MAX);
    CGSize size = [_NotificationLbl.text sizeWithFont:_NotificationLbl.font constrainedToSize:maxSize lineBreakMode:NSLineBreakByWordWrapping];
    CGRect frame = _NotificationLbl.frame;
    frame.size.height = size.height;
    _NotificationLbl.frame = frame;
    frame = _CreateDateLbl.frame;
    frame.origin.y = _NotificationLbl.frame.origin.y + size.height + 5;
    _CreateDateLbl.frame = frame;
}

#pragma -mark Impl Helper methods

-(NSString*) formatNotificationCreateDate:(NSDate*)date {
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"EEEE 'at' hh:mm a"]; //EX: Format Yesterday at 11: 00 PM
    return [formatter stringFromDate:date];
}

@end
