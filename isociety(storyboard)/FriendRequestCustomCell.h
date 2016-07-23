//
//  CalendarViewController.h
//  Seik
//
//  Created by Gavin on 10/26/14.
//  Copyright (c) 2014 Seik, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FriendRequestCustomCell : UITableViewCell

@property (nonatomic,strong) IBOutlet UILabel *lblFriendName;
@property (nonatomic,strong) IBOutlet UIButton *btnAccept;
@property (nonatomic,strong) IBOutlet UIButton *btnDecline;

@end
