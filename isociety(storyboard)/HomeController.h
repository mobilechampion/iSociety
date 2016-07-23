//
//  HomeController.h
//  Seik
//
//  Created by Gavin on 10/26/14.
//  Copyright (c) 2014 Seik, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface HomeController : UIViewController <UIGestureRecognizerDelegate, UITableViewDataSource, UITableViewDelegate>{
    ADBannerView *adView;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property CGPoint from;
@property CGPoint to;
@property BOOL ignoreDrag;
@property(nonatomic) BOOL AutoRedirectToChat;
@property  UIImageView *imgIndicatorarrow;
@property UILabel *lblIndicator;

//Public methods
- (void) redirectToChatRoom:(PFUser*)userChat;

@end
