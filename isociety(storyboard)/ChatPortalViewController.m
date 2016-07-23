//
//  ChatPortalViewController.m
//  Seik
//
//  Created by Gavin on 10/26/14.
//  Copyright (c) 2014 Seik, Inc. All rights reserved.
//

#import "ChatPortalViewController.h"
#import "ChatViewController.h"
#import "Localization.h"
#import "CalendarViewController.h"

@interface ChatPortalViewController ()

@end

@implementation ChatPortalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = self.titleStr;
    
    UIBarButtonItem *today = [[UIBarButtonItem alloc] initWithTitle:[[Localization sharedInstance] localizedStringForKey:@"Calendar"] style:UIBarButtonItemStylePlain target:self action:@selector(goToCalendar:)];
    self.navigationItem.rightBarButtonItem = today;
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    ChatViewController *chatController = segue.destinationViewController;
    
    chatController.titleStr = _titleStr;
    chatController.chatRoomID = _chatRoomID;
    chatController.user = _user;
}


-(void)goToCalendar:(id)sender{
    CalendarViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"CalendarViewController"];
    
    controller.isNotMyCalendar = YES;
    controller.title = self.titleStr;
    controller.forUser = self.user;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)goToBackVC{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
