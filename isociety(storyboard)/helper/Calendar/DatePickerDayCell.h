//
//  DatePickerDayCell.h
//  Seik
//
//  Created by Gavin on 10/26/14.
//  Copyright (c) 2014 Seik, Inc. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "iSociety.h"

@interface DatePickerDayCell : UICollectionViewCell

@property (nonatomic, readonly, strong) UILabel *dateLabel;
@property (nonatomic, readwrite, assign) DatePickerDate date;

@property (nonatomic, getter = isNotThisMonth) BOOL notThisMonth;
@property (nonatomic, getter = isDayOff) BOOL dayOff;

@property (nonatomic, getter = isToday) BOOL today;
@property (nonatomic, getter = isMarked) BOOL marked;
@property (nonatomic, getter = isAvailable) NSInteger availablity;
- (UIColor *)selfBackgroundColor;

- (UIFont *)dayLabelFont;
- (UIColor *)dayLabelTextColor;
- (UIColor *)dayOffLabelTextColor;
- (UIColor *)notThisMonthLabelTextColor;
- (UIFont *)todayLabelFont;
- (UIColor *)todayLabelTextColor;
- (UIColor *)todayImageColor;
- (UIImage *)customTodayImage;
- (UIColor *)overlayImageColor;

- (UIImage *)customOverlayImage;
- (UIColor *)availableMarkImageColor;
- (UIImage *)customAvailableMarkImage;
- (UIColor *)busyMarkImageColor;
- (UIColor *)idleMarkImageColor;
- (UIImage *)customIdleMarkImage;
- (UIImage *)customBusyMarkImage;
- (UIColor *)dividerImageColor;
- (UIImage *)customDividerImage;
@end
