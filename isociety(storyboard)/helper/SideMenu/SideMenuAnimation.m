//
//  SideMenuAnimation.m
//  Seik
//
//  Created by Gavin on 10/26/14.
//  Copyright (c) 2014 Seik, Inc. All rights reserved.
//

#import "SideMenuAnimation.h"

@implementation SideMenuAnimation

+ (void)animateContentView:(UIView *)contentView sidebarView:(UIView *)sidebarView fromSide:(Side)side visibleWidth:(CGFloat)visibleWidth duration:(NSTimeInterval)animationDuration completion:(void (^)(BOOL))completion
{
    
}

+ (void)reverseAnimateContentView:(UIView *)contentView sidebarView:(UIView *)sidebarView fromSide:(Side)side visibleWidth:(CGFloat)visibleWidth duration:(NSTimeInterval)animationDuration completion:(void (^)(BOOL))completion
{
    
}

+ (void)resetSidebarPosition:(UIView *)sidebarView
{
    CATransform3D resetTransform = CATransform3DIdentity;
    resetTransform = CATransform3DRotate(resetTransform, DegToRad(0), 1, 1, 1);
    resetTransform = CATransform3DScale(resetTransform, 1.0, 1.0, 1.0);
    resetTransform = CATransform3DTranslate(resetTransform, 0.0, 0.0, 0.0);
    sidebarView.layer.transform = resetTransform;
    
    CGRect resetFrame = sidebarView.frame;
    resetFrame.origin.x = 0;
    resetFrame.origin.y = 0;
    sidebarView.frame = resetFrame;
    
    [sidebarView.superview sendSubviewToBack:sidebarView];
    sidebarView.layer.zPosition = 0;
}

+ (void)resetContentPosition:(UIView *)contentView
{
    CATransform3D resetTransform = CATransform3DIdentity;
    resetTransform = CATransform3DRotate(resetTransform, DegToRad(0), 1, 1, 1);
    resetTransform = CATransform3DScale(resetTransform, 1.0, 1.0, 1.0);
    resetTransform = CATransform3DTranslate(resetTransform, 0.0, 0.0, 0.0);
    contentView.layer.transform = resetTransform;
    
    CGRect resetFrame = contentView.frame;
    resetFrame.origin.x = 0;
    resetFrame.origin.y = 0;
    contentView.frame = resetFrame;
    
    [contentView.superview bringSubviewToFront:contentView];
    contentView.layer.zPosition = 0;
}

@end
