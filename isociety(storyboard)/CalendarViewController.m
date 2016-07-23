//
//  CalendarViewController.m
//  Seik
//
//  Created by Gavin on 10/26/14.
//  Copyright (c) 2014 Seik, Inc. All rights reserved.
//

#import "CalendarViewController.h"
#import "DatePickerView.h"
#import "CustomDatePickerView.h"
#import "AppDelegate.h"
#import "Localization.h"
#import "ProgressHUD.h"
#include <libkern/OSAtomic.h>

@interface CalendarViewController ()<DatePickerViewDelegate, DatePickerViewDataSource,UIActionSheetDelegate>{
    NSDate *selectedDate;
    
    NSTimeInterval timestamp;
}

@property (strong, nonatomic) NSArray *availablityArray;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@property (strong, nonatomic) DatePickerView *datePickerView;
@property (strong, nonatomic) CustomDatePickerView *customDatePickerView;

-(NSDate *) lastMondayBeforeDate:(NSDate*)timeStamp timeInterval:(NSTimeInterval*)timeInterval;
-(NSDate *) nextMondayAfterDate:(NSDate*)timeStamp;

@end

@implementation CalendarViewController

@synthesize from;
@synthesize to;
@synthesize ignoreDrag;

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self customiseValues];
    [AppDelegate sharedAppDelegate].controllerRef = self;
    self.allWeekSelected = FALSE;
    self.navigationController.navigationBarHidden = NO;
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];

    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(slideView:)] ;
    [panRecognizer setMinimumNumberOfTouches:1];
    [panRecognizer setMaximumNumberOfTouches:1];
    [panRecognizer setDelegate:self];
    [self.view addGestureRecognizer:panRecognizer];
    
    UIPanGestureRecognizer *panRecognizerTop = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(slideView:)] ;
    [panRecognizerTop setMinimumNumberOfTouches:1];
    [panRecognizerTop setMaximumNumberOfTouches:1];
    [panRecognizerTop setDelegate:self];
    [self.navigationController.navigationBar addGestureRecognizer:panRecognizerTop];

    ADBannerView *adView = [[ADBannerView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 163, self.view.frame.size.width, 50)];
    [self.view addSubview:adView];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

-(void) slideView: (UIPanGestureRecognizer *) recognizer {
    
    CGPoint location = [recognizer locationInView:self.view];
    
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:{
            
            //possibilty to add some constraints for the draging
            /*if(!CGRectContainsPoint(view.frame, [recognizer locationInView:self.navigationController.navigationBar]))
             ignoreDrag=YES;
             else*/
            ignoreDrag=NO;
            
            if(ignoreDrag)
                return;
            
            from=location;
            
        }
            break;
            
        case UIGestureRecognizerStateChanged:{
            if(ignoreDrag)
                return;
            [[AppDelegate sharedAppDelegate] menuDragFrom:from.x To:location.x Direction:1];
        }
            break;
            
        case UIGestureRecognizerStateEnded:{
            if(ignoreDrag)
                return;
            [[AppDelegate sharedAppDelegate] snap];
        }
            break;
        default:
            break;
    }
}

-(void)customiseValues{
    self.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];

    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.view.backgroundColor = [BATUtil colorFromHexString:@"E6E6FA"];    
    if (!self.isNotMyCalendar) {
        self.title = [[Localization sharedInstance] localizedStringForKey:@"My Calendar"];
        self.forUser = [PFUser currentUser];
//        UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Dashboard.png"] style:UIBarButtonItemStyleDone target:[AppDelegate sharedAppDelegate] action:@selector(menuClick:)];
//        self.navigationItem.leftBarButtonItem = menuButton;
    }
    [ProgressHUD show:[NSString stringWithFormat:@"%@...",[[Localization sharedInstance] localizedStringForKey:@"Please Wait"]]];
    
    [self getCalendarDates];
    
    UIBarButtonItem *today = [[UIBarButtonItem alloc] initWithTitle:[[Localization sharedInstance] localizedStringForKey:@"Today"] style:UIBarButtonItemStylePlain target:self action:@selector(onTodayButtonTouch:)];
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor orangeColor];
    //[UIColor colorWithRed:244/255.0f green:245/255.0f blue:247/255.0f alpha:1.0f];
    self.navigationItem.rightBarButtonItem = today;
    
    [self.view addSubview:self.customDatePickerView];
}

-(void)getCalendarDates
{
    PFQuery *query = [PFQuery queryWithClassName:PF_CALENDAR_CLASS_NAME];
    [query whereKey:PF_CALENDAR_USER equalTo:self.forUser];
    [query setLimit: 1000];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if (error == nil)
         {
             self.availablityArray = objects;
             [self.customDatePickerView reloadData];
             
             [self.customDatePickerView scrollToToday:YES];
             
             [ProgressHUD dismiss];
         }
         else{
             [ProgressHUD dismiss];
             [ProgressHUD showError:[[Localization sharedInstance] localizedStringForKey:@"Network Error"]];
         }
     }];
    
}

#pragma mark - Custom Accessors

- (void)setCalendar:(NSCalendar *)calendar
{
    if (![_calendar isEqual:calendar]) {
        _calendar = calendar;
        _calendar.locale  = [NSLocale localeWithLocaleIdentifier:[[Localization sharedInstance] localizedStringForKey:@"Locale"]];
    }
}

- (NSDateFormatter *)dateFormatter
{
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setCalendar:self.calendar];
        [_dateFormatter setLocale:[self.calendar locale]];
        [_dateFormatter setDateStyle:NSDateFormatterFullStyle];
        [_dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    }
    return _dateFormatter;
}

- (DatePickerView *)datePickerView
{
    if (!_datePickerView) {
        _datePickerView = [[DatePickerView alloc] initWithFrame:self.view.bounds calendar:self.calendar];
        _datePickerView.delegate = self;
        _datePickerView.dataSource = self;
        _datePickerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return _datePickerView;
}

- (CustomDatePickerView *)customDatePickerView
{
    if (!_customDatePickerView) {
        _customDatePickerView = [[CustomDatePickerView alloc] initWithFrame:self.view.bounds calendar:self.calendar];
        _customDatePickerView.delegate = self;
        _customDatePickerView.dataSource = self;
        _customDatePickerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return _customDatePickerView;
}

#pragma mark - Action handling

- (void)onTodayButtonTouch:(UIBarButtonItem *)sender
{
    //    if (!self.datePickerView.hidden) {
    //        [self.datePickerView scrollToToday:YES];
    //    } else {
    [self.customDatePickerView scrollToToday:YES];
    //    }
}

- (void)onRestyleButtonTouch:(UIBarButtonItem *)sender
{
    if (!self.datePickerView.hidden) {
//        self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:244/255.0f green:245/255.0f blue:247/255.0f alpha:1.0f];
        self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.0 green:0.478 blue:1.0 alpha:0.95];
   
        self.datePickerView.hidden = YES;
        self.customDatePickerView.hidden = NO;
    } else {
        self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:248/255.0f green:248/255.0f blue:248/255.0f alpha:1.0f];
        self.customDatePickerView.hidden = YES;
        self.datePickerView.hidden = NO;
    }
}

#pragma mark - DatePickerViewDelegate

- (void)datePickerView:(DatePickerView *)view didSelectDate:(NSDate *)date
{
    NSLog(@"%@",date);
    self.allWeekSelected = FALSE;
    
    NSDateFormatter* df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"MM/dd/yyyy"];
    NSDate* enteredDate = date;
    NSDateComponents *todayYearMonthDayComponents = [self.calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:[NSDate date]];
    NSDate *today = [self.calendar dateFromComponents:todayYearMonthDayComponents];
    NSComparisonResult result = [today compare:enteredDate];
    switch (result)
    {
        case NSOrderedAscending:{
            
            if (!self.isNotMyCalendar && !self.actionSheetOpened) {
                selectedDate = date;
                NSLog(@"%@",selectedDate);
                
                timestamp = [selectedDate timeIntervalSince1970];
                UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:[[Localization sharedInstance] localizedStringForKey:@"Update Availablity:"] delegate:self cancelButtonTitle:[[Localization sharedInstance] localizedStringForKey:@"Cancel"] destructiveButtonTitle:nil otherButtonTitles:
                                              [[Localization sharedInstance] localizedStringForKey:@"I've Got No Plans"],
                                              [[Localization sharedInstance] localizedStringForKey:@"I'm Not Sure"],
                                              [[Localization sharedInstance] localizedStringForKey:@"Booked For The Day"], nil];
                
                [actionSheet showInView:self.view];
            }
            NSLog(@"Future Date");
            break;
            
        }
            
        case NSOrderedDescending:{
            NSLog(@"Earlier Date");
            
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Seik" message:[[Localization sharedInstance] localizedStringForKey:@"This day has already passed, plan ahead!"] delegate:nil cancelButtonTitle:[[Localization sharedInstance] localizedStringForKey:@"OK"] otherButtonTitles:nil];
            [alert show];
            
            break;
            
        }
        case NSOrderedSame:{
            NSLog(@"Today/Null Date Passed"); //Not sure why This is case when null/wrong date is passed
            
            if (!self.isNotMyCalendar) {
                selectedDate = date;
                timestamp = [selectedDate timeIntervalSince1970];
                UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:[[Localization sharedInstance] localizedStringForKey:@"Update Availablity:"] delegate:self cancelButtonTitle:[[Localization sharedInstance] localizedStringForKey:@"Cancel"] destructiveButtonTitle:nil otherButtonTitles:
                                              [[Localization sharedInstance] localizedStringForKey:@"I've Got No Plans"],
                                              [[Localization sharedInstance] localizedStringForKey:@"I'm Not Sure"],
                                              [[Localization sharedInstance] localizedStringForKey:@"Booked For The Day"], nil];
                
                [actionSheet showInView:self.view];
            }
            break;
        }
            
        default:
            NSLog(@"Error Comparing Dates");
            break;
    }
    
}

- (void)datePickerView:(DatePickerView *)view didLongPressedDate:(NSDate *)date
{
    if (!self.isNotMyCalendar && !self.actionSheetOpened) {
        selectedDate = date;
        timestamp = [selectedDate timeIntervalSince1970];
        
        NSDateComponents *todayYearMonthDayComponents = [self.calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:[NSDate date]];
        NSDate *today = [self.calendar dateFromComponents:todayYearMonthDayComponents];
        
        NSComparisonResult comparisonResult = [selectedDate compare:today];
        if (comparisonResult == NSOrderedDescending || comparisonResult == NSOrderedSame) {
            self.allWeekSelected = TRUE;
            self.actionSheetOpened = TRUE;
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:[[Localization sharedInstance] localizedStringForKey:@"Update Week:"] delegate:self cancelButtonTitle:[[Localization sharedInstance] localizedStringForKey:@"Cancel"] destructiveButtonTitle:nil otherButtonTitles:
                                          [[Localization sharedInstance] localizedStringForKey:@"Available"],
                                          [[Localization sharedInstance] localizedStringForKey:@"I'm Not Sure"],
                                          [[Localization sharedInstance] localizedStringForKey:@"Busy"], nil];
            
            [actionSheet showInView:self.view];
        }
        else {
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Oops!" message:[[Localization sharedInstance] localizedStringForKey:@"This day has already passed, plan ahead!"] delegate:nil cancelButtonTitle:[[Localization sharedInstance] localizedStringForKey:@"OK"] otherButtonTitles:nil];
            [alert show];
        }
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex < 3 && buttonIndex != -1 && buttonIndex !=actionSheet.cancelButtonIndex) {
        
        NSDate *newDate;
        [self.calendar rangeOfUnit:NSCalendarUnitDay
                         startDate:&newDate
                          interval:nil
                           forDate:selectedDate];
        selectedDate = newDate;
        
        NSDateComponents *todayYearMonthDayComponents = [self.calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:[NSDate date]];
        NSDate *today = [self.calendar dateFromComponents:todayYearMonthDayComponents];
        
        NSArray *filtered;
        if(!self.allWeekSelected) {
            filtered = [self.availablityArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.date == %@", selectedDate]];
        }
        else {
            filtered = [self.availablityArray filteredArrayUsingPredicate:[NSPredicate  predicateWithFormat:@"((date >= %@) AND (date < %@) AND (date >= %@))",[self lastMondayBeforeDate:selectedDate timeInterval:nil],[self nextMondayAfterDate:selectedDate], today]];
        }
        
        NSMutableArray *weekDateArray = [NSMutableArray array];
        
        if(!self.allWeekSelected) {
            [weekDateArray addObject:selectedDate];
        }
        else {
            NSDate *lastmonday = [self lastMondayBeforeDate:selectedDate timeInterval:nil];
            NSLog(@"monday %@", lastmonday);
            NSDateComponents *dayComponent1 = [[NSDateComponents alloc] init];
            dayComponent1.day = 1;
            
            /*NSDateComponents *dayComponent2 = [[NSDateComponents alloc] init];
             dayComponent2.day = 2;
             
             NSDateComponents *dayComponent3 = [[NSDateComponents alloc] init];
             dayComponent3.day = 3;
             
             NSDateComponents *dayComponent4 = [[NSDateComponents alloc] init];
             dayComponent4.day = 4;
             
             NSDateComponents *dayComponent5 = [[NSDateComponents alloc] init];
             dayComponent5.day = 5;
             
             NSDateComponents *dayComponent6 = [[NSDateComponents alloc] init];
             dayComponent6.day = 6;*/
            
            NSDate *weekDay = lastmonday;
            
            for (int i = 0; i < 7; i++) {
                NSComparisonResult result = [today compare:weekDay];
                if(result != NSOrderedDescending) {
                    [weekDateArray addObject:weekDay];
                }
                weekDay = [self.calendar dateByAddingComponents:dayComponent1 toDate:weekDay options:0];
            }
            
            
            /*weekDateArray = [NSMutableArray arrayWithObjects:
             lastmonday,
             [self.calendar dateByAddingComponents:dayComponent1 toDate:lastmonday options:0],
             [self.calendar dateByAddingComponents:dayComponent2 toDate:lastmonday options:0],
             [self.calendar dateByAddingComponents:dayComponent3 toDate:lastmonday options:0],
             [self.calendar dateByAddingComponents:dayComponent4 toDate:lastmonday options:0],
             [self.calendar dateByAddingComponents:dayComponent5 toDate:lastmonday options:0],
             [self.calendar dateByAddingComponents:dayComponent6 toDate:lastmonday options:0]
             ,nil];*/
        }
        
        NSLog(@"filtered %i", (int)filtered.count);
        
        for (PFObject *obj in filtered) {
            NSLog(@"savedobject %@", obj[PF_CALENDAR_DATE]);
            NSPredicate *removeSavedOnes = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
                // return YES for objects to keep
                NSDate *evaluateDate = (NSDate*)evaluatedObject;
                BOOL notMatched = [evaluateDate compare:obj[PF_CALENDAR_DATE]] != NSOrderedSame;
                NSLog(@"notmatched %i, %@, %@", notMatched, evaluateDate, obj[PF_CALENDAR_DATE]);
                return notMatched;
            }];
            
            [weekDateArray filterUsingPredicate:removeSavedOnes];
            
            [obj setObject:[NSString stringWithFormat:@"%ld",(long)buttonIndex] forKey:PF_USER_AVIALABLITY];
            // Save
            [obj save];
        }
        
        if (weekDateArray.count) {
            NSMutableArray *pfObjectArray = [NSMutableArray array];
            for(NSDate *weekDay in weekDateArray) {
                PFObject *object = [PFObject objectWithClassName:PF_CALENDAR_CLASS_NAME];
                object[PF_USER_AVIALABLITY] = [NSString stringWithFormat:@"%ld",(long)buttonIndex];
                object[PF_CALENDAR_USER] = [PFUser currentUser];
                object[PF_CALENDAR_DATE] = weekDay;
                object[PF_CALENDAR_DATE_TMSTMP] = [NSString stringWithFormat:@"%lf",timestamp];
                [pfObjectArray addObject:object];
            }
            
            __block int savedCount = 0;
            __block BOOL errorBool = FALSE;
            void(^backgroundBlock)(BOOL succeeded, NSError *error) = ^(BOOL succeeded, NSError *error) {
                if (error != nil)
                {
                    errorBool = TRUE;
                }
                
                savedCount++;
                NSLog(@"saved %i of %i", savedCount, (int)weekDateArray.count);
                if(savedCount == (int)weekDateArray.count) {
                    if (!errorBool)
                    {
                        [ProgressHUD show:[[Localization sharedInstance] localizedStringForKey:@"Saved"]];
                    }
                    else [ProgressHUD showError:[[Localization sharedInstance] localizedStringForKey:@"Network Error"]];;
                    
                    self.actionSheetOpened = FALSE;
                    [ProgressHUD show:[NSString stringWithFormat:@"%@...",[[Localization sharedInstance] localizedStringForKey:@"Please Wait"]]];
                    [self getCalendarDates];
                }
                /*else {
                 [[pfObjectArray objectAtIndex:savedCount] saveInBackgroundWithBlock:backgroundBlock];
                 }*/
            };
            
            for(PFObject *object in pfObjectArray) {
                [object saveInBackgroundWithBlock:backgroundBlock];
            }
            
        }
        else {
            self.actionSheetOpened = FALSE;
            [ProgressHUD show:[NSString stringWithFormat:@"%@...",[[Localization sharedInstance] localizedStringForKey:@"Please Wait"]]];
            [self getCalendarDates];
        }
        
    }
    else
    {
        NSLog(@"Cancel");
        self.actionSheetOpened = FALSE;
    }
}

#pragma mark - DatePickerViewDataSource
- (BOOL)datePickerView:(DatePickerView *)view shouldMarkDate:(NSDate *)date{
    NSArray *filtered = [self.availablityArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.date == %@", date]];
    return filtered.count;
}

- (BOOL)datePickerView:(DatePickerView *)view isCompletedAllTasksOnDate:(NSDate *)date{
    NSArray *filtered = [self.availablityArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.date == %@", date]];
    PFObject *obj = filtered[0];
    return [obj[PF_USER_AVIALABLITY] boolValue];
}

- (NSInteger)datePickerView:(DatePickerView *)view isAvailableOnDate:(NSDate *)date{
    NSArray *filtered = [self.availablityArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.date == %@", date]];
    PFObject *obj = filtered[0];
    return [obj[PF_USER_AVIALABLITY] integerValue];
}

#pragma mark - UtilityFunctions
-(NSDate *) lastMondayBeforeDate:(NSDate*)timeStamp timeInterval:(NSTimeInterval*)timeInterval {
    NSDate *startOfTheWeek;
    NSTimeInterval interval;
    if(timeInterval == nil)
        timeInterval = &interval;
    [self.calendar rangeOfUnit:NSCalendarUnitWeekOfYear
                     startDate:&startOfTheWeek
                      interval:timeInterval
                       forDate:timeStamp];
    return startOfTheWeek;
}

-(NSDate *) nextMondayAfterDate:(NSDate*)timeStamp {
    NSTimeInterval interval;
    NSDate *resultDate = [self lastMondayBeforeDate:timeStamp timeInterval:&interval];
    return [resultDate dateByAddingTimeInterval:interval-1];
}

@end
