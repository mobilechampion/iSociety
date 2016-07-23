//
//  DatePickerView.m
//  Seik
//
//  Created by Gavin on 10/26/14.
//  Copyright (c) 2014 Seik, Inc. All rights reserved.
//


#import "DatePickerView.h"
#import <QuartzCore/QuartzCore.h>
#import "iSociety.h"
#import "DatePickerCollectionView.h"
#import "DatePickerCollectionViewLayout.h"
#import "DatePickerDayCell.h"
#import "DatePickerMonthHeader.h"
#import "DatePickerView.h"
#import "DatePickerDaysOfWeekView.h"
#import "NSCalendar+Additions.h"
#import "Localization.h"

static NSString * const DatePickerViewMonthHeaderIdentifier = @"DatePickerViewMonthHeaderIdentifier";
static NSString * const DatePickerViewDayCellIdentifier = @"DatePickerViewDayCellIdentifier";


@interface DatePickerView () <DatePickerCollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, readonly, strong) NSCalendar *calendar;
@property (nonatomic, readonly, assign) DatePickerDate fromDate;
@property (nonatomic, readonly, assign) DatePickerDate toDate;
@property (nonatomic, readonly, strong) DatePickerDaysOfWeekView *daysOfWeekView;
@property (nonatomic, readonly, strong) DatePickerCollectionView *collectionView;
@property (nonatomic, readonly, strong) DatePickerCollectionViewLayout *collectionViewLayout;
@property (nonatomic, readonly, strong) NSDate *today;
@property (nonatomic, readonly, assign) NSUInteger daysInWeek;

@end

@implementation DatePickerView

@synthesize calendar = _calendar;
@synthesize fromDate = _fromDate;
@synthesize toDate = _toDate;
@synthesize daysOfWeekView = _daysOfWeekView;
@synthesize collectionView = _collectionView;
@synthesize collectionViewLayout = _collectionViewLayout;
@synthesize daysInWeek = _daysInWeek;

#pragma mark - Lifecycle

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInitializer];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInitializer];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame calendar:(NSCalendar *)calendar
{
    self = [super initWithFrame:frame];
    if (self) {
        _calendar = calendar;
        [self commonInitializer];
    }
    return self;
}

- (void)layoutSubviews
{
    CGPoint beforeLayoutSubviewsContentOffset = self.collectionView.contentOffset;
    
    [super layoutSubviews];
    
    self.daysOfWeekView.frame = [self daysOfWeekViewFrame];
    if (!self.daysOfWeekView.superview) {
        [self addSubview:self.daysOfWeekView];
    }
    
    self.collectionView.frame = [self collectionViewFrame];
    if (!self.collectionView.superview) {
        [self scrollToToday:NO];
        [self addSubview:self.collectionView];
    } else {
        [self.collectionViewLayout invalidateLayout];
        [self.collectionViewLayout prepareLayout];
        self.collectionView.contentOffset = beforeLayoutSubviewsContentOffset;
    }
    UILongPressGestureRecognizer* longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGesture:)];
    [self.collectionView addGestureRecognizer:longPressGesture];
    
    longPressGesture.minimumPressDuration = .5; //seconds
    longPressGesture.delegate = self;
    
    // Make the default gesture recognizer wait until the custom one fails.
    for (UIGestureRecognizer* aRecognizer in [self.collectionView gestureRecognizers]) {
        if ([aRecognizer isKindOfClass:[UILongPressGestureRecognizer class]])
            [aRecognizer requireGestureRecognizerToFail:longPressGesture];
    }
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    
    if (newSuperview && !_collectionView) {
        //	do some initialization!
        DatePickerDaysOfWeekView *v = self.daysOfWeekView;
        [v layoutIfNeeded];
        
        UICollectionView *cv = self.collectionView;
        [cv layoutIfNeeded];
    }
}
#pragma mark - Custom Accessors

- (NSCalendar *)calendar
{
    if (!_calendar) {
        _calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];        
        _calendar.locale  = [NSLocale localeWithLocaleIdentifier:[[Localization sharedInstance] localizedStringForKey:@"Local"]];
    }
    return _calendar;
}

- (CGRect)daysOfWeekViewFrame
{
    BOOL isPhone = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone;
    BOOL isPortraitInterfaceOrientation = UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation]);
    
    CGRect namesOfDaysViewFrame = self.bounds;
    if (isPhone) {
        if (isPortraitInterfaceOrientation) {
            namesOfDaysViewFrame.size.height = 22.0f;
        } else {
            namesOfDaysViewFrame.size.height = 26.0f;
        }
    } else {
        namesOfDaysViewFrame.size.height = 36.0f;
    }
    
    return namesOfDaysViewFrame;
}

- (Class)daysOfWeekViewClass
{
    return [DatePickerDaysOfWeekView class];
}

- (DatePickerDaysOfWeekView *)daysOfWeekView
{
    if (!_daysOfWeekView) {
        _daysOfWeekView = [[[self daysOfWeekViewClass] alloc] initWithFrame:[self daysOfWeekViewFrame] calendar:self.calendar];
    }
    return _daysOfWeekView;
}

- (Class)collectionViewClass
{
    return [DatePickerCollectionView class];
}

- (CGRect)collectionViewFrame
{
    CGFloat daysOfWeekViewHeight = CGRectGetHeight([self daysOfWeekViewFrame]);
    
    CGRect collectionViewFrame = self.bounds;
    collectionViewFrame.origin.y += daysOfWeekViewHeight;
    collectionViewFrame.size.height -= daysOfWeekViewHeight;
    return collectionViewFrame;
}

- (DatePickerCollectionView *)collectionView
{
    if (!_collectionView) {
        _collectionView = [[[self collectionViewClass] alloc] initWithFrame:[self collectionViewFrame] collectionViewLayout:self.collectionViewLayout];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        [_collectionView registerClass:[self monthHeaderClass] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:DatePickerViewMonthHeaderIdentifier];
        [_collectionView registerClass:[self dayCellClass] forCellWithReuseIdentifier:DatePickerViewDayCellIdentifier];
        [_collectionView reloadData];
    }
    return _collectionView;
}

- (Class)collectionViewLayoutClass
{
    return [DatePickerCollectionViewLayout class];
}

- (DatePickerCollectionViewLayout *)collectionViewLayout
{
    if (!_collectionViewLayout) {
        _collectionViewLayout = [[[self collectionViewLayoutClass] alloc] init];
    }
    return _collectionViewLayout;
}

- (Class)monthHeaderClass
{
    return [DatePickerMonthHeader class];
}

- (Class)dayCellClass
{
    return [DatePickerDayCell class];
}

- (NSUInteger)daysInWeek
{
    if (_daysInWeek == 0) {
        _daysInWeek = [self.calendar maximumRangeOfUnit:NSCalendarUnitWeekday].length;
    }
    return _daysInWeek;
}

#pragma mark - Handling Notifications

- (void)significantTimeChange:(NSNotification *)notification
{
    NSDateComponents *todayYearMonthDayComponents = [self.calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:[NSDate date]];
    _today = [self.calendar dateFromComponents:todayYearMonthDayComponents];
    
    [self.collectionView reloadData];
}

#pragma mark - Public

- (void)scrollToToday:(BOOL)animated
{
    [self scrollToDate:self.today animated:animated];
}

- (void)scrollToDate:(NSDate *)date animated:(BOOL)animated
{
    DatePickerCollectionView *cv = self.collectionView;
    DatePickerCollectionViewLayout *cvLayout = (DatePickerCollectionViewLayout *)self.collectionView.collectionViewLayout;
    
    NSArray *visibleCells = [self.collectionView visibleCells];
    if (![visibleCells count])
        return;
    
    NSDateComponents *dateYearMonthComponents = [self.calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth) fromDate:date];
    NSDate *month = [self.calendar dateFromComponents:dateYearMonthComponents];
    
    _fromDate = [self pickerDateFromDate:[self.calendar dateByAddingComponents:((^{
        NSDateComponents *components = [NSDateComponents new];
        components.month = -6;
        return components;
    })()) toDate:month options:0]];
    
    _toDate = [self pickerDateFromDate:[self.calendar dateByAddingComponents:((^{
        NSDateComponents *components = [NSDateComponents new];
        components.month = 6;
        return components;
    })()) toDate:month options:0]];
    
    [cv reloadData];
    [cvLayout invalidateLayout];
    [cvLayout prepareLayout];
    
    NSInteger section = [self sectionForDate:date];
    
    NSDate *firstDayInMonth = [self dateForFirstDayInSection:section];
    NSUInteger weekday = [self.calendar components:NSCalendarUnitWeekday fromDate:firstDayInMonth].weekday;
    NSInteger item = [self.calendar components:NSCalendarUnitDay fromDate:firstDayInMonth toDate:date options:0].day + (weekday - self.calendar.firstWeekday);
    
    NSIndexPath *cellIndexPath = [NSIndexPath indexPathForItem:item inSection:section];
    [self.collectionView scrollToItemAtIndexPath:cellIndexPath atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:animated];
}

- (void)reloadData
{
    [self.collectionView reloadData];
}

#pragma mark - Private

- (void)commonInitializer
{
    NSDateComponents *nowYearMonthComponents = [self.calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth) fromDate:[NSDate date]];
    NSDate *now = [self.calendar dateFromComponents:nowYearMonthComponents];
    
    _fromDate = [self pickerDateFromDate:[self.calendar dateByAddingComponents:((^{
        NSDateComponents *components = [NSDateComponents new];
        components.month = -6;
        return components;
    })()) toDate:now options:0]];
    
    _toDate = [self pickerDateFromDate:[self.calendar dateByAddingComponents:((^{
        NSDateComponents *components = [NSDateComponents new];
        components.month = 6;
        return components;
    })()) toDate:now options:0]];
    
    NSDateComponents *todayYearMonthDayComponents = [self.calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:[NSDate date]];
    _today = [self.calendar dateFromComponents:todayYearMonthDayComponents];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(significantTimeChange:)
                                                 name:UIApplicationSignificantTimeChangeNotification
                                               object:nil];
}

- (void)appendPastDates
{
    [self shiftDatesByComponents:((^{
        NSDateComponents *dateComponents = [NSDateComponents new];
        dateComponents.month = -6;
        return dateComponents;
    })())];
}

- (void)appendFutureDates
{
    [self shiftDatesByComponents:((^{
        NSDateComponents *dateComponents = [NSDateComponents new];
        dateComponents.month = 6;
        return dateComponents;
    })())];
}

- (void)shiftDatesByComponents:(NSDateComponents *)components
{
    DatePickerCollectionView *cv = self.collectionView;
    DatePickerCollectionViewLayout *cvLayout = (DatePickerCollectionViewLayout *)self.collectionView.collectionViewLayout;
    
    NSArray *visibleCells = [self.collectionView visibleCells];
    if (![visibleCells count])
        return;
    
    NSIndexPath *fromIndexPath = [cv indexPathForCell:((UICollectionViewCell *)visibleCells[0]) ];
    NSInteger fromSection = fromIndexPath.section;
    NSDate *fromSectionOfDate = [self dateForFirstDayInSection:fromSection];
    UICollectionViewLayoutAttributes *fromAttrs = [cvLayout layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:fromSection]];
    CGPoint fromSectionOrigin = [self convertPoint:fromAttrs.frame.origin fromView:cv];
    
    _fromDate = [self pickerDateFromDate:[self.calendar dateByAddingComponents:components toDate:[self dateFromPickerDate:self.fromDate] options:0]];
    _toDate = [self pickerDateFromDate:[self.calendar dateByAddingComponents:components toDate:[self dateFromPickerDate:self.toDate] options:0]];
    
#if 0
    
    //	This solution trips up the collection view a bit
    //	because our reload is reactionary, and happens before a relayout
    //	since we must do it to avoid flickering and to heckle the CA transaction (?)
    //	that could be a small red flag too
    
    [cv performBatchUpdates:^{
        
        if (components.month < 0) {
            
            [cv deleteSections:[NSIndexSet indexSetWithIndexesInRange:(NSRange){
                cv.numberOfSections - abs(components.month),
                abs(components.month)
            }]];
            
            [cv insertSections:[NSIndexSet indexSetWithIndexesInRange:(NSRange){
                0,
                abs(components.month)
            }]];
            
        } else {
            
            [cv insertSections:[NSIndexSet indexSetWithIndexesInRange:(NSRange){
                cv.numberOfSections,
                abs(components.month)
            }]];
            
            [cv deleteSections:[NSIndexSet indexSetWithIndexesInRange:(NSRange){
                0,
                abs(components.month)
            }]];
            
        }
        
    } completion:^(BOOL finished) {
        
        NSLog(@"%s %x", __PRETTY_FUNCTION__, finished);
        
    }];
    
    for (UIView *view in cv.subviews)
        [view.layer removeAllAnimations];
    
#else
    
    [cv reloadData];
    [cvLayout invalidateLayout];
    [cvLayout prepareLayout];
    
#endif
    
    NSInteger toSection = [self sectionForDate:fromSectionOfDate];
    UICollectionViewLayoutAttributes *toAttrs = [cvLayout layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:toSection]];
    CGPoint toSectionOrigin = [self convertPoint:toAttrs.frame.origin fromView:cv];
    
    [cv setContentOffset:(CGPoint) {
        cv.contentOffset.x,
        cv.contentOffset.y + (toSectionOrigin.y - fromSectionOrigin.y)
    }];
}

- (NSInteger)sectionForDate:(NSDate *)date;
{
    return [self.calendar components:NSCalendarUnitMonth fromDate:[self dateForFirstDayInSection:0] toDate:date options:0].month;
}

- (NSDate *)dateForFirstDayInSection:(NSInteger)section
{
    return [self.calendar dateByAddingComponents:((^{
        NSDateComponents *dateComponents = [NSDateComponents new];
        dateComponents.month = section;
        return dateComponents;
    })()) toDate:[self dateFromPickerDate:self.fromDate] options:0];
}

- (NSUInteger)numberOfWeeksForMonthOfDate:(NSDate *)date
{
#if 0
    
    NSRange weekRange = [self.calendar rangeOfUnit:NSWeekCalendarUnit inUnit:NSMonthCalendarUnit forDate:date];
    
    
    // Example: Friday, Muharram 29, 1436 AH at 12:00:00 AM GMT+03:00
    NSUInteger incorrectNSRangeLength1 = NSUIntegerMax - 44; // must be 5
    
    // Example: Wednesday, Muharram 29, 1434 AH at 12:00:00 AM GMT+03:00
    NSUInteger incorrectNSRangeLength2 = NSUIntegerMax - 45; // must be 5
    
    if ((weekRange.length == incorrectNSRangeLength1) || (weekRange.length == incorrectNSRangeLength2)) {
        NSLog(@"%lu", (unsigned long)(weekRange.length));
        return 5;
    } else {
        return weekRange.length;
    }
    
#else
    
    NSDate *firstDayInMonth = [self.calendar dateFromComponents:[self.calendar components:NSCalendarUnitYear|NSCalendarUnitMonth fromDate:date]];
    
    NSDate *lastDayInMonth = [self.calendar dateByAddingComponents:((^{
        NSDateComponents *dateComponents = [NSDateComponents new];
        dateComponents.month = 1;
        dateComponents.day = -1;
        return dateComponents;
    })()) toDate:firstDayInMonth options:0];
    
    NSDate *fromFirstWeekday = [self.calendar dateFromComponents:((^{
        NSDateComponents *dateComponents = [self.calendar components:NSCalendarUnitWeekOfYear|NSCalendarUnitYearForWeekOfYear fromDate:firstDayInMonth];
        dateComponents.weekday = self.calendar.firstWeekday;
        return dateComponents;
    })())];
    
    NSDate *toFirstWeekday = [self.calendar dateFromComponents:((^{
        NSDateComponents *dateComponents = [self.calendar components:NSCalendarUnitWeekOfYear|NSCalendarUnitYearForWeekOfYear fromDate:lastDayInMonth];
        dateComponents.weekday = self.calendar.firstWeekday;
        return dateComponents;
    })())];
    
    return 1 + [self.calendar components:NSCalendarUnitWeekOfYear fromDate:fromFirstWeekday toDate:toFirstWeekday options:0].weekOfYear;
    
#endif
}

- (NSDate *)dateFromPickerDate:(DatePickerDate)dateStruct
{
    return [self.calendar dateFromComponents:[self dateComponentsFromPickerDate:dateStruct]];
}

- (NSDateComponents *)dateComponentsFromPickerDate:(DatePickerDate)dateStruct
{
    NSDateComponents *components = [NSDateComponents new];
    components.year = dateStruct.year;
    components.month = dateStruct.month;
    components.day = dateStruct.day;
    return components;
}

- (DatePickerDate)pickerDateFromDate:(NSDate *)date
{
    NSDateComponents *components = [self.calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:date];
    return (DatePickerDate) {
        components.year,
        components.month,
        components.day
    };
}

- (NSUInteger)reorderedWeekday:(NSUInteger)weekday
{
    NSInteger ordered = weekday - self.calendar.firstWeekday;
    if (ordered < 0) {
        ordered = self.daysInWeek + ordered;
    }
    
    return ordered;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return [self.calendar components:NSCalendarUnitMonth fromDate:[self dateFromPickerDate:self.fromDate] toDate:[self dateFromPickerDate:self.toDate] options:0].month;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.daysInWeek * [self numberOfWeeksForMonthOfDate:[self dateForFirstDayInSection:section]];
}

- (DatePickerDayCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    DatePickerDayCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:DatePickerViewDayCellIdentifier forIndexPath:indexPath];
    
    NSDate *firstDayInMonth = [self dateForFirstDayInSection:indexPath.section];
    DatePickerDate firstDayPickerDate = [self pickerDateFromDate:firstDayInMonth];
    NSUInteger weekday = [self reorderedWeekday:[self.calendar components:NSCalendarUnitWeekday fromDate:firstDayInMonth].weekday];
    
    NSDate *cellDate = [self.calendar dateByAddingComponents:((^{
        NSDateComponents *dateComponents = [NSDateComponents new];
        dateComponents.day = indexPath.item - weekday - 1;
        return dateComponents;
    })()) toDate:firstDayInMonth options:0];
    DatePickerDate cellPickerDate = [self pickerDateFromDate:cellDate];
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setLocale:[NSLocale localeWithLocaleIdentifier:[[Localization sharedInstance] localizedStringForKey:@"Locale"]]];
    NSString *formattedNumberString = [numberFormatter stringFromNumber:[NSNumber numberWithLong:(unsigned long)(cellPickerDate.day)]];
    

    cell.date = cellPickerDate;
    cell.dateLabel.text = formattedNumberString;//[NSString stringWithFormat:@"%lu", (unsigned long)(cellPickerDate.day)];
    
    cell.notThisMonth = !((firstDayPickerDate.year == cellPickerDate.year) && (firstDayPickerDate.month == cellPickerDate.month));
    if (!cell.isNotThisMonth) {
        weekday = [self.calendar components:NSCalendarUnitWeekday fromDate:cellDate].weekday;
        cell.dayOff = (weekday == 1) || (weekday == 7);
        
        if ([self.dataSource respondsToSelector:@selector(datePickerView:shouldMarkDate:)]) {
            cell.marked = [self.dataSource datePickerView:self shouldMarkDate:cellDate];
            
            if (cell.marked && [self.dataSource respondsToSelector:@selector(datePickerView:isAvailableOnDate:)]) {
                cell.availablity = [self.dataSource datePickerView:self isAvailableOnDate:cellDate];
            }
        }
        
        cell.today = ([cellDate compare:_today] == NSOrderedSame) ? YES : NO;
    }
    //Changes done by Deep
    // START
    UILabel *lbl = [[UILabel alloc ] initWithFrame:CGRectMake(0, 0, 1, cell.frame.size.height+2)];
    lbl.text = @"";
    lbl.backgroundColor = [UIColor redColor];
    [cell addSubview:lbl];
    // END
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        
        DatePickerMonthHeader *monthHeader = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:DatePickerViewMonthHeaderIdentifier forIndexPath:indexPath];
        
        NSString *dateFormatterName = [NSString stringWithFormat:@"calendarMonthHeader_%@_%@", [self.calendar calendarIdentifier], [[self.calendar locale] localeIdentifier]];
        NSDateFormatter *dateFormatter = [self.calendar df_dateFormatterNamed:dateFormatterName withConstructor:^{
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setCalendar:self.calendar];
            [dateFormatter setLocale:[self.calendar locale]];
            return dateFormatter;
        }];
        
        NSDate *formattedDate = [self dateForFirstDayInSection:indexPath.section];
        DatePickerDate date = [self pickerDateFromDate:formattedDate];
        
        monthHeader.date = date;
        
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setLocale:[NSLocale localeWithLocaleIdentifier:[[Localization sharedInstance] localizedStringForKey:@"Locale"]]];
        NSString *formattedNumberString = [numberFormatter stringFromNumber:[NSNumber numberWithLong:(unsigned long)(date.year)]];
        
        NSString *monthString = [dateFormatter shortStandaloneMonthSymbols][date.month - 1];
        monthHeader.dateLabel.text = [[NSString stringWithFormat:@"%@ %@", monthString, formattedNumberString] uppercaseString];//[[NSString stringWithFormat:@"%@ %lu", monthString, (unsigned long)(date.year)] uppercaseString];
        
        DatePickerDate today = [self pickerDateFromDate:_today];
        if ( (today.month == date.month) && (today.year == date.year) ) {
            monthHeader.currentMonth = YES;
        } else {
            monthHeader.currentMonth = NO;
        }
        
        return monthHeader;
        
    }
    
    return nil;
}

#pragma mark - UICollectionViewDelegate

//	We are cheating by piggybacking on view state to avoid recalculation
//	in -collectionView:shouldHighlightItemAtIndexPath:
//	and -collectionView:shouldSelectItemAtIndexPath:.

//	A native refactoring process might introduce duplicate state which is bad too.

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    return !((DatePickerDayCell *)[collectionView cellForItemAtIndexPath:indexPath]).isNotThisMonth;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return !((DatePickerDayCell *)[collectionView cellForItemAtIndexPath:indexPath]).isNotThisMonth;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(datePickerView:didSelectDate:)]) {
        DatePickerDayCell *cell = ((DatePickerDayCell *)[collectionView cellForItemAtIndexPath:indexPath]);
        NSDate *selectedDate = cell ? [self.calendar dateFromComponents:[self dateComponentsFromPickerDate:cell.date]] : nil;
        [self.delegate datePickerView:self didSelectDate:selectedDate];
    }
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(DatePickerCollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return [collectionViewLayout selfHeaderReferenceSize];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(DatePickerCollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [collectionViewLayout selfItemSize];
}

#pragma mark - DatePickerCollectionViewDelegate

- (void)pickerCollectionViewWillLayoutSubviews:(DatePickerCollectionView *)pickerCollectionView
{
    //	Note: relayout is slower than calculating 3 or 6 months’ worth of data at a time
    //	So we punt 6 months at a time.
    
    //	Running Time	Self		Symbol Name
    //
    //	1647.0ms   23.7%	1647.0	 	objc_msgSend
    //	193.0ms    2.7%	193.0	 	-[NSIndexPath compare:]
    //	163.0ms    2.3%	163.0	 	objc::DenseMap<objc_object*, unsigned long, true, objc::DenseMapInfo<objc_object*>, objc::DenseMapInfo<unsigned long> >::LookupBucketFor(objc_object* const&, std::pair<objc_object*, unsigned long>*&) const
    //	141.0ms    2.0%	141.0	 	DYLD-STUB$$-[_UIHostedTextServiceSession dismissTextServiceAnimated:]
    //	138.0ms    1.9%	138.0	 	-[NSObject retain]
    //	136.0ms    1.9%	136.0	 	-[NSIndexPath indexAtPosition:]
    //	124.0ms    1.7%	124.0	 	-[_UICollectionViewItemKey isEqual:]
    //	118.0ms    1.7%	118.0	 	_objc_rootReleaseWasZero
    //	105.0ms    1.5%	105.0	 	DYLD-STUB$$CFDictionarySetValue$shim
    
    if (pickerCollectionView.contentOffset.y < 0.0f) {
        [self appendPastDates];
    }
    
    if (pickerCollectionView.contentOffset.y > (pickerCollectionView.contentSize.height - CGRectGetHeight(pickerCollectionView.bounds))) {
        [self appendFutureDates];
    }
}

#pragma mark - UILongPressGestureRecognizer

- (void)handleLongPressGesture:(UILongPressGestureRecognizer*)gesture
{
    if ( gesture.state == UIGestureRecognizerStateEnded ) {
        

        if ([self.delegate respondsToSelector:@selector(datePickerView:didLongPressedDate:)]) {
            CGPoint p = [gesture locationInView:self.collectionView];
            NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:p];
            if (indexPath != nil){
                DatePickerDayCell* cell = ((DatePickerDayCell* )[self.collectionView cellForItemAtIndexPath:indexPath]);
                NSDate *selectedDate = cell ? [self.calendar dateFromComponents:[self dateComponentsFromPickerDate:cell.date]] : nil;
                [self.delegate datePickerView:self didLongPressedDate:selectedDate];
            }
        }
    }
    
}

@end
