//
//  CustomDatePickerMonthHeader.m
//  Seik
//
//  Created by Gavin on 10/26/14.
//  Copyright (c) 2014 Seik, Inc. All rights reserved.
//

#import "CustomDatePickerMonthHeader.h"

@implementation CustomDatePickerMonthHeader

- (UIColor *)selfBackgroundColor
{
    return [UIColor colorWithRed:244/255.0f green:245/255.0f blue:247/255.0f alpha:1.0f];
}

- (UIFont *)monthLabelFont
{
    return [UIFont fontWithName:@"Avenir-Medium" size:18.0f];
}

- (UIColor *)monthLabelTextColor
{
    return [UIColor colorWithRed:51/255.0f green:37/255.0f blue:36/255.0f alpha:1.0f];
}

- (UIColor *)currentMonthLabelTextColor
{
    return [UIColor colorWithRed:3/255.0f green:117/255.0f blue:214/255.0f alpha:1.0f];
}

@end
