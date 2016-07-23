//
//  NotificationTableVC.m
//  Seik
//
//  Created by Gavin on 10/26/14.
//  Copyright (c) 2014 Seik, Inc. All rights reserved.
//

#import "NotificationTableVC.h"
#import "NotificationCell.h"
#import "NotificationObject.h"
#import "PostCommentObject.h"
#import "FriendsPortalViewController.h"
#import "PostViewController.h"
#import "AppDelegate.h"
#import <Parse/Parse.h>
#import "MessageEmptyNotificationView.h"

#define PUPIL_STARTING_POS_Y    22

@interface NotificationTableVC ()
{
    NSMutableArray* _notificationArray;
    
    UIView *refreshLoadingView_;
    UIImageView *eyeBackgroundImageView_;
    UIImageView *eyePupilImageView_;
    int angle_;
    BOOL isRefreshingAnimating_;
    NSTimer *timer_;
    MessageEmptyNotificationView *emptyCellView;
}
@property (nonatomic) CGRect originalFrame;

@property (nonatomic) CGFloat yOffset;

@end

@implementation NotificationTableVC

- (void)viewDidLoad {

    [super viewDidLoad];
    emptyCellView = [[[NSBundle mainBundle] loadNibNamed:@"MessageEmptyNotificationView" owner:self options:nil] objectAtIndex:0];
    _notificationArray = [[NSMutableArray alloc] init];
    self.title = @"Notifications";
    self.tableView.tableFooterView = [UIView new];
    [self setupRefreshControl];
    [self.refreshControl beginRefreshing];
    [self reloadNotification];
    
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
     BOOL doesContain = [self.view.subviews containsObject:emptyCellView];
    if(doesContain)
    {
        [emptyCellView removeFromSuperview];
    }
    
    
    //Reset Badge once User take there
    PFInstallation* installation = [PFInstallation currentInstallation];
    if (installation.badge != 0 ){
        installation.badge = 0;
        [installation saveInBackground];
        UINavigationController* nav = [APP_DELEGATE.MainTabBar.viewControllers objectAtIndex:3];
        [nav tabBarItem].badgeValue = nil;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)endRefreshingWithDelay{
    double delayInSeconds = 3.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
//        [self performSelectorInBackground:@selector(reloadNotification) withObject:nil];
        [self.refreshControl endRefreshing];
    });
}

- (void) reloadNotification {
    
    NSLog(@"reloadNotification Called");
    //Get notifications
    PFUser* user = [PFUser currentUser];
    [NotificationObject getFriendRequestForUser:user.objectId onDone:^(NSArray *objects, NSError *error) {
        NSMutableArray *finalArray = [NSMutableArray array];
        for (PFObject* object in objects) {
            NotificationObject* objectToNotificationObj = [NotificationObject new];
            objectToNotificationObj.NotificationText = [NSString stringWithFormat:@"%@ sent you a friend request!", object[@"fromuser"]];
            objectToNotificationObj.CreateDate = object.createdAt;
            objectToNotificationObj.NoticeType = NotificationFriendQuest;
            [finalArray addObject:objectToNotificationObj];
        }
        [PostCommentObject getCommentsForUser:[PFUser currentUser] onDone:^(NSArray *objects, NSError *error) {
            for (PFObject* object in objects) {
                NotificationObject* objectToNotificationObj = [NotificationObject new];
                objectToNotificationObj.NotificationText = object[@"commentText"];
                objectToNotificationObj.PostId = object[@"postId"];
                objectToNotificationObj.CreateDate = object.createdAt;
                objectToNotificationObj.NoticeType = NotificationPostComment;
                [finalArray addObject:objectToNotificationObj];
            }
            _notificationArray = finalArray;
            [self.tableView reloadData];
            [self endRefreshingWithDelay];
        }];
    }];
}

#pragma mark- Refresh Control
-(void)setupRefreshControl
{
    // TODO: Programmatically inserting a UIRefreshControl
    angle_ = 0;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    
    [self.tableView addSubview:self.refreshControl];
    // Setup the loading view, which will hold the moving graphics
    refreshLoadingView_ = [[UIView alloc] initWithFrame:self.refreshControl.bounds];
    
    // Create the graphic image views
    eyeBackgroundImageView_ = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"eye.png"]];
    eyePupilImageView_ = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pupil.png"]];
    
    
    // Add the graphics to the loading view
    [refreshLoadingView_ addSubview:eyeBackgroundImageView_];
    [refreshLoadingView_ addSubview:eyePupilImageView_];
    //    [self.refreshControl setBackgroundColor:[UIColor clearColor]];
    
    // Clip so the graphics don't stick out
    refreshLoadingView_.clipsToBounds = YES;
    refreshLoadingView_.backgroundColor = self.view.backgroundColor;
    
    // Hide the original spinner icon
    self.refreshControl.tintColor = [UIColor clearColor];
    
    // Add the loading and colors views to our refresh control
    //[self.refreshControl addSubview:self.refreshColorView];
    [self.refreshControl addSubview:refreshLoadingView_];
    
    isRefreshingAnimating_ = NO;
    self.originalFrame = self.refreshControl.frame;
    self.refreshControl.backgroundColor = [UIColor clearColor];
    refreshLoadingView_.backgroundColor = [UIColor clearColor];
    [self setRefreshLoadingContentsWithOffsetY:0];
    // When activated, invoke our refresh function
    [self.refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
}

- (void)refresh:(id)sender{
    
    [self performSelectorInBackground:@selector(reloadNotification) withObject:nil];
}
-(void)setInMiddle
{
    CGFloat midX = self.tableView.frame.size.width / 2.5;
    CGRect eyeBgFrame = eyeBackgroundImageView_.frame;
    CGRect eyePupilFrame = eyePupilImageView_.frame;
    eyeBgFrame.origin.x = midX;
    eyePupilFrame.origin.x = midX+27;
    eyePupilFrame.origin.y = eyePupilFrame.origin.y+22;
    eyeBackgroundImageView_.frame = eyeBgFrame;
    eyePupilImageView_.frame = eyePupilFrame;

}
-(void)startPupilAnimation
{
    
//    if (timer_) {
//        [timer_ invalidate];
//        timer_ = nil;
//    }
    isRefreshingAnimating_ = YES;
    
    if (timer_ == nil)
    {
        timer_ = [NSTimer scheduledTimerWithTimeInterval:0.15 target:self selector:@selector(movieClockWise) userInfo:nil repeats:YES];
    }
}

-(void)stopPupilAnimation
{
    NSLog(@"Stop Animation");
    if (timer_) {
        [timer_ invalidate];
        timer_ = nil;
    }
    isRefreshingAnimating_ = NO;
}
-(void)movieClockWise
{
    angle_++;
    if(angle_ > 359){
        angle_ = 0;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        
        eyePupilImageView_.center = CGPointMake(eyePupilImageView_.center.x + cos(angle_) * 7, (eyePupilImageView_.center.y + sin (angle_) * 1));
//        eyePupilImageView_.center = CGPointMake(eyePupilImageView_.center.x + cos(angle_) * 7, eyePupilImageView_.center.y + sin (angle_) * 7);
    });
    //NSLog(@"Frame of eye :%@", NSStringFromCGRect(eyePupilImageView_.frame));
    if (!self.refreshControl.isRefreshing) {
        [self resetAnimation];
    }
}
- (void)resetAnimation
{
    // Reset our flags and background color
    isRefreshingAnimating_ = NO;
    angle_ = 0;
    NSLog(@"Reset Animation");
    
    [self stopPupilAnimation];
    [self resetPupilPosition];
    
}
- (void)setRefreshLoadingContentsWithOffsetY:(CGFloat)offsetY{
    CGFloat midX = self.tableView.frame.size.width / 2.5;
    CGRect eyeBgFrame = eyeBackgroundImageView_.frame;
    CGRect eyePupilFrame = eyePupilImageView_.frame;
    eyeBgFrame.origin.x = midX;
    //eyeBgFrame.origin.y = 0 - offsetY;
    eyePupilFrame.origin.x = midX+27;
    //eyePupilFrame.origin.y = PUPIL_STARTING_POS_Y - offsetY;
    eyeBackgroundImageView_.frame = eyeBgFrame;
    eyePupilImageView_.frame = eyePupilFrame;
//    if (offsetY >0){
//        eyeBackgroundImageView_.alpha = 0.0;
//        eyePupilImageView_.alpha = 0.0;
//    }
//    else
    {
        eyeBackgroundImageView_.alpha = 1.0;
        eyePupilImageView_.alpha = 1.0;

    }
}
-(void)resetPupilPosition
{
    [self.view layoutIfNeeded];
    [eyePupilImageView_ layoutIfNeeded];
    
    NSLog(@"Reset Frame of eye :%@", NSStringFromCGRect(eyePupilImageView_.frame));
    [UIView animateWithDuration:0.25 animations:^{
        [self setRefreshLoadingContentsWithOffsetY:30];
        [self.view layoutIfNeeded];
    }];
    
}

#pragma mark - UIScrollViewDelegates
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.refreshControl.isRefreshing && !isRefreshingAnimating_)
    {
        NSLog(@"Start Pupil Animation");
    }
    
    self.refreshControl.hidden = FALSE;
    NSInteger yOffset = scrollView.contentOffset.y;
    
    if (yOffset < -29)
    {
//        NSLog(@"yOffset %ld",yOffset);
        NSLog(@"Scroll Up");
        
        self.refreshControl.frame = CGRectMake(self.refreshControl.frame.origin.x, self.originalFrame.origin.y + yOffset, self.refreshControl.frame.size.width, self.refreshControl.frame.size.height);
        refreshLoadingView_.frame = self.refreshControl.bounds;
        
    }
    
    if (yOffset > -30)
    {
        self.refreshControl.frame = self.originalFrame;
        refreshLoadingView_.frame = self.refreshControl.bounds;
        
//        NSLog(@"yOffset %ld",yOffset);
        NSLog(@"Scroll Down");
        if(isRefreshingAnimating_ && !self.refreshControl.refreshing && (scrollView.contentOffset.y > -40))
        {
            [self resetAnimation];
        }
    }
    
    float height =  refreshLoadingView_.frame.size.height - eyeBackgroundImageView_.frame.size.height;
    if (height < 0)
    {
        height = 0;
    }
    
    eyeBackgroundImageView_.frame = CGRectMake(eyeBackgroundImageView_.frame.origin.x, refreshLoadingView_.frame.size.height - eyeBackgroundImageView_.frame.size.height, eyeBackgroundImageView_.frame.size.width, eyeBackgroundImageView_.frame.size.height);
    eyePupilImageView_.frame = CGRectMake(eyePupilImageView_.frame.origin.x, refreshLoadingView_.frame.size.height - 20.0 - eyePupilImageView_.frame.size.height, eyePupilImageView_.frame.size.width, eyePupilImageView_.frame.size.height);
    
    
    
    
    if (yOffset < -29)
    {
        NSLog(@"ANIMATION START");
        [self startPupilAnimation];
        
        ////self.refreshControl.hidden = FALSE;
        //[self resetAnimation];
    }
    else
    {
        
//        if(isRefreshingAnimating_ && !self.refreshControl.refreshing && (scrollView.contentOffset.y > -40))
//        {
//            NSLog(@"ANIMATION STOP");
//            [self resetAnimation];
//        }
        NSLog(@"ANIMATION STOP");
        [self resetAnimation];
    }
    //
    self.yOffset = scrollView.contentOffset.y;
    
}


- (void)scrollViewDidScrollOld:(UIScrollView *)scrollView
{
    if (self.refreshControl.isRefreshing && !isRefreshingAnimating_) {
        NSLog(@"Start Pupil Animation");
        
    }
    
    if (self.yOffset > scrollView.contentOffset.y){
        /// scroll up
        [self setRefreshLoadingContentsWithOffsetY:0];

//        [UIView animateWithDuration:0.25 animations:^{
//            [self setRefreshLoadingContentsWithOffsetY:0];
//            //[self.view layoutIfNeeded];
//        }];
       if(!isRefreshingAnimating_)
       {
           //[self startPupilAnimation];
       }
       if (!self.refreshControl.refreshing && scrollView.contentOffset.y < -150) {
           [self refresh:nil];
           [self.refreshControl beginRefreshing];
           //[self startPupilAnimation];

       }
        NSLog(@"Scroll Up %f",scrollView.contentOffset.y);
        
        //[self.tabBarController.tabBar setHidden:NO];
        //[self showTabBar: self.navigationController.tabBarController];
        
        
        //[self.navigationController.navigationBar setHidden: NO];
        //[self.navigationController setNavigationBarHidden:NO animated:YES ];
        
    }else  if (self.yOffset < scrollView.contentOffset.y) {
        // Scroll down
        NSLog(@"Scroll Down %f", scrollView.contentOffset.y);
        if(isRefreshingAnimating_ && !self.refreshControl.refreshing && (scrollView.contentOffset.y > -40)){
            //[self resetAnimation];
        }
        //[self.tabBarController.tabBar setHidden:YES];
        //[self hideTabBar: self.navigationController.tabBarController];
        
        //[self.navigationController.navigationBar setHidden: YES];
        //[self.navigationController setNavigationBarHidden:YES animated:YES ];
    }
    
     NSInteger yOffset = scrollView.contentOffset.y;
    if (yOffset < 0)
    {
        NSLog(@"ANIMATION START");
        [self startPupilAnimation];
        
        //        //self.refreshControl.hidden = FALSE;
        //        [self resetAnimation];
    }
    else
    {
        
        if(isRefreshingAnimating_ && !self.refreshControl.refreshing && (scrollView.contentOffset.y > 1))
        {
            NSLog(@"ANIMATION STOP");
            [self resetAnimation];
        }
    }

    self.yOffset = scrollView.contentOffset.y;
    
}

-(void) setViewEmptyTable
{
    BOOL doesContain = [self.view.subviews containsObject:emptyCellView];
    
    if(_notificationArray.count == 0)
    {
        if(!doesContain)
        {
            [self.view addSubview:emptyCellView];
            emptyCellView.center = CGPointMake(self.view.frame.size.width  / 2,
                self.view.frame.size.height / 2);
        }

    }
    
    else{
        if(doesContain)
        {
            [emptyCellView removeFromSuperview];
        }
    }
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    [self setViewEmptyTable];
   
    return _notificationArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NotificationCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NotificationCellId" forIndexPath:indexPath];
    
    [cell blindDataToShow:_notificationArray[indexPath.row]];
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NotificationObject *objectSelected = _notificationArray[indexPath.row];
    if (objectSelected.NoticeType == NotificationFriendQuest) {
        //Switch to Friend request tab
        UINavigationController* nav = APP_DELEGATE.MainTabBar.viewControllers[1];
        //Friend Portal
        FriendsPortalViewController* friendMainVC = (FriendsPortalViewController*)nav.viewControllers[0];
        //Focus to Friend request tab
        [APP_DELEGATE.MainTabBar setSelectedIndex:1];
        //Jump to Added me
        [friendMainVC performSelector:@selector(redirectToAddedMe) withObject:nil afterDelay:0.1];
    } else {
        //PostObject
        [APP_DELEGATE.MainTabBar setSelectedIndex:2];
        //Get Post object and redirect to comment
        NSString* postId = ((NotificationObject*)objectSelected).PostId;
        PFQuery* query = [PFQuery queryWithClassName:@"AnonymousPost"];
        [query whereKey:@"objectId" equalTo:postId];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (objects.count > 0) {
               UINavigationController*  nav = APP_DELEGATE.MainTabBar.viewControllers[0];
                //Friend Portal
                PostViewController* postVC = (PostViewController*)nav.viewControllers[0];
                //Jump to Added me
                [postVC performSelector:@selector(redirectToComment:) withObject:[objects lastObject] afterDelay:0.1];
                
            }
        }];
    }
}




@end
