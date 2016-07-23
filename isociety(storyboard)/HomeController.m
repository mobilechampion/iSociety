//
//  HomeController.m
//  Seik
//
//  Created by Gavin on 10/26/14.
//  Copyright (c) 2014 Seik, Inc. All rights reserved.
//

#import "HomeController.h"
#import "iSociety.h"
#import "ProfileViewController.h"
#import "FriendsController.h"
#import "HomeTableCell.h"
#import "LoginViewController.h"
#import "CustomNavigationController.h"
#import "Localization.h"
#import "LoginViewController.h"
#import "ChatPortalViewController.h"

@interface HomeController ()
{
    NSMutableArray *usersArray,*friendsArray;
}
@end

@implementation HomeController
@synthesize from;
@synthesize to;
@synthesize ignoreDrag;

- (void)viewDidLoad {
    [super viewDidLoad];

    //[self customiseValues];
    
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
    
//    UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Dashboard.png"] style:UIBarButtonItemStyleDone target:[AppDelegate sharedAppDelegate] action:@selector(menuClick:)];
//    self.navigationItem.leftBarButtonItem = menuButton;
//    self.navigationItem.hidesBackButton = YES;
    self.navigationController.navigationBarHidden = NO;
    
//    adView = [[ADBannerView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 163, self.view.frame.size.width, 50)];
//    adView = [[ADBannerView alloc] initWithAdType:ADAdTypeMediumRectangle];
//    [self.view addSubview:adView];
    
    
    self.imgIndicatorarrow = [[UIImageView alloc] initWithFrame:CGRectMake(76,adView.frame.origin.y - 60, 40, 60)];
    self.lblIndicator = [[UILabel alloc] initWithFrame:CGRectMake(20, self.imgIndicatorarrow.frame.origin.y- 30, self.view.frame.size.width-20, 30) ];
    self.imgIndicatorarrow.image =[UIImage  imageNamed:@"arrow.png"];
    self.imgIndicatorarrow.contentMode = UIViewContentModeScaleAspectFit;
    self.lblIndicator.text =@"Add Friends!";
    [self.view addSubview:self.imgIndicatorarrow];
    [self.view addSubview:self.lblIndicator];
    self.imgIndicatorarrow.hidden = YES;
    self.lblIndicator.hidden = YES;
    
}

- (void)customiseValues{
    self.title = [[Localization sharedInstance] localizedStringForKey:@"Home"];
    
    [self.tabBarController.viewControllers[1] setTitle:[[Localization sharedInstance] localizedStringForKey:@"Friends"]];
    [self.tabBarController.viewControllers[2] setTitle:[[Localization sharedInstance] localizedStringForKey:@"Anonymous"]];
    [self.tabBarController.viewControllers[3] setTitle:[[Localization sharedInstance] localizedStringForKey:@"Notifications"]];
    [self.tabBarController.viewControllers[4] setTitle:[[Localization sharedInstance] localizedStringForKey:@"My Calendar"]];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [ProgressHUD dismiss];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [AppDelegate sharedAppDelegate].controllerRef = self;

    //Prakash: Refer AppDelegate
    //if (![AppDelegate sharedAppDelegate].isLoggedIn) {
    //Prakash: If current user is nil thats mean non of the session was initiated.
    if ([PFUser currentUser] == nil) {
        LoginViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
        CustomNavigationController *navigationController = [[CustomNavigationController alloc] initWithRootViewController:viewController];
        [self.navigationController presentViewController:navigationController animated:NO completion:nil];
    }
    PFUser *user = [PFUser currentUser];
    NSLog(@"status = %@", user[PF_USER_AVIALABLITY]);
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];

    if ([PFUser currentUser] && _AutoRedirectToChat == FALSE) {
        [self getFriends];
    }
    [self.tableView reloadData];
}

-(void)displayAddFriendInstruction:(BOOL)bVisible{
    self.imgIndicatorarrow.hidden = !bVisible;
        self.lblIndicator.hidden = !bVisible;
}

- (void)getFriends{
    usersArray = [[NSMutableArray alloc] init];
    [ProgressHUD show:[NSString stringWithFormat:@"%@...",[[Localization sharedInstance] localizedStringForKey:@"Fetching Data"]] Interaction:NO];
    PFQuery *friendQuery = [PFQuery queryWithClassName:@"Friends"];
    //@System Integration...

    //Changed the parameters to get all friends, either I have sent them request or they have sent me friend request...
    [friendQuery whereKey:PF_CHATROOMS_ROOM containsString:[PFUser currentUser].objectId];
    //Added a field in database to manage the friend request status... If it is accepted then only it is counted as friend...
    [friendQuery whereKey:PF_STATUS equalTo:@YES];
    
    [friendQuery findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
        // results contains players with lots of wins or only a few wins.
        if (!error && results.count)  {
            friendsArray = [[NSMutableArray alloc] initWithArray:results];
            if ([friendsArray count] > 0) {
                self.imgIndicatorarrow.hidden = YES;
                self.lblIndicator.hidden = YES;
            } else {
                self.imgIndicatorarrow.hidden = NO;
                self.lblIndicator.hidden = NO;
            }
            for (PFObject *friend in results) {
                PFQuery *query = [PFUser query];
                //@System Integration...
                //Check the user id and make request to get the friend request record from Friend class on parse...
                if([friend[PF_USER_FRIEND_ID] isEqualToString:[PFUser currentUser].objectId]){
                    [query whereKey:PF_USER_OBJECTID equalTo:friend[PF_USER_ID]];
                }
                else{
                    [query whereKey:PF_USER_OBJECTID equalTo:friend[PF_USER_FRIEND_ID]];
                }
                [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                    [usersArray addObjectsFromArray:objects];
                    
                    [self.tableView reloadData];
                }];
            }
            [ProgressHUD shared].interaction = YES;
            [ProgressHUD dismiss];
            [self.tableView reloadData];
        }else if(error){
            [ProgressHUD showError:[[Localization sharedInstance] localizedStringForKey:@"Error On Fetching Your Friend list"]];
            [ProgressHUD shared].interaction = YES;
            [ProgressHUD dismiss];
            self.imgIndicatorarrow.hidden = NO;
            self.lblIndicator.hidden = NO;
        }
        else{
//            [ProgressHUD showError:[[Localization sharedInstance] localizedStringForKey:@"No Friends To Display!"]];
            [ProgressHUD shared].interaction = YES;
            [ProgressHUD dismiss];
            self.imgIndicatorarrow.hidden = NO;
            self.lblIndicator.hidden = NO;
        }
    }];
    self.navigationItem.title = @"Home";
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    BOOL displayAddFrindArrow = usersArray.count == 0 ? YES : NO;
//    displayAddFrindArrow = YES;
    [self displayAddFriendInstruction:displayAddFrindArrow];
    
    return usersArray.count;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{

    NSLog(@"home screen started");
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *strCellIdentifier = [NSString stringWithFormat:@"Cell-%ld-%ld",(long)indexPath.section,(long)indexPath.row];
    HomeTableCell *cell = [tableView dequeueReusableCellWithIdentifier:strCellIdentifier];
    cell = nil;

    if (!cell) {
        cell = [[HomeTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:strCellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    PFUser *user = usersArray[indexPath.row];

    // USerName
    UILabel *titleLabel = [BATUtil initLabelWithFrame:CGRectMake(10, 10, [UIScreen mainScreen].bounds.size.width-80, 25) text:[user.username capitalizedString] textAlignment:NSTextAlignmentLeft textColor:[UIColor blackColor] font:[UIFont fontWithName:@"HelveticaNeue-Thin" size:18]];
    [cell.contentView addSubview:titleLabel];
    
    
//    NSLog(@"%lu", [user[PF_USER_AVIALABLITY] integerValue]);
    
    UIButton *cellButton =  [UIButton buttonWithType:UIButtonTypeCustom];
    cellButton.frame = CGRectMake([UIScreen mainScreen].bounds.size.width-50, 15, 20, 30);
 
    cellButton.userInteractionEnabled = NO;
    [cell.contentView addSubview:cellButton];

    // Configure the cell...
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    [self performSegueWithIdentifier:@"chat" sender:self];
    PFUser *user = usersArray[indexPath.row];
    
    //NSPredicate *predct = [NSPredicate predicateWithFormat:
    //                       @"currentUserID == %@ && friendsUserID == %@",[PFUser currentUser].objectId, user.objectId];//AND friendsUserID == %@ ,user.objectId
    //NSArray *tempArray = [friendsArray filteredArrayUsingPredicate:predct];
    PFObject* object = nil;
    for (PFObject *friend in friendsArray) {
        if([friend[PF_USER_FRIEND_ID] isEqualToString:[PFUser currentUser].objectId] && [friend[PF_USER_ID] isEqualToString:user.objectId]){
            object = friend;
            break;
        } else if([friend[PF_USER_ID] isEqualToString:[PFUser currentUser].objectId] && [friend[PF_USER_FRIEND_ID] isEqualToString:user.objectId]){
            object = friend;
            break;
        }
    }
    
    //Need o validate here
    if (object) {
        
        ChatPortalViewController *chatController = [self.storyboard instantiateViewControllerWithIdentifier:@"ChatPortalViewController"];
        
        chatController.titleStr = [user.username capitalizedString];
        chatController.chatRoomID = object[PF_CHAT_ROOM];
        chatController.user = user;
        [self.navigationController pushViewController:chatController animated:YES];
    }
    
}
/* */
//-(UIImage *)getPersonStatus:(NSInteger)statusCode{
//    switch (statusCode) {
//        case kStatusAvailable:
//            return [UIImage imageNamed:@"green"];
//            break;
//        case kStatusIdle:
//            return [UIImage imageNamed:@"orange"];
//            break;
//        case kStatusBusy:
//            return [UIImage imageNamed:@"red"];
//            break;
//    }
//    return nil;
//}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"chat"])
    {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        PFUser *user = usersArray[indexPath.row];
        
        NSPredicate *predct = [NSPredicate predicateWithFormat:
                                  @"currentUserID == %@ AND friendsUserID == %@",[PFUser currentUser].objectId,user.objectId];
        NSArray *tempArray = [friendsArray filteredArrayUsingPredicate:predct];
        
        PFObject *object = tempArray[0];
        ChatViewController *chatController = [segue destinationViewController];
        chatController.titleStr = [user.username capitalizedString];
        chatController.chatRoomID = object[PF_CHAT_ROOM];
    }
}

- (void) redirectToChatRoom:(PFUser*)userChat {
    
    if(!usersArray) {
        usersArray = [NSMutableArray new];
    }
    [ProgressHUD show:[NSString stringWithFormat:@"%@...",[[Localization sharedInstance] localizedStringForKey:@"Fetching Data"]] Interaction:NO];
    PFQuery *friendQuery = [PFQuery queryWithClassName:@"Friends"];
    //@System Integration...
    
    //Changed the parameters to get all friends, either I have sent them request or they have sent me friend request...
    [friendQuery whereKey:PF_CHATROOMS_ROOM containsString:[PFUser currentUser].objectId];
    //Added a field in database to manage the friend request status... If it is accepted then only it is counted as friend...
    //    [friendQuery whereKey:PF_STATUS equalTo:@YES];
    [friendQuery findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
        // results contains players with lots of wins or only a few wins.
        if (!error && results.count)  {
            friendsArray = [[NSMutableArray alloc] initWithArray:results];
            for (PFObject *friend in results) {
                PFQuery *query = [PFUser query];
                //@System Integration...
                //Check the user id and make request to get the friend request record from Friend class on parse...
                if([friend[PF_USER_FRIEND_ID] isEqualToString:[PFUser currentUser].objectId]){
                    [query whereKey:PF_USER_OBJECTID equalTo:friend[PF_USER_ID]];
                }
                else{
                    [query whereKey:PF_USER_OBJECTID equalTo:friend[PF_USER_FRIEND_ID]];
                }
                [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                    [usersArray addObjectsFromArray:objects];
                    
                    [self.tableView reloadData];
                }];
            }
            [ProgressHUD shared].interaction = YES;
            [ProgressHUD dismiss];
            [self.tableView reloadData];
            dispatch_async(dispatch_get_main_queue(), ^{
                NSPredicate *predct = [NSPredicate predicateWithFormat:
                                       @"currentUserID == %@ AND friendsUserID == %@",userChat.objectId, [PFUser currentUser].objectId];
                NSArray *tempArray = [friendsArray filteredArrayUsingPredicate:predct];
                if(tempArray.count > 0)
                {
                    PFObject *object = tempArray[0];
                    ChatPortalViewController *chatController = [self.storyboard instantiateViewControllerWithIdentifier:@"ChatPortalViewController"];
                    chatController.titleStr = [userChat.username capitalizedString];
                    chatController.chatRoomID = object[PF_CHAT_ROOM];
                    chatController.user = userChat;
                    [self.navigationController pushViewController:chatController animated:YES];

                }
                
            });
        }else if(error){
            [ProgressHUD showError:[[Localization sharedInstance] localizedStringForKey:@"Error On Fetching Your Friend list"]];
        }
        else{
            //[ProgressHUD showError:[[Localization sharedInstance] localizedStringForKey:@"No Friends To Display!"]];
        }
    }];

}

#pragma mark - Autorotation Delegates
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    [self.tableView reloadData];
}


@end
