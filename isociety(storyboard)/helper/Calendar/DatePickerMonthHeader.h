//
//  DatePickerMonthHeader.h
//  Seik
//
//  Created by Gavin on 10/26/14.
//  Copyright (c) 2014 Seik, Inc. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "iSociety.h"

@interface DatePickerMonthHeader : UICollectionReusableView

@property (nonatomic, readonly, strong) UILabel *dateLabel;
@property (nonatomic, readwrite, assign) DatePickerDate date;
@property (nonatomic, getter = isCurrentMonth) BOOL currentMonth;
- (UIColor *)selfBackgroundColor;

- (UIFont *)monthLabelFont;
- (UIColor *)monthLabelTextColor;
- (UIColor *)currentMonthLabelTextColor;
@end
