//
//  DatePickerCollectionView.m
//  Seik
//
//  Created by Gavin on 10/26/14.
//  Copyright (c) 2014 Seik, Inc. All rights reserved.
//


#import "DatePickerCollectionView.h"
#import "DatePickerCollectionViewLayout.h"

@implementation DatePickerCollectionView

@dynamic delegate;

#pragma mark - Lifecycle

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInitializer];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInitializer];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout
{
    self = [super initWithFrame:frame collectionViewLayout:layout];
    if (self) {
        [self commonInitializer];
    }
    return self;
}

- (void)commonInitializer
{
    self.backgroundColor = [self selfBackgroundColor];
    self.showsVerticalScrollIndicator = NO;
    self.showsHorizontalScrollIndicator = NO;
    self.scrollsToTop = NO;
    self.delaysContentTouches = NO;
}

- (void)layoutSubviews
{
    if ([self.delegate respondsToSelector:@selector(pickerCollectionViewWillLayoutSubviews:)]) {
        [self.delegate pickerCollectionViewWillLayoutSubviews:self];
    }
    [super layoutSubviews];
}

#pragma mark - Atrributes of the View

- (UIColor *)selfBackgroundColor
{
    return [UIColor whiteColor];
}

@end

