//
//  NotificationCell.h
//  Seik
//
//  Created by Gavin on 10/26/14.
//  Copyright (c) 2014 Seik, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NotificationObject.h"

@interface NotificationCell : UITableViewCell


@property (weak, nonatomic) IBOutlet UIImageView * AvatarImageView;
@property (weak, nonatomic) IBOutlet UILabel * NotificationLbl;
@property (weak, nonatomic) IBOutlet UILabel * CreateDateLbl;

//Methods
- (void) blindDataToShow:(NotificationObject*) notificationObj;

@end
