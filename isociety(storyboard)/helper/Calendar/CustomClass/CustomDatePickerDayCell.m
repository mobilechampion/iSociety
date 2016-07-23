//
//  CustomDatePickerDayCell.m
//  Seik
//
//  Created by Gavin on 10/26/14.
//  Copyright (c) 2014 Seik, Inc. All rights reserved.
//

#import "CustomDatePickerDayCell.h"

@implementation CustomDatePickerDayCell

- (UIFont *)dayLabelFont
{
    return [UIFont fontWithName:@"AvenirNext-Regular" size:16.0f];
}

- (UIColor *)dayLabelTextColor
{
    return [UIColor colorWithRed:51/255.0f green:37/255.0f blue:36/255.0f alpha:1.0f];
}

- (UIColor *)dayOffLabelTextColor
{
    return [UIColor colorWithRed:51/255.0f green:37/255.0f blue:36/255.0f alpha:1.0f];
}

- (UIFont *)todayLabelFont
{
    return [UIFont fontWithName:@"AvenirNext-Bold" size:17.0f];
}

- (UIColor *)todayLabelTextColor
{
    return [UIColor colorWithRed:3/255.0f green:117/255.0f blue:214/255.0f alpha:1.0f];
}

- (UIColor *)todayImageColor
{
    return [UIColor yellowColor];
}

- (UIColor *)overlayImageColor
{
    return [UIColor colorWithWhite:1.0f alpha:1.0f];
}

- (UIColor *)dividerImageColor
{
    return [UIColor redColor];
}

@end
