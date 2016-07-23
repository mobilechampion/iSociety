//
//  AppDelegate.m
//  Seik
//
//  Created by Gavin on 10/26/14.
//  Copyright (c) 2014 Seik, Inc. All rights reserved.
//

#import "AppDelegate.h"
#import "CustomNavigationController.h"
#import "LoginViewController.h"
#import "HomeController.h"
#import "DashboardViewController.h"
#import "SideMenuController.h"
#import "Localization.h"
#import <FacebookSDK/FacebookSDK.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import <ParseCrashReporting/ParseCrashReporting.h>
#import "sqlite3.h"
#import "FriendsPortalViewController.h"
#import "NotificationTableVC.h"
#import "ChatPortalViewController.h"
#import "PostViewController.h"

#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

@interface AppDelegate ()<UIPickerViewDataSource,UIPickerViewDelegate,UIAlertViewDelegate>
{
    NSArray *pickerArray;
    UIPickerView *pickerView;
    UIView *pickerBackgroundView;
}
@end
@implementation AppDelegate
@synthesize controllerRef,sidemenuController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    
    [[self window] setBackgroundColor:[UIColor whiteColor]];
    
    [self setLocationManager];
    [self configureParseSDK];
    
    [self customiseNavigation];
    [self initialiseWindow];
    //[self customiseSetLanguage];
    

    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
#ifdef __IPHONE_8_0
        //Registered device for push notifications.
        UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                        UIUserNotificationTypeBadge |
                                                        UIUserNotificationTypeSound);
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                                 categories:nil];
        [application registerUserNotificationSettings:settings];
        [application registerForRemoteNotifications];
#endif
    } else {
        UIRemoteNotificationType myTypes = UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound;
        [application registerForRemoteNotificationTypes:myTypes];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationReceived:) name:@"notificationReceived" object:nil];

    if ([[UIScreen mainScreen] bounds].size.height == 480)
        self.dev_type = IPHONE_4;
    else if ([[UIScreen mainScreen] bounds].size.height == 568)
        self.dev_type = IPHONE_5;
    else if ([[UIScreen mainScreen] bounds].size.height == 667)
        self.dev_type = IPHONE_6;
    else if ([[UIScreen mainScreen] bounds].size.height == 736)
        self.dev_type = IPHONE_6P;

    
    UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];

    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    
    if ([[userDefault objectForKey:@"isAlreadyLogin"] isEqualToString:@"yes"])
    {
        _MainTabBar = [mainStoryBoard instantiateViewControllerWithIdentifier:@"mainTab"];
        
        _MainTabBar.selectedViewController = [_MainTabBar.viewControllers objectAtIndex:2];
        
        //[self presentViewController:PostViewController animated:NO completion:nil];
        self.window.rootViewController = _MainTabBar;
        
    } else {
        [[Localization sharedInstance] setLanguage:@"English"];
        [[AppDelegate sharedAppDelegate] switchLanguage];
    }

    [self setStatusBarColor];
    return YES;
}

-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"Error %@", error);
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation addUniqueObject:@"global" forKey:@"channels"];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    PFUser* currentUser = [PFUser currentUser];
    if (currentUser) {
        currentInstallation[@"User"] = currentUser;
    }
    [currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {

    //Play System sound
    UIApplicationState appstate = [[UIApplication sharedApplication] applicationState];
    if (appstate == UIApplicationStateActive) {
        AudioServicesPlaySystemSound(1104);
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"notificationReceived" object:self userInfo:userInfo];
    
    
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    // attempt to extract a token from the url
    return [FBAppCall handleOpenURL:url
                  sourceApplication:sourceApplication
                        withSession:[PFFacebookUtils session]];
}

#pragma mark - AppEngine methods

+ (AppDelegate *)sharedAppDelegate{
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (UIImage*)loadImage:(NSURL*)vidURL {
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:vidURL options:nil];
    AVAssetImageGenerator *generate = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    NSError *err = NULL;
    CMTime time = CMTimeMake(1, 60);
    CGImageRef imgRef = [generate copyCGImageAtTime:time actualTime:NULL error:&err];
    NSLog(@"err==%@, imageRef==%@", err, imgRef);
    
    return [[UIImage alloc] initWithCGImage:imgRef];
}

-(void)notificationReceived:(NSNotification*)notice{
        __block UINavigationController* nav = [_MainTabBar.viewControllers objectAtIndex:3];
    //Set Bagde number
    NSDictionary* userInfo = [notice userInfo];
    NSDictionary* result = [userInfo objectForKey:@"aps"];
    NSNumber* numberofrequest = [result objectForKey:@"badge"];
    [nav tabBarItem].badgeValue = [numberofrequest stringValue];
    NSString* notificationType = [userInfo objectForKey:@"NotificationType"];
    if (notificationType && [notificationType isEqualToString:@"Message"]) {
        //xwyk8eM9Qj
        _NumberOfMessage++;
        nav = _MainTabBar.viewControllers[0];
        [nav tabBarItem].badgeValue = [NSString stringWithFormat:@"%d",_NumberOfMessage];
        NSString* userId = [userInfo objectForKey:@"UserChat"];
        PFQuery* query = [PFUser query];
        [query whereKey:@"objectId" equalTo:userId];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (objects.count > 0) {
                PFUser* userChat = [objects lastObject];
                //Switch to Friend request tab
                //Friend Portal
                HomeController* homeVC = (HomeController*)nav.viewControllers[0];
                //Focus to Friend request tab
                homeVC.AutoRedirectToChat = TRUE;
                [_MainTabBar setSelectedIndex:0];
                //Jump to Added me
                [homeVC performSelector:@selector(redirectToChatRoom:) withObject:userChat afterDelay:0.1];
            }
        }];
        [TSMessage showNotificationWithTitle:[result objectForKey:@"alert"] type:TSMessageNotificationTypeMessage];
        
        
    } else if (notificationType && [notificationType isEqualToString:@"Post"]) {
        //PostObject
        [_MainTabBar setSelectedIndex:2];
        //Get Post object and redirect to comment
        NSString* postId = [userInfo objectForKey:@"PostObject"];
        //Process Post notification foreground & background
        NSString* stayAtPersonPost = [userInfo objectForKey:@"StayAtPost"];
        PFQuery* query = [PFQuery queryWithClassName:@"AnonymousPost"];
        [query whereKey:@"objectId" equalTo:postId];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (objects.count > 0) {
                nav = _MainTabBar.viewControllers[2];
                //Friend Portal
                PostViewController* postVC = (PostViewController*)nav.viewControllers[0];
                if ([stayAtPersonPost isEqualToString:@"YES"]) {
                    postVC.IsStayAtPersonPost = TRUE;
                }
                //Jump to Added me
                [postVC performSelector:@selector(redirectToComment:) withObject:[objects lastObject] afterDelay:0.1];
                
            }
        }];
        [TSMessage showNotificationWithTitle:[result objectForKey:@"alert"] type:TSMessageNotificationTypeMessage];
    } else {
        //Handle Push Notifications.
        [PFPush handlePush:userInfo];
        //Switch to Friend request tab
        nav = _MainTabBar.viewControllers[1];
        _NumberOfFriendRequest++;
        [nav tabBarItem].badgeValue = [NSString stringWithFormat:@"%ld",_NumberOfFriendRequest];
        //Friend Portal
        FriendsPortalViewController* friendMainVC = (FriendsPortalViewController*)nav.viewControllers[0];
        //Focus to Friend request tab
        [_MainTabBar setSelectedIndex:1];
        //Jump to Added me
        [friendMainVC performSelector:@selector(redirectToAddedMe) withObject:nil afterDelay:0.1];
    }
}


-(void)initialiseWindow
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor colorWithRed:102.0/255 green:254.0/255 blue:203.0/255 alpha:1.0];
    [self.window makeKeyAndVisible];
}

-(void)customiseSetLanguage{
    PFUser *user = [PFUser currentUser];
    if(user){
        [[Localization sharedInstance] setLanguage:@"English"];
        [[AppDelegate sharedAppDelegate] switchLanguage];
    }else{
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Language" message:@"Would you like to set your preferred language?" delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No, Continue With English", nil];
        [alertView show];
    }
}

-(void)customiseNavigation{
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(-1000, -1000)
                                                         forBarMetrics:UIBarMetricsDefault];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [[Localization sharedInstance] setLanguage:@"English"];
        
        [[AppDelegate sharedAppDelegate] switchLanguage];
    }
    else{
        [self initializeArray];
        
        [self addPickerView];
    }
}

-(void)doneAction:(id)sender{
    NSString *languageStr = pickerArray[[pickerView selectedRowInComponent:0]];
    languageStr = [languageStr stringByReplacingOccurrencesOfString:@"" withString:@""];
    
    [[Localization sharedInstance] setLanguage:languageStr];
    [[AppDelegate sharedAppDelegate] switchLanguage];
}

-(void)cancelAction:(id)sender{
    [[Localization sharedInstance] setLanguage:@"English"];
    [[AppDelegate sharedAppDelegate] switchLanguage];
}

-(void)initializeArray{
    pickerArray = @[
                    @"Afrikaans",@"Albanian",@"Arabic",@"Armenian",@"Azerbaijani",@"Basque",@"Belarusian",@"Bengali",@"Bosnian",@"Bulgarian",@"Catalan",@"Chinese (Simplified)",@"Chinese (Traditional)",@"Croatian",@"Czech",
                @"Danish",@"Dutch",@"English",@"Esperanto",@"Estonian",@"Filipino",@"Finnish",@"French",@"Galician",@"Georgian",@"German",@"Greek",@"Gujarati",@"Haitian Creole",@"Hausa",@"Hebrew",@"Hindi",@"Hmong",@"Hungarian",@"Icelandic",@"Igbo",
                    @"Indonesian",@"Irish",@"Italian",@"Japanese",@"Javanese",@"Kannada",@"Khmer",
                    @"Korean",@"Lao",@"Malay",@"Maltese",@"Maori",@"Marathi",@"Mongolian",@"Nepali",@"Norwegian",@"Persian",
                    @"Polish",@"Portuguese",@"Punjabi",@"Romanian",@"Russian",
                    @"Serbian",@"Slovak",@"Slovenian",@"Somali",@"Spanish",@"Swahili",@"Swedish",@"Tamil",@"Telugu",
                    @"Thai",@"Turkish",
                    @"Ukrainian",@"Vietnamese",@"Welsh",@"Yiddish",@"Yoruba",@"Zulu"];
}

-(void)addPickerView{
    pickerBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height-260, [UIScreen mainScreen].bounds.size.width, 260)];
    pickerBackgroundView.backgroundColor = [BATUtil colorFromHexString:@"87CEEB"];
    
    [self.window addSubview:pickerBackgroundView];
    
    
    pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 44, pickerBackgroundView.frame.size.width, 216)];
    pickerView.delegate = self;
    pickerView.dataSource = self;
    pickerView.showsSelectionIndicator = YES;
    [pickerBackgroundView addSubview:pickerView];
    
    
    UIToolbar *pickerToolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, pickerView.frame.size.width, 44)];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:[[Localization sharedInstance] localizedStringForKey:@"Done"] style:UIBarButtonItemStyleDone target:self action:@selector(doneAction:)];
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:[[Localization sharedInstance] localizedStringForKey:@"Cancel"] style:UIBarButtonItemStyleDone target:self action:@selector(cancelAction:)];
    
    pickerToolBar.items = @[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],cancelButton, doneButton];
    [pickerBackgroundView addSubview:pickerToolBar];
    [pickerView selectRow:0 inComponent:0 animated:YES];
}


- (void)switchLanguage {
    [self.window removeFromSuperview];
    [self rootViewController];
}

-(void)rootViewController
{
    __block UIViewController *controller;
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    //User login check.
    PFUser *user = [PFUser currentUser];
    if(!user){
        
        PFInstallation *currentInstallation = [PFInstallation currentInstallation];
        [currentInstallation addUniqueObject:[NSString stringWithFormat:@"test%@",user.objectId] forKey:@"channels"];
        [currentInstallation saveInBackground];
        
        user[PF_USER_AVIALABLITY] = @"1";

        [ProgressHUD showSuccess:[NSString stringWithFormat:@"%@ %@!",[[Localization sharedInstance] localizedStringForKey:@"Welcome back"], [user objectForKey:PF_USER_USERNAME]]];
        controller = [mainStoryboard instantiateViewControllerWithIdentifier:@"mainTab"];
    }
    else{
        user[PF_USER_AVIALABLITY] = @"0";

        //If user is not logged in, diver user to login screen...
        controller = [[UINavigationController alloc] initWithRootViewController:[mainStoryboard instantiateViewControllerWithIdentifier:@"LoginViewController"]];
    }

    self.window.rootViewController = controller;
}

-(void)configureParseSDK{
    [Parse setApplicationId:@"Q8NUBnC4d3QpZn4x9x6sxdCJtLOiJbIHtYyFsGrO"
                  clientKey:@"sLQVl1yGwGsxXJGx4D9KZ8bSfjYzII9rrgwSCUJs"];
    [PFFacebookUtils initializeFacebook];
    
    [PFTwitterUtils initializeWithConsumerKey:@"yGzyAUUrxMfPf99JRGt9mnzle"
                               consumerSecret:@"YpwgCqmso5ypdHm0qVwmFUz56NxPNrwynEqe7qwPTatCoFGbF4"];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    
    PFUser *user = [PFUser currentUser];
    user[PF_USER_AVIALABLITY] = @"1";
    
    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
    }];
}

-(void)menuClick:(id)sender{
    if(self.sidemenuController.isSideMenuPresent){
        [self.sidemenuController dismissSideMenuViewController];
    }
    else{
        [self.sidemenuController presentLeftViewControllerWithStyle:5];
    }
}

-(void)snap{
    [self.sidemenuController snap];
}

-(void)menuDragFrom:(float)from To:(float)to Direction:(int)direction{
    [self.sidemenuController menuDragFrom:from To:to Direction:direction];
}

- (BOOL) application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return [PFFacebookUtils handleOpenURL:url];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    PFUser *user = [PFUser currentUser];
    if (user) {
        user[PF_USER_AVIALABLITY] = @"0";
        
        [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
        }];
    }
    // Logs 'install' and 'app activate' App Events.
    [self setLocationManager];
    [FBAppEvents activateApp];
    [FBAppCall handleDidBecomeActiveWithSession:[PFFacebookUtils session]];
}

#pragma mark - UIPickerView Delegate
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return pickerArray.count;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return pickerArray[row];
}

#pragma mark -CLLocation Manager delegate methods
- (CLLocationDistance)calculateDistance:(CLLocation*)destLoc{

    CLLocationDistance distance = [self.currentLoc distanceFromLocation:destLoc];
    NSLog(@"updated coordinate are %@",_currentLoc);

    double distanceKM = distance / 1639.344;
    NSLog(@"start location = %f, %f", self.currentLoc.coordinate.latitude, self.currentLoc.coordinate.longitude);
    NSLog(@"end location = %f, %f", destLoc.coordinate.latitude, destLoc.coordinate.longitude);
    NSLog(@"Calculated miles %@", [NSString stringWithFormat:@"%.1fmiles",(distance/1639.344)]); //
    return distanceKM;
}

- (void)setLocationManager{
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    _locationManager.delegate = self;
    
    // Override point for customization after application launch.
    if (IS_OS_8_OR_LATER){
        [_locationManager requestAlwaysAuthorization];
        //Right, that is the point
    }else{

    }
    
    [_locationManager startUpdatingLocation];
    _currentLoc = nil;
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    //    NSLog(@"didFailWithError: %@", error);
    [self setLocationManager];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    _currentLoc = [locations lastObject];
//    NSLog(@"updated coordinate are %@",_currentLoc);
}


-(void)setStatusBarColor
{
    //1) Set View controller-based status bar appearance to NO
    //2) Set Status bar style to UIStatusBarStyleLightContent
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
    {
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
        UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0, 0,[UIScreen mainScreen].bounds.size.width, 20)];
        view.alpha = 0.8;
        view.backgroundColor = [UIColor colorWithRed:0.0 green:0.478 blue:1.0 alpha:0.95];
        [self.window.rootViewController.view addSubview:view];
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}
@end
