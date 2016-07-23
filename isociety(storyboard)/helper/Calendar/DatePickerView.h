//
//  DatePickerView.h
//  Seik
//
//  Created by Gavin on 10/26/14.
//  Copyright (c) 2014 Seik, Inc. All rights reserved.
//


#import <UIKit/UIKit.h>

@protocol DatePickerViewDelegate;
@protocol DatePickerViewDataSource;

@interface DatePickerView : UIView<UIGestureRecognizerDelegate>

- (instancetype)initWithFrame:(CGRect)frame calendar:(NSCalendar *)calendar;

@property (nonatomic, readwrite, weak) id<DatePickerViewDelegate> delegate;
@property (nonatomic, readwrite, weak) id<DatePickerViewDataSource> dataSource;

- (void)scrollToToday:(BOOL)animated;

- (void)scrollToDate:(NSDate *)date animated:(BOOL)animated;

- (void)reloadData;

- (Class)daysOfWeekViewClass;
- (Class)collectionViewClass;
- (Class)collectionViewLayoutClass;
- (Class)monthHeaderClass;
- (Class)dayCellClass;
@end


@protocol DatePickerViewDelegate <NSObject>
@optional
- (void)datePickerView:(DatePickerView *)view didSelectDate:(NSDate *)date;
- (void)datePickerView:(DatePickerView *)view didLongPressedDate:(NSDate *)date;

@end


@protocol DatePickerViewDataSource <NSObject>

@optional
- (BOOL)datePickerView:(DatePickerView *)view shouldMarkDate:(NSDate *)date;
- (BOOL)datePickerView:(DatePickerView *)view isCompletedAllTasksOnDate:(NSDate *)date;
- (NSInteger)datePickerView:(DatePickerView *)view isAvailableOnDate:(NSDate *)date;

@end