//
//  FriendsPortalViewController.m
//  Seik
//
//  Created by Gavin on 10/26/14.
//  Copyright (c) 2014 Seik, Inc. All rights reserved.
//

#import "FriendsPortalViewController.h"
#import "AppDelegate.h"
#import "Localization.h"
#import "FriendsController.h"
#import "FriendRequestViewController.h"

@interface FriendsPortalViewController ()

@end

@implementation FriendsPortalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [AppDelegate sharedAppDelegate].controllerRef = self;
    self.navigationController.navigationBarHidden = NO;
    [self customiseValues];
    
    ADBannerView *adView = [[ADBannerView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 163, self.view.frame.size.width, 50)];
    [self.view addSubview:adView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)customiseValues{
    self.title = [[Localization sharedInstance] localizedStringForKey:@"Friends"];
    [addFriendButton setTitle:[[Localization sharedInstance] localizedStringForKey:@"Add Friends"] forState:UIControlStateNormal];
    [addMeButton setTitle:[[Localization sharedInstance] localizedStringForKey:@"Added Me"] forState:UIControlStateNormal];
}

#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"myFriennds"]) {
        FriendsController *dest = (FriendsController*)segue.destinationViewController;
        dest.keyString = @"friends";
    }
}

#pragma -mark Iml Actions

- (void) redirectToAddedMe {
    FriendRequestViewController* friendRequestVC = [self.storyboard instantiateViewControllerWithIdentifier:@"FriendRequestViewController"];
    [self.navigationController pushViewController:friendRequestVC animated:TRUE];
}

@end
