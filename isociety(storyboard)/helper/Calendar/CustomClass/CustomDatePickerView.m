//
//  CustomDatePickerView.m
//  Seik
//
//  Created by Gavin on 10/26/14.
//  Copyright (c) 2014 Seik, Inc. All rights reserved.
//


#import "CustomDatePickerView.h"
#import "CustomDatePickerDaysOfWeekView.h"
#import "CustomDatePickerCollectionView.h"
#import "CustomDatePickerCollectionViewLayout.h"
#import "CustomDatePickerMonthHeader.h"
#import "CustomDatePickerDayCell.h"

@implementation CustomDatePickerView

- (Class)daysOfWeekViewClass
{
    return [CustomDatePickerDaysOfWeekView class];
}

- (Class)collectionViewClass
{
    return [CustomDatePickerCollectionView class];
}

- (Class)collectionViewLayoutClass
{
    return [CustomDatePickerCollectionViewLayout class];
}

- (Class)monthHeaderClass
{
    return [CustomDatePickerMonthHeader class];
}

- (Class)dayCellClass
{
    return [CustomDatePickerDayCell class];
}

@end
