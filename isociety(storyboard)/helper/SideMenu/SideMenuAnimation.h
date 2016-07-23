//
//  SideMenuAnimation.h
//  Seik
//
//  Created by Gavin on 10/26/14.
//  Copyright (c) 2014 Seik, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

#define DegToRad(degrees) (degrees * M_PI / 180)
#define Animaions \
    @"FacebookAnimation", \
    @"AirbnbAnimation", \
    @"LuvocracyAnimation", \
    @"FeedlyAnimation", \
    @"FlipboardAnimation", \
    @"WunderlistAnimation"

typedef NS_ENUM(NSInteger,  AnimationTransitionStyle) {
    AnimationTransitionStyleFacebook,
    AnimationTransitionStyleAirbnb,
    AnimationTransitionStyleLuvocracy,
    AnimationTransitionStyleFeedly,
    AnimationTransitionStyleFlipboard,
    AnimationTransitionStyleWunderlist
};

typedef NS_ENUM(NSInteger, Side) {
    Left,
    Right
};

@class SideMenuAnimation;

@interface SideMenuAnimation : NSObject

+ (void)animateContentView:(UIView *)contentView
               sidebarView:(UIView *)sidebarView
                  fromSide:(Side)side
              visibleWidth:(CGFloat)visibleWidth
                  duration:(NSTimeInterval)animationDuration
                completion:(void (^)(BOOL finished))completion;

+ (void)reverseAnimateContentView:(UIView *)contentView
                      sidebarView:(UIView *)sidebarView
                         fromSide:(Side)side
                     visibleWidth:(CGFloat)visibleWidth
                         duration:(NSTimeInterval)animationDuration
                       completion:(void (^)(BOOL finished))completion;

+ (void)resetSidebarPosition:(UIView *)sidebarView;
+ (void)resetContentPosition:(UIView *)contentView;

@end
