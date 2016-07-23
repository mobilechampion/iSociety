//
//  Gradient.m
//  Seik
//
//  Created by Gavin on 10/26/14.
//  Copyright (c) 2014 Seik, Inc. All rights reserved.
//


#import "Gradient.h"
#import <UIKit/UIKit.h>


@implementation Gradient

+ (CAGradientLayer *) setupGradient:(CGRect)frame
{
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.colors = @[(id)[Gradient blueRadient], (id)[Gradient greenRadient]];//colors;
    gradientLayer.locations = @[[NSNumber numberWithFloat:0.0], [NSNumber numberWithFloat:1.0]];
    gradientLayer.startPoint = CGPointMake(1, 0);
    gradientLayer.endPoint = CGPointMake(0, 1);
    gradientLayer.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);
    return gradientLayer;
}

+ (CGColorRef) blueRadient
{
    return [UIColor colorWithRed:(5/255.0) green:(198/255.0) blue:(249/255.0) alpha:1.0].CGColor;
}

+ (CGColorRef) greenRadient
{
    return [UIColor colorWithRed:(130/255.0) green:(247/255.0) blue:(76/255.0) alpha:1.0].CGColor;
}


@end
