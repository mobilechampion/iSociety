//
//  AppDelegate.h
//  Seik
//
//  Created by Gavin on 10/26/14.
//  Copyright (c) 2014 Seik, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import <CoreLocation/CoreLocation.h>
#import <iAd/iAd.h>
#import "iSociety.h"
#import "SideMenuController.h"
#import "TSMessage.h"

#ifndef __AppDelegate__h

#define __AppDelegate__h

#define kOFFSET_KEYBOARD 120
#define APP_DELEGATE ((AppDelegate*)[UIApplication sharedApplication].delegate)

#endif

@interface AppDelegate : UIResponder <UIApplicationDelegate,SideMenuControllerDelegate, CLLocationManagerDelegate>

typedef enum DeviceTypes {
    IPHONE_4,
    IPHONE_5,
    IPHONE_6,
    IPHONE_6P
} Device_Type;

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, readwrite) Device_Type dev_type;

@property (nonatomic, strong) SideMenuController *sidemenuController;
@property (nonatomic, strong) UIViewController *controllerRef;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) UITabBarController* MainTabBar;
@property (strong, nonatomic) CLLocation *currentLoc;
@property (nonatomic) NSInteger NumberOfMessage;
@property (nonatomic) NSInteger NumberOfFriendRequest;

+(AppDelegate *)sharedAppDelegate;
-(void)menuClick:(id)sender;
- (void)switchLanguage ;
-(void)rootViewController;
-(void)menuDragFrom:(float)from To:(float)to Direction:(int)direction;
-(void)snap;

-(void)initializeArray;
-(void)addPickerView;
- (UIImage*)loadImage:(NSURL*)vidURL;


- (CLLocationDistance)calculateDistance:(CLLocation*)destLoc;
- (void)setLocationManager;

@end

