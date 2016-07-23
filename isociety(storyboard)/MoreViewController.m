//
//  MoreViewController.m
//  Seik
//
//  Created by Gavin on 10/26/14.
//  Copyright (c) 2014 Seik, Inc. All rights reserved.
//

#import "MoreViewController.h"
#import "AppDelegate.h"
#import "Localization.h"

@interface MoreViewController ()

@end

@implementation MoreViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [AppDelegate sharedAppDelegate].controllerRef = self;
    self.navigationController.navigationBarHidden = NO;
    [self customiseValues];
    
//    ADBannerView *adView = [[ADBannerView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 163, 320, 50)];
//    [self.view addSubview:adView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)customiseValues{
    self.title = [[Localization sharedInstance] localizedStringForKey:@"More"];
    [logoutButton setTitle:[[Localization sharedInstance] localizedStringForKey:@"Logout"] forState:UIControlStateNormal];

    ADBannerView *adView = [[ADBannerView alloc] initWithAdType:ADAdTypeMediumRectangle];
//    adView.frame = CGRectMake(10, 130, self.view.frame.size.width, adView.frame.size.height);
    adView.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2);
    [self.view addSubview:adView];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)Logout:(id)sender{
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    
    [userDefault setObject:@"no" forKey:@"isAlreadyLogin"];
    [userDefault synchronize];
    
    PFUser *user = [PFUser currentUser];
    user[PF_USER_AVIALABLITY] = @"0";

    [PFUser logOut];
    [[AppDelegate sharedAppDelegate] rootViewController];
}

- (IBAction)GotoPro:(id)sender{
    
}

@end
