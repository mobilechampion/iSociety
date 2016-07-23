//
//  CustomNavigationController.m
//  iSociety
//
//  Created by Gavin on 10/26/14.
//  Copyright (c) 2014 iSociety, Inc. All rights reserved.
//

#import "CustomNavigationController.h"
#import "AppDelegate.h"
#import "BATUtil.h"
#import "Gradient.h"

@interface CustomNavigationController ()

@end

@implementation CustomNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationBar.barTintColor = [UIColor colorWithRed:0.0 green:0.478 blue:1.0 alpha:0.95];//[UIColor colorWithRed:102.0/255 green:254.0/255 blue:203.0/255 alpha:1.0];
    self.navigationBar.tintColor = [UIColor whiteColor]; //COLOR_NAVBAR_BUTTON;
    self.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
    self.navigationBar.translucent = NO;
    [self setupGradients];
   
    NSDictionary *textAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [UIColor whiteColor],NSForegroundColorAttributeName,
                                    [UIColor clearColor],NSBackgroundColorAttributeName,nil];
    
    self.navigationBar.titleTextAttributes = textAttributes;

    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setupGradients
{
    [self.view.layer insertSublayer:[Gradient setupGradient:self.view.frame] atIndex:0];
}

@end
