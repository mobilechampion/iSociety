//
//  WunderlistAnimation.m
//  Seik
//
//  Created by Gavin on 10/26/14.
//  Copyright (c) 2014 Seik, Inc. All rights reserved.
//

#import "WunderlistAnimation.h"

@implementation WunderlistAnimation
+ (void)animateContentView:(UIView *)contentView sidebarView:(UIView *)sidebarView fromSide:(Side)side visibleWidth:(CGFloat)visibleWidth duration:(NSTimeInterval)animationDuration completion:(void (^)(BOOL))completion
{
    [self resetSidebarPosition:sidebarView];
    [self resetContentPosition:contentView];
    
    
    CGRect contentFrame = contentView.frame;
    CGRect sidebarFrame = sidebarView.frame;
    
    if(side == Left)
    {
        contentFrame.origin.x += visibleWidth;
        sidebarFrame.origin.x -= 50;
    }
    else
    {
        contentFrame.origin.x -= visibleWidth;
        sidebarFrame.origin.x += 50;
    }
    
    sidebarView.frame = sidebarFrame;
    sidebarFrame.origin.x = 0;
    
    [UIView animateWithDuration:animationDuration
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         contentView.frame = contentFrame;
                         sidebarView.frame = sidebarFrame;
                     }
                     completion:^(BOOL finished) {
                         completion(finished);
                     }];
}


+ (void)reverseAnimateContentView:(UIView *)contentView sidebarView:(UIView *)sidebarView fromSide:(Side)side visibleWidth:(CGFloat)visibleWidth duration:(NSTimeInterval)animationDuration completion:(void (^)(BOOL))completion
{
    CGRect contentFrame = contentView.frame;
    contentFrame.origin.x = 0;
    
    CGRect sidebarFrame = sidebarView.frame;
    
    if(side == Left)
    {
        sidebarFrame.origin.x -= 50;
    }
    else
    {
        sidebarFrame.origin.x += 50;
    }
    
    [UIView animateWithDuration:animationDuration
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         contentView.frame = contentFrame;
                         sidebarView.frame = sidebarFrame;
                     }
                     completion:^(BOOL finished) {
                         completion(finished);
                     }];
}

@end
