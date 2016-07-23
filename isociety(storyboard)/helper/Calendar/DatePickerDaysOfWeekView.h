//
//  DatePickerDaysOfWeekView.h
//  Seik
//
//  Created by Gavin on 10/26/14.
//  Copyright (c) 2014 Seik, Inc. All rights reserved.
//


#import <UIKit/UIKit.h>

@interface DatePickerDaysOfWeekView : UIView

- (instancetype)initWithFrame:(CGRect)frame calendar:(NSCalendar *)calendar;
- (UIColor *)selfBackgroundColor;
- (CGSize)selfItemSize;
- (CGFloat)selfInteritemSpacing;
- (UIFont *)dayOfWeekLabelFont;

- (UIColor *)dayOfWeekLabelTextColor;
- (UIColor *)dayOffOfWeekLabelTextColor;

@end
