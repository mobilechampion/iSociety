//
//  SideMenuController.h
//  Seik
//
//  Created by Gavin on 10/26/14.
//  Copyright (c) 2014 Seik, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SideMenuAnimation.h"
#import "DashboardViewController.h"

@protocol SideMenuControllerDelegate;

@interface SideMenuController : UIViewController

@property (nonatomic, strong) UIViewController *centerViewController;
@property (nonatomic, strong) DashboardViewController *leftViewController;
@property (nonatomic, strong) UIViewController *rightViewController;

@property (nonatomic, assign) NSTimeInterval animationDuration;
@property (nonatomic, assign) CGFloat sideMenuWidth;
@property (nonatomic, assign) BOOL isSideMenuPresent;
@property (nonatomic, assign) id <SideMenuControllerDelegate> delegate;
@property (nonatomic, assign) BOOL isUseAutoLayout;

- (id)initWithCenterViewController:(UIViewController *)centerViewController
          leftViewController:(UIViewController *)leftViewController;

- (id)initWithCenterViewController:(UIViewController *)centerViewController
         rightViewController:(UIViewController *)rightViewController;

- (id)initWithCenterViewController:(UIViewController *)centerViewController
          leftViewController:(UIViewController *)leftViewController
         rightViewController:(UIViewController *)rightViewController;

- (id)initWithCenterViewController:(UIViewController *)centerViewController
          leftViewController:(UIViewController *)leftViewController
           storyboardsUseAutoLayout:(BOOL)storyboardsUseAutoLayout;

- (id)initWithCenterViewController:(UIViewController *)centerViewController
         rightViewController:(UIViewController *)rightViewController
           storyboardsUseAutoLayout:(BOOL)storyboardsUseAutoLayout;

- (id)initWithCenterViewController:(UIViewController *)centerViewController
          leftViewController:(UIViewController *)leftViewController
         rightViewController:(UIViewController *)rightViewController
           storyboardsUseAutoLayout:(BOOL)storyboardsUseAutoLayout;

- (void)dismissSideMenuViewController;
- (void)presentLeftViewController;
- (void)presentLeftViewControllerWithStyle:(AnimationTransitionStyle)transitionStyle;
- (void)presentRightViewController;
- (void)presentRightViewControllerWithStyle:(AnimationTransitionStyle)transitionStyle;

- (void)menuDragFrom:(float)from To:(float)to Direction:(int)direction;
- (void)snap;

- (void)setContentViewController:(UIViewController *)centerViewController;

@end



@protocol SideMenuControllerDelegate <NSObject>

@optional
- (void)sidemenuController:(SideMenuController *)sidemenuController willShowViewController:(UIViewController *)viewController;
- (void)sidemenuController:(SideMenuController *)sidemenuController didShowViewController:(UIViewController *)viewController;
- (void)sidemenuController:(SideMenuController *)sidemenuController willHideViewController:(UIViewController *)viewController;
- (void)sidemenuController:(SideMenuController *)sidemenuController didHideViewController:(UIViewController *)viewController;
@end



@interface UIViewController(SideMenuController)

@property (strong, readonly, nonatomic) SideMenuController *sidemenuController;

@end

