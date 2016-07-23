//
//  DatePickerCollectionView.h
//  Seik
//
//  Created by Gavin on 10/26/14.
//  Copyright (c) 2014 Seik, Inc. All rights reserved.
//


#import <UIKit/UIKit.h>

@class DatePickerCollectionView;

@protocol DatePickerCollectionViewDelegate <UICollectionViewDelegate>

- (void) pickerCollectionViewWillLayoutSubviews:(DatePickerCollectionView *)pickerCollectionView;

@end

@interface DatePickerCollectionView : UICollectionView

@property (nonatomic, assign) id <DatePickerCollectionViewDelegate> delegate;

- (UIColor *)selfBackgroundColor;
@end
