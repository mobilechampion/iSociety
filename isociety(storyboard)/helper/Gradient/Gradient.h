//
//  Gradient.h
//  Seik
//
//  Created by Gavin on 10/26/14.
//  Copyright (c) 2014 Seik, Inc. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@interface Gradient : NSObject

+ (CAGradientLayer *) setupGradient:(CGRect)frame;

@end
