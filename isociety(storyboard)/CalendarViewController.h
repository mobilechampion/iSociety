//
//  CalendarViewController.h
//  Seik
//
//  Created by Gavin on 10/26/14.
//  Copyright (c) 2014 Seik, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@class DatePickerView;

@interface CalendarViewController : UIViewController <UIGestureRecognizerDelegate>

@property (strong, nonatomic) NSCalendar *calendar;

@property (readwrite) BOOL isNotMyCalendar;
@property (strong, nonatomic) PFUser *forUser;

@property (readwrite) BOOL allWeekSelected;
@property (readwrite) BOOL actionSheetOpened;

@property CGPoint from;
@property CGPoint to;
@property BOOL ignoreDrag;

@end
