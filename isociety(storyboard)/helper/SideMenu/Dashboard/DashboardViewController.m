//
//  DashboardViewController.m
//  Seik
//
//  Created by Gavin on 10/26/14.
//  Copyright (c) 2014 Seik, Inc. All rights reserved.
//

#import "DashboardViewController.h"
#import "iSociety.h"
#import "AppDelegate.h"
#import "HomeController.h"
#import "FriendsController.h"
#import "CustomNavigationController.h"
#import "ProfileViewController.h"
#import "Localization.h"
#import "CalendarViewController.h"
#import "FriendRequestViewController.h"
#import "PostViewController.h"
#import "Gradient.h"

@interface DashboardViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    UITableView *tableViewObj;
    NSArray *menuList,*imageArray;
    UIView *footerView;
}

@end

@implementation DashboardViewController

@synthesize tableViewObj;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self addTableView];
    
    menuList = @[[[Localization sharedInstance] localizedStringForKey:@"My Friends"],
                 [[Localization sharedInstance] localizedStringForKey:@"Add Friends"],
                 [[Localization sharedInstance] localizedStringForKey:@"Friend Requests"],
                 [[Localization sharedInstance] localizedStringForKey:@"Profile"],
                 [[Localization sharedInstance] localizedStringForKey:@"iSocietize Pro"],
                 [[Localization sharedInstance] localizedStringForKey:@"My Calendar"],
                 [[Localization sharedInstance] localizedStringForKey:@"My Post"]];
    
    imageArray = @[@"Home",
                   @"Friends",
                   @"FriendRequest",
                   @"Profiles",
                   @"Settings",
                   @"Calendar",
                   @"MyPost"];
    
    [self addHeaderView];
    
    [self addFooterView];
    
    [self setupGradients];
}

-(void)notificationReceived:(NSDictionary *)userInfo
{
    [tableViewObj selectRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0] animated:YES scrollPosition:UITableViewScrollPositionNone];
}

-(void)addHeaderView
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 117)];
    headerView.backgroundColor = [UIColor clearColor];
//
    UILabel *titleLabel = [BATUtil initLabelWithFrame:CGRectMake(0, 3, 260, 120) text:@"Seik" textAlignment:NSTextAlignmentCenter textColor:[UIColor colorWithRed:10.0f/255.0f green:0.0f/255.0f blue:255.0f/255.0f alpha:1.0] font:[UIFont fontWithName:@"SnellRoundhand" size:72]];
    
    [headerView addSubview:titleLabel];
    
    tableViewObj.tableHeaderView = headerView;
    
//    tableViewObj.backgroundColor = [BATUtil colorFromHexString:@"87CEEB"];
    
}

-(void)addFooterView
{
    UIButton *logoutButton = [BATUtil buttonWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height-50, 260, 50) backgroundColor:@"#00000000" title:[[Localization sharedInstance] localizedStringForKey:@"Logout"] delegate:self selector:@selector(logOut:)];
    [self.view addSubview:logoutButton];
}

-(void)addTableView
{
    self.view.frame = [UIScreen mainScreen].bounds;
    tableViewObj = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height) style:UITableViewStylePlain];
    tableViewObj.delegate = self;
    tableViewObj.dataSource = self;
    tableViewObj.scrollEnabled = NO;
    tableViewObj.backgroundColor = [UIColor clearColor];
    [self.view addSubview:tableViewObj];
}

-(void)logOut:(id)sender
{
    [PFUser logOut];
    
    
//    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isSignIn"];
//    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[AppDelegate sharedAppDelegate] rootViewController];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return menuList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *strCellIdentifier = [NSString stringWithFormat:@"cell-%ld.%ld",(long)indexPath.section,(long)indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:strCellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:strCellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = [UIColor blackColor];
    
    cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.png",imageArray[indexPath.row]]];
    cell.textLabel.text = menuList[indexPath.row];
    // Configure the cell...
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIViewController *controller = nil;
    switch (indexPath.row) {
        case 0:{
            controller = [self.storyboard instantiateViewControllerWithIdentifier:@"HomeController"];
            break;
        }
        case 1:{
            controller = [self.storyboard instantiateViewControllerWithIdentifier:@"FriendsController"];
            break;
        }
        case 2:{
            controller = [self.storyboard instantiateViewControllerWithIdentifier:@"FriendRequestViewController"];
            break;
        }
        case 3:{
            controller = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileViewController"];
            break;
        }
        case 4:{
            controller = [self.storyboard instantiateViewControllerWithIdentifier:@"HomeController"];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"URL goes here (you dont have to mind)"]];
            break;
        }
        case 5:{
            controller = [self.storyboard instantiateViewControllerWithIdentifier:@"CalendarViewController"];
            ((CalendarViewController *)controller).isNotMyCalendar = NO;
            break;
        }
        case 6:{
            controller = [self.storyboard instantiateViewControllerWithIdentifier:@"PostViewController"];
            break;
        }
    }
    [AppDelegate sharedAppDelegate].controllerRef = controller;
       
    CustomNavigationController *navigationController = [[CustomNavigationController alloc] initWithRootViewController:controller];
    [[AppDelegate sharedAppDelegate].sidemenuController setContentViewController:navigationController];
    [[AppDelegate sharedAppDelegate].sidemenuController dismissSideMenuViewController];
}


-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [UIView new];
}

//9Series: Setup gradient color to blue green
-(void)setupGradients
{
    [self.view.layer insertSublayer:[Gradient setupGradient:self.view.frame] atIndex:0];
}
@end
