//
//  PostViewController.m
//  Seik
//
//  Created by Gavin on 10/26/14.
//  Copyright (c) 2014 Seik, Inc. All rights reserved.
//

#import "PostViewController.h"
#import "AppDelegate.h"
#import "Localization.h"
#import "PostCell.h"
#import "AddNewPostViewController.h"
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import "SVProgressHUD.h"
#import "CommentsViewController.h"
#import "Helper.h"
#import "NewPostViewController.h"

#define CARD_WIDTH 320
#define CARD_HEIGHT 300
#define CELL_HEIGHT 340

#define PUPIL_STARTING_POS_X    155
#define PUPIL_STARTING_POS_Y    22

@interface PostViewController ()
{
    UIView *refreshLoadingView_;
    UIImageView *eyeBackgroundImageView_;
    UIImageView *eyePupilImageView_;
    int angle_;
    BOOL isRefreshingAnimating_;
    NSTimer *timer_;
}

@property (nonatomic) CGRect originalFrame;
@property (nonatomic) CGPoint lastPositionOffset;
@property (nonatomic) CGFloat yOffset;
@property (nonatomic,strong) UIRefreshControl *refreshControl;
@end

@implementation PostViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    emptyCellView.hidden = YES;
    
    //Allocate memory to TableContentsList Array
    if (tableContentsList == nil)
    {
        tableContentsList = [[NSMutableArray alloc] init];
    }
    
    [self customiseView];
    [self customiseValues];
    moveDirection = 0;
    feedsTableView.alpha = 1.0f;
    feedsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    feedsTableView.backgroundColor = [UIColor clearColor];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
    
    
    enlargedView = [[UIView alloc] initWithFrame:CGRectMake(self.view.frame.origin.x,
                                                            self.view.frame.origin.y,
                                                            self.view.frame.size.width,
                                                            self.view.frame.size.height - self.navigationController.tabBarController.tabBar.frame.size.height - self.navigationController.navigationBar.frame.size.height)];
    [enlargedView setBackgroundColor:[UIColor blackColor]];
    contentImgView = [[UIImageView alloc] initWithFrame:enlargedView.frame];
    contentImgView.contentMode = UIViewContentModeScaleAspectFit;
    [contentImgView setUserInteractionEnabled:YES];
    [enlargedView addSubview:contentImgView];
    
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action: @selector(didTap)];
    tap.numberOfTapsRequired = 1;
    [enlargedView addGestureRecognizer:tap];
    
    [enlargedView setHidden:YES];
    [self.view addSubview:enlargedView];
    
    UIButton *exit = [UIButton buttonWithType:UIButtonTypeCustom];
    exit.frame = CGRectMake(0, 0, 30, 30);
    [exit setTitle:@"X" forState:UIControlStateNormal];
    [exit setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [exit addTarget:self action:@selector(didExit) forControlEvents:UIControlEventTouchUpInside];
    [flagView addSubview:exit];
    
    [enlargedView setUserInteractionEnabled:YES];
    UISwipeGestureRecognizer *swipeUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    swipeUp.direction = UISwipeGestureRecognizerDirectionUp;
    UISwipeGestureRecognizer *swipeDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    swipeDown.direction = UISwipeGestureRecognizerDirectionDown;
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    [enlargedView addGestureRecognizer:swipeUp];
    [enlargedView addGestureRecognizer:swipeDown];
    [enlargedView addGestureRecognizer:swipeLeft];
    [enlargedView addGestureRecognizer:swipeRight];
    
    [self setupRefreshControl];
}
-(void)setupRefreshControl
{
    angle_ = 0;
    
    self.refreshControl = [[UIRefreshControl alloc] init];

    [feedsTableView addSubview:self.refreshControl];
 
    refreshLoadingView_ = [[UIView alloc] initWithFrame:self.refreshControl.bounds];
    
    eyeBackgroundImageView_ = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"eye.png"]];
    eyePupilImageView_ = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pupil.png"]];
    
    
    [refreshLoadingView_ addSubview:eyeBackgroundImageView_];
    [refreshLoadingView_ addSubview:eyePupilImageView_];

    refreshLoadingView_.clipsToBounds = YES;
    refreshLoadingView_.backgroundColor = self.view.backgroundColor;
    
    self.refreshControl.tintColor = [UIColor clearColor];
    
    [self.refreshControl addSubview:refreshLoadingView_];
    
    isRefreshingAnimating_ = NO;
    self.originalFrame = self.refreshControl.frame;
    self.refreshControl.backgroundColor = [UIColor clearColor];
    refreshLoadingView_.backgroundColor = [UIColor clearColor];
    [self setRefreshLoadingContentsWithOffsetY:0];

    [self.refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
}

- (void)refresh:(id)sender
{
    
    [self loadFeedData];
}

-(void)setInMiddle
{
    CGFloat midX = feedsTableView.frame.size.width / 2.5;
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
    
    isRefreshingAnimating_ = YES;
    
    if (timer_ == nil)
    {
        timer_ = [NSTimer scheduledTimerWithTimeInterval:0.15 target:self selector:@selector(movieClockWise) userInfo:nil repeats:YES];
    }
}

-(void)stopPupilAnimation
{
    NSLog(@"Stop Animation");
    if (timer_)
    {
        [timer_ invalidate];
        timer_ = nil;
    }
    isRefreshingAnimating_ = NO;
}

-(void)movieClockWise
{
    angle_++;
    if(angle_ > 359)
    {
        angle_ = 0;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
       
        //[self setInMiddle];

        eyePupilImageView_.center = CGPointMake(eyePupilImageView_.center.x + cos(angle_) * 7, (eyePupilImageView_.center.y + sin (angle_) * 1));
    });
    
    NSLog(@"Frame of eye :%@", NSStringFromCGRect(eyePupilImageView_.frame));
    if (!self.refreshControl.isRefreshing)
    {
        [self resetAnimation];
    }
}

- (void)resetAnimation
{
    isRefreshingAnimating_ = NO;
    angle_ = 0;
    NSLog(@"Reset Animation");
    
    [self stopPupilAnimation];
    [self resetPupilPosition];
}

- (void)setRefreshLoadingContentsWithOffsetY:(CGFloat)offsetY
{
    CGFloat midX = feedsTableView.frame.size.width / 2.5;
    CGRect eyeBgFrame = eyeBackgroundImageView_.frame;
    CGRect eyePupilFrame = eyePupilImageView_.frame;
    eyeBgFrame.origin.x = midX;

    eyePupilFrame.origin.x = midX+27;
    
    eyeBackgroundImageView_.frame = eyeBgFrame;
    eyePupilImageView_.frame = eyePupilFrame;
    
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

- (void)showHideBar:(NSNumber *)param
{

    BOOL shown = [param boolValue];
    
    if (shown)
    {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        
        [UIView animateWithDuration:.5
                              delay:0.3
                            options: UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             
                             [feedsTableView setFrame:oldertablefrm];
                                                      }
                         completion:^(BOOL finished)
         {
             moveDirection = 0;
         }];
        
    }
    else
    {
        [self.navigationController setNavigationBarHidden:YES animated:YES];

        
        oldertablefrm = feedsTableView.frame;
    
        
        
        [UIView animateWithDuration:.5
                              delay:0.3
                            options: UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             
                             [feedsTableView setFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
            
                         }
                         completion:^(BOOL finished){
                             moveDirection = 0;
                         }];
        
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    
    self.navigationController.navigationBarHidden = NO;
    
    
    //self.navigationController.hidesBarsOnSwipe = YES;
    
    [self.refreshControl beginRefreshing];
    
    [self performSelector:@selector(loadFeedData) withObject:nil afterDelay:0.5];
    
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (void)endRefreshingWithDelay{
    double delayInSeconds = 3.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        [self.refreshControl endRefreshing];
    });
}

- (void)loadFeedData{
    if (!_isShowOwnerPost) {
        PFQuery *query = [PFQuery queryWithClassName:@"AnonymousPost"];
        if (postTypeSegment.selectedSegmentIndex == 0) {
            // Sorts the results in ascending order by the created date
            [query orderByDescending:@"createdAt"];
        }else if (postTypeSegment.selectedSegmentIndex == 1) {
            [query orderByDescending:@"voteCount"];
        }
        
        [query whereKey:@"postPosition" nearGeoPoint:[PFGeoPoint geoPointWithLocation:[AppDelegate sharedAppDelegate].currentLoc] withinMiles:5.f];
        
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            NSLog(@"%@", objects);
            tableContentsList = [[NSMutableArray alloc] init];
            //add david
//            [self filterByDistance:5 postList:objects];
            [tableContentsList addObjectsFromArray:objects];
            [feedsTableView reloadData];
            if(!feedsTableView.dragging&&!feedsTableView.tracking)
                feedsTableView.contentOffset = self.lastPositionOffset;
            self.lastPositionOffset = CGPointZero;
            
            [self endRefreshingWithDelay];
            [self setViewEmptyTable];
            
            [self checkBlockedUsers];
        }];
    } else {
        
        [self setViewEmptyTable];
        [feedsTableView reloadData];
        [self.refreshControl endRefreshing];
    }
    
}

-(void)didTap
{
    [enlargedView setHidden:YES];
}


#pragma mark - Internal

- (void)checkBlockedUsers
{
    __block PFUser *user = [PFUser currentUser];
    
    NSMutableArray *tempArray = [tableContentsList mutableCopy];
    
   __block NSMutableArray *blockedUsersArray = [NSMutableArray array];
    
    PFRelation *relation = [user relationForKey:@"testBlockedUsers"];

    [[relation query] findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        blockedUsersArray = [objects mutableCopy];
        
        [blockedUsersArray enumerateObjectsUsingBlock:^(PFObject *blockedUser, NSUInteger idx, BOOL *stop) {
            
            [tempArray enumerateObjectsUsingBlock:^(PFObject *postObject, NSUInteger idx, BOOL *stop) {
                
                if ([blockedUser[@"userID"] isEqualToString:postObject[@"User"]]) {
                    [tableContentsList removeObject:postObject];
                    NSLog(@"\n\n\n%@ == %@\n\n\n", blockedUser[@"userID"],  postObject[@"User"]);
                }

            }];
            
            
            if (stop) {
                [feedsTableView reloadData];
            }
        }];

    }];

}

#pragma mark - UI methods
- (void)addDashboardButton{
    UIBarButtonItem *refButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"plus"] style:UIBarButtonItemStyleDone target:self action:@selector(addNewPost)];
    self.navigationItem.rightBarButtonItem = refButton;
    
    NSArray *postTypes = [[NSArray alloc] initWithObjects:
                          [[Localization sharedInstance] localizedStringForKey:@"Current"],
                          [[Localization sharedInstance] localizedStringForKey:@"Trending"], nil];
    postTypeSegment = [[UISegmentedControl alloc] initWithItems:postTypes];
    postTypeSegment.tintColor = [UIColor whiteColor];
    postTypeSegment.frame = CGRectMake(self.view.frame.size.width / 2 - 65, 5, 130, 28);
    postTypeSegment.selectedSegmentIndex = 0;
    [postTypeSegment addTarget:self action:@selector(ChangeType:) forControlEvents:UIControlEventValueChanged];
       self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.0 green:0.478 blue:1.0 alpha:0.95];
    self.navigationItem.titleView = postTypeSegment;
    
}

- (void)customiseView
{
    [AppDelegate sharedAppDelegate].controllerRef = self;
}

- (void)customiseValues
{
    self.title = [[Localization sharedInstance] localizedStringForKey:@"Anonymous"];
    [self addDashboardButton];
}

#pragma mark - user defined methods
- (void)filterByDistance:(double)mileRadius postList:(NSArray*)posts{
    for (int i=0; i<posts.count; i++) {
        PFObject *tempObject = [posts objectAtIndex:i];
        PFGeoPoint *userGeoPoint = tempObject[@"postPosition"];
        
        CLLocation *postLoc = [[CLLocation alloc] initWithLatitude:userGeoPoint.latitude longitude:userGeoPoint.longitude];
        if ([[AppDelegate sharedAppDelegate] calculateDistance:postLoc] < mileRadius) {
            [tableContentsList addObject:tempObject];
        }
    }
    
    float low_bound = 0;
    float high_bound = [tableContentsList count];
    
    randomList = [[NSMutableArray alloc] init];
    for (int i=0; i<tableContentsList.count / 2; i++) {
        int rndValue = (int)(((float)arc4random()/0x100000000)*(high_bound-low_bound)+low_bound);
        [randomList addObject:[NSNumber numberWithInt:rndValue]];
    }
    
    NSLog(@"%@", randomList);
    [feedsTableView reloadData];
    if(!feedsTableView.dragging&&!feedsTableView.tracking)
        feedsTableView.contentOffset = self.lastPositionOffset;
    self.lastPositionOffset = CGPointZero;
}

- (void)menuClick:(id)sender{
    }

- (void)calTimeDifference:(NSDate*)sinceDate{
    sec = 0;
    NSDate *today = [NSDate date];
    NSInteger timeDiff = [today timeIntervalSinceDate:sinceDate];
    hour = timeDiff / 3600;        sec = timeDiff % 3600;
    min = sec / 60;                sec = sec % 60;
    day = hour / 24;
}

#pragma mark - IBAction methods
- (IBAction)ChangeType:(UISegmentedControl*)sender{
    PFQuery *query = [PFQuery queryWithClassName:@"AnonymousPost"];
    
    if (sender.selectedSegmentIndex == 0) {
        // Sorts the results in ascending order by the created date
        [query orderByDescending:@"createdAt"];
        
    }else if (sender.selectedSegmentIndex == 1) {
        [query orderByDescending:@"voteCount"];
    }
    
    [query whereKey:@"postPosition" nearGeoPoint:[PFGeoPoint geoPointWithLocation:[AppDelegate sharedAppDelegate].currentLoc] withinMiles:5.f];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSLog(@"%@", objects);
        tableContentsList = [[NSMutableArray alloc] init];
        //add david
        //            [self filterByDistance:5 postList:objects];
        [tableContentsList addObjectsFromArray:objects];
        [feedsTableView reloadData];
        if(!feedsTableView.dragging&&!feedsTableView.tracking)
            feedsTableView.contentOffset = self.lastPositionOffset;
        self.lastPositionOffset = CGPointZero;
    }];
}

- (void)handleSingleTap:(UISwipeGestureRecognizer *)gestureRecognizer {
    [ UIView animateWithDuration:1.5f animations:^{
        [enlargedView setTransform:CGAffineTransformIdentity];
    }];
    [enlargedView setHidden:YES];
    
}

#pragma mark - post action methods
- (void)addNewPost{
//    AddNewPostViewController *dest = [self.storyboard instantiateViewControllerWithIdentifier:@"AddNewPostViewController"];
//    dest.bNew = YES;
//    [self.navigationController pushViewController:dest animated:YES];

//    __block IFFiltersViewController *filtersViewController = [[IFFiltersViewController alloc] init];
//    
//            filtersViewController.shouldLaunchAsAVideoRecorder = NO;
//            filtersViewController.shouldLaunchAshighQualityVideo = NO;
//    
//    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
//    [self presentViewController:filtersViewController animated:YES completion:^(){
//        filtersViewController = nil;        
//    }];

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Post" bundle:[NSBundle mainBundle]];
    NewPostViewController *dest = [storyboard instantiateViewControllerWithIdentifier:@"NewPostViewController"];
    UINavigationController *destNav = [[UINavigationController alloc] initWithRootViewController:dest];
    [self presentViewController:destNav animated:YES completion:nil];
}

- (void)deletePost:(UIButton*)sender{
    PFObject *tempObject = [tableContentsList objectAtIndex:sender.tag];
    PFUser *user = [PFUser currentUser];
    
    NSLog(@"%@", tempObject[@"User"]);
    if ([tempObject[@"User"] isEqualToString:user.objectId]) {
        [tempObject deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded)
                [self loadFeedData];
        }];
    }
}

- (void)plusVote:(UIButton*)sender{
    
    PFObject *tempObject = [tableContentsList objectAtIndex:sender.tag];
    
    //[feedsTableView reloadData];
    
    PFUser *user = [PFUser currentUser];
    
    //...loading vote history for this post
    PFQuery *query = [PFQuery queryWithClassName:@"APostVoteTable"];
    [query whereKey:@"postId" equalTo:tempObject];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSLog(@"%@", objects);
        BOOL bAlreadyVoted = NO;
        PFObject *curPost;
        
        if(error != nil)
        {
            return;
        }
        
        // validate if the user already had voted this or not
        for (PFObject *object in objects) {
            PFUser *votedUser = object[@"voteUser"];
            if ([votedUser.objectId isEqualToString:user.objectId]) {
                curPost = object;
                bAlreadyVoted = YES;
                
                if([object[@"status"] isEqualToString:@"up"])
                {
                    return;
                }
                
                break;
            }
        }
        
        if (!bAlreadyVoted) {
            
            PFObject *mediaPost = [PFObject objectWithClassName:@"APostVoteTable"];
            mediaPost[@"postId"] = tempObject;
            mediaPost[@"voteUser"] = user;
            mediaPost[@"votedValue"] = [NSNumber numberWithInt:1];
            mediaPost[@"status"] = @"up";
            mediaPost[@"voteUser"] = user;
            
            [mediaPost saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    // The object has been saved.
                    PFQuery *query = [PFQuery queryWithClassName:@"AnonymousPost"];
                    
                    // Retrieve the object by id
                    [query getObjectInBackgroundWithId:tempObject.objectId block:^(PFObject *postObject, NSError *error) {
                        
                        NSString *postCount = postObject[@"voteCount"];
                        postCount = [NSString stringWithFormat:@"%d", [postCount intValue] + 1];
                        [tempObject setObject:postCount forKey:@"voteCount"];
                        [feedsTableView reloadData];
                        //Send notification each 5 votes
                        //                        if([postCount integerValue] % 5) {
                        //                            [Helper sendFeedNotificationToAllUserWithMessage1:[NSString stringWithFormat:@"Your post received %ld upvotes!", [postCount integerValue]] toPostObject:tempObject];
                        //                        }
                        postObject[@"voteCount"] = [NSString stringWithFormat:@"%d", [postCount intValue]];
                        
                        [postObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                            if (succeeded)
                            {
                                self.lastPositionOffset = feedsTableView.contentOffset;
                                [self loadFeedData];
                            }
                        }];
                    }];
                } else {
                    // There was a problem, check error.description
                }
            }];
        }
        
        
        else{
            if ([curPost[@"status"] isEqualToString:@"down"]) {
                PFQuery *query = [PFQuery queryWithClassName:@"APostVoteTable"];
                
                // Retrieve the object by id
                [query getObjectInBackgroundWithId:curPost.objectId block:^(PFObject *postObject, NSError *error) {
                                       postObject[@"votedValue"] = [NSNumber numberWithInt:1];
                    postObject[@"status"] = @"up";
                    postObject[@"voteUser"] = user;
                    
                    [postObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        if (succeeded){
                            PFQuery *query2 = [PFQuery queryWithClassName:@"AnonymousPost"];
                            // Retrieve the object by id
                            [query2 getObjectInBackgroundWithId:tempObject.objectId block:^(PFObject *anoPostObject, NSError *error) {
                                
                                NSString *postCount = anoPostObject[@"voteCount"];
                                postCount = [NSString stringWithFormat:@"%d", [postCount intValue] + 1];
                                [tempObject setObject:postCount forKey:@"voteCount"];
                                [feedsTableView reloadData];
                                
                                anoPostObject[@"voteCount"] = [NSString stringWithFormat:@"%d", [postCount intValue]];
                                
                                [anoPostObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                    if (succeeded)
                                    {
                                        self.lastPositionOffset = feedsTableView.contentOffset;
                                        [self loadFeedData];
                                    }
                                }];
                            }];
                        }
                    }];
                }];
            }
            
        }
    }];
}

- (void)downVote:(UIButton*)sender{
    
    
    PFObject *tempObject = [tableContentsList objectAtIndex:sender.tag];
    
    
    PFUser *user = [PFUser currentUser];
    
    //...loading vote history for this post
    PFQuery *query = [PFQuery queryWithClassName:@"APostVoteTable"];
    [query whereKey:@"postId" equalTo:tempObject];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSLog(@"%@", objects);
        BOOL bAlreadyVoted = NO;
        PFObject *curPost;
        
        if(error !=nil)
        {
            return;
        }
        
        // validate if the user already had voted this or not
        for (PFObject *object in objects) {
            PFUser *votedUser = object[@"voteUser"];
            if ([votedUser.objectId isEqualToString:user.objectId]) {
                curPost = object;
                bAlreadyVoted = YES;
                
                
                if([object[@"status"] isEqualToString:@"down"])
                {
                    return;
                    
                }
                break;
                
            }
        }
        
        // vote (plus) only when user has not voted it yet.
        void(^saveBlock)(BOOL succeeded, NSError *error) = ^(BOOL succeeded, NSError *error)
        {
            if (succeeded){
                PFQuery *query2 = [PFQuery queryWithClassName:@"AnonymousPost"];
                
                // Retrieve the object by id
                
                [query2 getObjectInBackgroundWithId:tempObject.objectId block:^(PFObject *anoPostObject, NSError *error) {
                    
                                        NSString *postCount = anoPostObject[@"voteCount"];
                    
                    if ([postCount intValue] > V_MIN_POST_DOWN_VOTE_LIMIT) {
                        postCount = [NSString stringWithFormat:@"%d", [postCount intValue] - 1];
                                                anoPostObject[@"voteCount"] = postCount;
                        [tempObject setObject:postCount forKey:@"voteCount"];
                        [feedsTableView reloadData];
                        [anoPostObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                            if (succeeded)
                            {
                                self.lastPositionOffset = feedsTableView.contentOffset;
                                [self loadFeedData];
                            }
                        }];
                    }else{
                        [anoPostObject deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                            if (succeeded)
                            {
                                self.lastPositionOffset = feedsTableView.contentOffset;
                                [self loadFeedData];
                                return;
                            }
                        }];
                    }
                }];
            }
        };
        
                if (bAlreadyVoted) {
            if ([curPost[@"status"] isEqualToString:@"up"]) {
                PFQuery *query = [PFQuery queryWithClassName:@"APostVoteTable"];
                
                // Retrieve the object by id
                [query getObjectInBackgroundWithId:curPost.objectId block:^(PFObject *postObject, NSError *error) {
                    
                    postObject[@"votedValue"] = [NSNumber numberWithInt:0];
                    postObject[@"status"] = @"down";
                    postObject[@"voteUser"] = user;
                    
                    [postObject saveInBackgroundWithBlock:saveBlock];
                }];
            }
        }else  {
            PFObject *postObject = [PFObject objectWithClassName:@"APostVoteTable"];
            postObject[@"postId"] = tempObject;
            postObject[@"voteUser"] = user;
            postObject[@"votedValue"] = [NSNumber numberWithInt:0];
            postObject[@"status"] = @"down";
            [postObject saveInBackgroundWithBlock:saveBlock];
        }
    }];
}

- (void)comments:(UIButton*)sender{
    PFObject *tempObject = [tableContentsList objectAtIndex:sender.tag];
    
    NSString *userId = [NSString stringWithFormat:@"-%@-", tempObject[@"User"]];
    NSString *blockedUser = [[PFUser currentUser] objectForKey:@"blockedUser"];
    if (blockedUser && [blockedUser containsString:userId]) {
        return;
    }
    
    CommentsViewController *dest = [self.storyboard instantiateViewControllerWithIdentifier:@"CommentsViewController"];
    dest.postObject = tempObject;
    self.lastPositionOffset = feedsTableView.contentOffset;
    [self.navigationController pushViewController:dest animated:YES];
    self.navigationController.navigationBarHidden = NO;
}

//Redirect comment bas on Post from Post notification when User tap
- (void) redirectToComment :(PFObject*)postObject {
    //Process to show personal post when user redirect to here
    if(!tableContentsList) {
        tableContentsList = [NSMutableArray new];
    } else {
        [tableContentsList removeAllObjects];
    }
    [tableContentsList addObject:postObject];
    if (_IsStayAtPersonPost) {
        [feedsTableView reloadData];
    } else {
        CommentsViewController *dest = [self.storyboard instantiateViewControllerWithIdentifier:@"CommentsViewController"];
        dest.postObject = postObject;
        _isShowOwnerPost = TRUE;
        self.lastPositionOffset = feedsTableView.contentOffset;
        [self.navigationController pushViewController:dest animated:YES];
        self.navigationController.navigationBarHidden = NO;
    }
    
}

- (void)showFlagView:(UIButton*)sender{
    
    
    [blockSwitch setOn:NO];
     
    flagIndex = sender.tag;
    PFObject *tempObject = [tableContentsList objectAtIndex:flagIndex];
    
    if([((UIButton*)sender).titleLabel.text isEqualToString:@"Flagged"])
    {
        [BATUtil showAlertWithMessage:M_POST_ALREADY_FLAGGED title:@"Help Us Out!"];
        
        return;
    }
    
    PFUser *user = [PFUser currentUser];
    PFRelation *relation = [user relationForKey:@"testBlockedUsers"];
    
    [[relation query] findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        [objects enumerateObjectsUsingBlock:^(PFObject *blockedUser, NSUInteger idx, BOOL *stop) {
            if ([blockedUser[@"userID"] isEqualToString:tempObject[@"User"]]) {
                [blockSwitch setOn:YES];
            }
        }];
        
    }];
    

    [flagView setHidden:NO];
}

- (IBAction)Flag:(id)sender{
    PFObject *tempObject = [tableContentsList objectAtIndex:flagIndex];
    PFQuery *query2 = [PFQuery queryWithClassName:@"AnonymousPost"];
    // Retrieve the object by id
    
    
    [query2 getObjectInBackgroundWithId:tempObject.objectId block:^(PFObject *anoPostObject, NSError *error) {
        
        anoPostObject[@"flagged"] = @"Y";
        
        [anoPostObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded)
            {
                [flagView setHidden:YES];
                tempObject[@"flagged"] = @"Y";
                [feedsTableView reloadData];
                
            }
            
            else {
                [BATUtil showAlertWithMessage:@"An error occured flagging the post, please try again." title:@"Oops!"];
            }
        }];
    }];
    
}

-(void ) didExit
{
    flagView.hidden = YES;
}

- (IBAction)Block:(UISwitch*)sender{

    PFUser *user = [PFUser currentUser];
    
    PFObject *tempObject = [tableContentsList objectAtIndex:flagIndex];
    
    
    NSString *userId = tempObject[@"User"];
    userId = [NSString stringWithFormat:@"%@", userId];
//    NSString *blockedUser = user[@"blockedUser"];
    
    PFObject *blockedUser = [PFObject objectWithClassName:@"testBlockUser"];
    blockedUser[@"userID"] = userId;
    
    PFRelation *relation = [user relationForKey:@"testBlockedUsers"];

    if (sender.isOn) {
        
        blockedUser[@"parent"] = user;
    
        [blockedUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            
            if (succeeded) {
                
                [relation addObject:blockedUser];
                
                [self saveBlockedUserWithUser:user];
                
            } else {
                [BATUtil showAlertWithMessage:@"User could not be blocked, please try again." title:@"Oops!"];
            }

        }];
        
 
        
    } else {

        [[relation query] findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            
            [objects enumerateObjectsUsingBlock:^(PFObject *obj, NSUInteger idx, BOOL *stop) {
                if ([blockedUser[@"userID"] isEqualToString: obj[@"userID"]]) {
                    blockedUser[@"parent"] = nil;
                    [relation removeObject:blockedUser];
                }
                
                if (stop) [self saveBlockedUserWithUser:user];
            }];
            
          
        }];
    }




}

- (void)saveBlockedUserWithUser:(PFUser *)user
{
    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded)
        {
            [self loadFeedData];
            
            [flagView setHidden:YES];
        }
        else
        {
            [BATUtil showAlertWithMessage:@"User could not be blocked, please try again." title:@"Oops!"];
            
        }
    }];
}


-(UIImage * ) scaleImage: (UIImage * ) image toSize: (CGSize) targetSize {
    
    CGFloat scaleFactor = 1.0;
    if (image.size.width > targetSize.width || image.size.height > targetSize.height)
        if (!((scaleFactor = (targetSize.width / image.size.width)) > (targetSize.height / image.size.height))) //scale to fit width, or
            scaleFactor = targetSize.height / image.size.height; // scale to fit heigth.
    UIGraphicsBeginImageContext(targetSize);
    CGRect rect = CGRectMake((targetSize.width - image.size.width * scaleFactor) / 2, (targetSize.height - image.size.height * scaleFactor) / 2,
                             image.size.width * scaleFactor, image.size.height * scaleFactor);
    [image drawInRect: rect];
    UIImage * scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

-(void) setViewEmptyTable
{
    if(tableContentsList.count == 0)
    {
        emptyCellView.hidden = NO;
    }
    
    else{
        emptyCellView.hidden = YES;
    }
}
#pragma mark - UITableView Detasource & Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    //[self setViewEmptyTable];
    return tableContentsList.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return CELL_HEIGHT;//self.view.frame.size.width * 0.9;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    
    UIView *borderView = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                                  0,
                                                                  self.view.frame.size.width,
                                                                  2)];
    borderView.backgroundColor = [UIColor colorWithRed:0.49 green:1.0 blue:0.87 alpha:1.0];
    
    return borderView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    return 0.0f;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellIdentifier = @"postFeedCell";
    PostCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    PFObject *tempObject = [tableContentsList objectAtIndex:indexPath.section];
    PFUser *user = [PFUser currentUser];
    
    if(!cell)
        cell = (PostCell *)[[[NSBundle mainBundle] loadNibNamed:@"PostCell" owner:self options:nil] objectAtIndex:0];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    
    //main photo
    PFFile *thumbImgFile = tempObject[@"thumbImage"];
    NSString *thumbUrl = thumbImgFile.url;
    //cell.imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, CELL_HEIGHT - 35)]; // Original source
    cell.imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, CELL_HEIGHT - 45)]; // Temp
    CGRect viewBottomCellFrame = cell.viewBottomCell.frame;
   /* cell.viewBottomCell.frame = CGRectMake(viewBottomCellFrame.origin.x,
                                           viewBottomCellFrame.origin.y,
                                           viewBottomCellFrame.size.width,
                                           viewBottomCellFrame.size.height);*/
    
    
    //[cell.imgView sd_setImageWithURL:[NSURL URLWithString:[thumbUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] placeholderImage:nil];
    [cell.imgView setUserInteractionEnabled:YES];
    [cell.imgView sd_setImageWithURL:[NSURL URLWithString:[thumbUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]
                           completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                               if (cell.imgView.frame.size.height != cell.imgView.image.size.height)
                               {
                                   [cell.imgView setImage:[self scaleImage:image toSize:cell.imgView.frame.size]];
                               }
                           }];
    
    
    cell.imgView.contentMode = UIViewContentModeScaleAspectFit; /// original
    [cell insertSubview:cell.imgView atIndex:0];
    
    
    
    //headline
    [cell.headlineLabel setHidden:NO];
    cell.headlineLabel.text = tempObject[@"postTitle"];
    if (cell.headlineLabel.text.length < 1)
    {
        [cell.headlineLabel setHidden:YES];
    }
    
    // number of comments (action to comments page)
    NSString *commentSuffix = [[NSString alloc] init];
    long numComments = [[tempObject objectForKey:@"commentCount"] longValue];
    
    if ([[tempObject objectForKey:@"commentCount"] longValue] > 1 || [[tempObject objectForKey:@"commentCount"] longValue] == 0)
        commentSuffix = [[Localization sharedInstance] localizedStringForKey:@"Comments"];
    else
        commentSuffix = @"Comment";
    
    [cell.commentsButton setTitle:[NSString stringWithFormat:@"%lu %@", numComments, commentSuffix]
                         forState:UIControlStateNormal];
    
    // time difference
    [self calTimeDifference:tempObject.createdAt];
    
    NSString *tempday, *temphour, *tempMin, *tempSec;
    if (hour < 1){
        if (min < 1) {
            tempSec = [NSString stringWithFormat:@"%lu s", sec];
            cell.timeLabel.text = tempSec;
        }else{
            tempMin = [NSString stringWithFormat:@"%lu m", min];
            cell.timeLabel.text = tempMin;
        }
    }else{
        temphour = [NSString stringWithFormat:@"%lu h", hour];
        cell.timeLabel.text = temphour;
        
        if (hour>23) {
            tempday = [NSString stringWithFormat:@"%lu d", day];
            cell.timeLabel.text = tempday;
        }
    }
    
    if(day > 365)
        cell.timeLabel.text = @"More than 1y";
    else if (day > 7)
    {
        NSInteger month,daysWhithoutMonth,dWeeks,dDays;
        month = 0;
        daysWhithoutMonth = 0;
        dWeeks = 0;
        dDays = 0;
        if(day > 30)
        {
            month = day/30;
            daysWhithoutMonth = day - month*30;
        }
        else
            daysWhithoutMonth = day;
        
        if(daysWhithoutMonth > 7)
        {
            dWeeks = daysWhithoutMonth/7;
            dDays = daysWhithoutMonth - dWeeks;
        }
        else
            dDays = day;
        
        NSString* outLine = @"";
        if(month>0)
            outLine = [outLine stringByAppendingFormat:@"%lu mth ",(long)month];
        if(dWeeks > 0)
            outLine = [outLine stringByAppendingFormat:@"%lu w ",(long)dWeeks];
        if(dDays >0)
            outLine = [outLine stringByAppendingFormat:@"%lu d",(long)dDays];
        
        cell.timeLabel.text = outLine;
    }
    
    cell.numVotesLabel.text = [NSString stringWithFormat:@"%d",[[tempObject objectForKey:@"voteCount"] intValue]];
    
    [cell.upVoteButton addTarget:self action:@selector(plusVote:) forControlEvents:UIControlEventTouchUpInside];
    [cell.downVoteButton addTarget:self action:@selector(downVote:) forControlEvents:UIControlEventTouchUpInside];
    [cell.commentsButton addTarget:self action:@selector(comments:) forControlEvents:UIControlEventTouchUpInside];
    [cell.flagButton addTarget:self action:@selector(showFlagView:) forControlEvents:UIControlEventTouchUpInside];
    [cell.deleteButton addTarget:self action:@selector(deletePost:) forControlEvents:UIControlEventTouchUpInside];
    [cell.playButton addTarget:self action:@selector(playVideo:) forControlEvents:UIControlEventTouchUpInside];
    
    cell.upVoteButton.tag = indexPath.section;
    cell.downVoteButton.tag = indexPath.section;
    cell.commentsButton.tag = indexPath.section;
    cell.flagButton.tag = indexPath.section;
    cell.deleteButton.tag = indexPath.section;
    
    //delete button
    if ([tempObject[@"User"] isEqualToString:user.objectId]){
        [cell.deleteButton setHidden:NO];
        [cell.flagButton setHidden:YES];
    }
    
    else{
        [cell.deleteButton setHidden:YES];
        [cell.flagButton setHidden:NO];
        
        
        if(![tempObject[@"flagged"] isEqualToString:@"Y"])
        {
            [cell.flagButton setFrame:cell.deleteButton.frame];
            [cell.flagButton setTitle:@"       " forState:UIControlStateNormal];
            [cell.flagButton setImage:[UIImage imageNamed:@"flag.png"] forState:UIControlStateNormal];
        }
        
        
        
        
    }
    
    
    
    
    //play button
    if ([tempObject[@"mediaType"] isEqualToString:@"Photo"])
        [cell.playButton setHidden:YES];
    else
        [cell.playButton setHidden:NO];
    
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    PFObject *infoDict = tableContentsList[indexPath.section];

    NSString *userId = [NSString stringWithFormat:@"-%@-", infoDict[@"User"]];
    NSString *blockedUser = [[PFUser currentUser] objectForKey:@"blockedUser"];
    if (blockedUser && [blockedUser containsString:userId]) {
        return;
    }
    
    if ([infoDict[@"mediaType"] isEqualToString:@"Photo"]) {
        PFFile *imgFile = infoDict[@"thumbImage"];
        [contentImgView sd_setImageWithURL:[NSURL URLWithString:imgFile.url] placeholderImage:nil];
        
        contentImgView.clipsToBounds =YES;
        
        enlargedView.frame = CGRectMake(CGRectGetMinX(enlargedView.frame),
                                        CGRectGetMinY(enlargedView.frame),
                                        CGRectGetWidth(enlargedView.frame),
                                        CGRectGetHeight(enlargedView.frame) + 100);
        
        [enlargedView setHidden:NO];
    }else if ([infoDict[@"mediaType"] isEqualToString:@"Video"]){
        NSLog(@"%@", infoDict[@"postVideo"]);
        PFFile *videoFile = infoDict[@"postVideo"];
        
        PBJVideoPlayerController *controller = [[PBJVideoPlayerController alloc] init];
        controller.videoPath = videoFile.url;
        controller.delegate = self;
        controller.view.backgroundColor = [UIColor whiteColor];
        controller.videoFillMode = AVLayerVideoGravityResizeAspectFill;
        [self.navigationController pushViewController:controller animated:NO];
    }
    
    
    //    [SVProgressHUD dismiss];
}



- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.refreshControl.isRefreshing && !isRefreshingAnimating_)
    {
        NSLog(@"Start Pupil Animation");
    }
    
    self.refreshControl.hidden = FALSE;
    NSInteger yOffset = scrollView.contentOffset.y;
    
    if (yOffset < -59)
    {
//        NSLog(@"yOffset %ld",yOffset);
        NSLog(@"Scroll Up");
        
        self.refreshControl.frame = CGRectMake(self.refreshControl.frame.origin.x, self.originalFrame.origin.y + yOffset, self.refreshControl.frame.size.width, self.refreshControl.frame.size.height);
        refreshLoadingView_.frame = self.refreshControl.bounds;
        
    }
    
    if (yOffset > -60)
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
    
    
    
    
    if (yOffset < -59)
    {
        NSLog(@"ANIMATION START");
        [self startPupilAnimation];
        
            }
    else
    {
        
        if(isRefreshingAnimating_ && !self.refreshControl.refreshing && (scrollView.contentOffset.y > -40))
        {
            NSLog(@"ANIMATION STOP");
            [self resetAnimation];
        }
    }
    
    
    self.yOffset = scrollView.contentOffset.y;
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    
    
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    
}


-(void)hidetopandbottombar
{
    NSLog(@"hide topbar called");
    NSLog(@"Move Direction: %d", moveDirection);
    
    if (moveDirection == 1){
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showtopandbottombar) object:nil];
    }
    else if (moveDirection == 2){
        return;
    }
    
    moveDirection = 2;
    [self performSelectorOnMainThread:@selector(showHideBar:) withObject:@(NO) waitUntilDone:NO];
}

-(void)showtopandbottombar
{
    NSLog(@"showtopandbottombar called");
    NSLog(@"Move Direction: %d", moveDirection);
    
    if (moveDirection == 2) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hidetopandbottombar) object:nil];
    }else if (moveDirection == 1){
        return;
    }
    
    moveDirection = 1;
    
    //    NSLog(@"show topbar called");
    [self performSelectorOnMainThread:@selector(showHideBar:) withObject:@(YES) waitUntilDone:NO];
}


- (NSString*)getYMDFormatFromDate:(NSDate*)date{
    NSString *dateString = [[NSString alloc] init];
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd"; // HH:mm:ss ZZZ
    dateString = [dateFormatter stringFromDate:date];
    return dateString;
}

- (void)playVideo:(id)sender{
    }


#pragma mark - UITextField / UITextView delegate methods
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if ([string isEqualToString:@"\n"]) {
        [textField resignFirstResponder];
    }
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView{
    textView.text = @"";
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
    }
    return YES;
}

#pragma mark - PBJVideoController Delegate
- (void)videoPlayerReady:(PBJVideoPlayerController *)videoPlayer{
    //    [SVProgressHUD show];
    NSLog(@"1");
}

- (void)videoPlayerPlaybackStateDidChange:(PBJVideoPlayerController *)videoPlayer{
    NSLog(@"2");
}

- (void)videoPlayerPlaybackWillStartFromBeginning:(PBJVideoPlayerController *)videoPlayer{
    NSLog(@"3");
}

- (void)videoPlayerPlaybackDidEnd:(PBJVideoPlayerController *)videoPlayer{

    [self.navigationController popViewControllerAnimated:YES];
    NSLog(@"4");
}

@end