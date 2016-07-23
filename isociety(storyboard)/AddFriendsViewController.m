//
//  AddFriendsViewController.m
//  Seik
//
//  Created by Gavin on 10/26/14.
//  Copyright (c) 2014 Seik, Inc. All rights reserved.
//

#import "AddFriendsViewController.h"
#import "AppDelegate.h"
#import "Localization.h"
#import "FriendsController.h"

@interface AddFriendsViewController ()

@end

@implementation AddFriendsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [AppDelegate sharedAppDelegate].controllerRef = self;
    self.navigationController.navigationBarHidden = NO;
    [self customiseValues];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)customiseValues{
    self.title = [[Localization sharedInstance] localizedStringForKey:@"Add Friends"];
    
    ADBannerView *adView = [[ADBannerView alloc] initWithAdType:ADAdTypeMediumRectangle];
    adView.frame = CGRectMake(10, 130, self.view.frame.size.width, adView.frame.size.height);
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

#pragma mark - UITableView Delegate & Datasource
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    FriendsController *dest = [self.storyboard instantiateViewControllerWithIdentifier:@"FriendsController"];
    if (indexPath.row == 0) {
        dest.keyString = @"user";
    }else{
        dest.keyString = @"contact";
    }
    
    [self.navigationController pushViewController:dest animated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 2;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    NSArray *titleList = [[NSArray alloc] initWithObjects:
                          [[Localization sharedInstance] localizedStringForKey:@"Add by Username"],
                          [[Localization sharedInstance] localizedStringForKey:@"Add From Contact List"], nil];
    cell.textLabel.text = titleList[indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    return cell;
}

@end
