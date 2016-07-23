//
//  CalendarViewController.h
//  Seik
//
//  Created by Gavin on 10/26/14.
//  Copyright (c) 2014 Seik, Inc. All rights reserved.
//

#import "FriendRequestViewController.h"
#import <Parse/Parse.h>
#import "AppDelegate.h"
#import "iSociety.h"
#import "Localization.h"
#import "FriendRequestCustomCell.h"

@interface FriendRequestViewController ()

@end

@implementation FriendRequestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [AppDelegate sharedAppDelegate].controllerRef = self;
    
    [self customiseView];
//    [self addDashboardButton];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [self performSelector:@selector(fetchFriendRequests) withObject:nil afterDelay:1.0];
}

-(void)fetchFriendRequests
{
    [ProgressHUD show:[NSString stringWithFormat:@"%@...", [[Localization sharedInstance] localizedStringForKey:@"Fetching Friends"]] Interaction:YES];

    PFUser *currentUser = [PFUser currentUser];
    PFQuery *query = [[PFQuery alloc]initWithClassName:@"FriendRequest"];
    [query whereKey:@"touser" equalTo:currentUser.username];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{

        if(error)
        {
            NSLog(@"Error Occured...");
        }
        else
        {
            if([objects count] > 0)
            {
                NSLog(@"Objects Array : %@",objects);
                //Make sort creattedAt
                NSSortDescriptor* createdAtDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:FALSE];
                dataArray = [objects sortedArrayUsingDescriptors:[NSArray arrayWithObject:createdAtDescriptor]];
            }
        }
        
        [ProgressHUD dismiss];
        [myTableView reloadData];
        });
    }];
}

-(void)addDashboardButton{
    UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Dashboard.png"] style:UIBarButtonItemStyleDone target:[AppDelegate sharedAppDelegate] action:@selector(menuClick:)];
    
    self.navigationItem.leftBarButtonItem = menuButton;
}

-(void)customiseView{
    [AppDelegate sharedAppDelegate].controllerRef = self;
    [self customiseValues];
    
    ADBannerView *adView = [[ADBannerView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 163, self.view.frame.size.width + 10, 50)];
    [self.view addSubview:adView];
}

-(void)customiseValues{
    self.title = [[Localization sharedInstance] localizedStringForKey:@"Added Me"];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"Number of rows....");
//    [AppDelegate sharedAppDelegate].isLoggedIn = YES;
    self.view.userInteractionEnabled = YES;
    self.view.window.userInteractionEnabled = YES;
    return [dataArray count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Cell For Rows...");
    static NSString *cellIdentifier = @"Cell";
    FriendRequestCustomCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(cell==nil)
    {
        cell = (FriendRequestCustomCell *)[[[NSBundle mainBundle] loadNibNamed:@"FriendRequestCustomCell" owner:self options:nil] objectAtIndex:0];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    PFObject *object = [[PFObject alloc]initWithClassName:@"FriendRequest"];
    NSLog(@"Object : %@",object);
    object = [dataArray objectAtIndex:indexPath.row];
    
    cell.lblFriendName.text = [object[PF_FROM_USER] capitalizedString];
    
    cell.btnAccept.tag = indexPath.row;
    cell.btnDecline.tag = indexPath.row;
    
    [cell.btnAccept addTarget:self action:@selector(acceptFriend:) forControlEvents:UIControlEventTouchUpInside];
    [cell.btnDecline addTarget:self action:@selector(declineFriend:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

-(void)acceptFriend:(UIButton *)sender
{
    //@System Integration...
    //Accept the friend request....
    PFObject *object = [dataArray objectAtIndex:sender.tag];
    PFQuery *query = [PFQuery queryWithClassName:@"Friends"];
    [query whereKey:@"currentUserID" equalTo:object[PF_FROM_USER_ID]];
    [query whereKey:@"friendsUserID" equalTo:object[PF_TO_USER_ID]];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(error){
            NSLog(@"Error occured...");
        }
        else
        {
            NSLog(@"Array : %@",objects);
            if([objects count] > 0)
            {
                //Modify the friend request record in Friend Class in Parse...
                PFObject *friendObject = [objects objectAtIndex:0];
                friendObject[PF_STATUS] = [NSNumber numberWithBool:TRUE];
                [friendObject saveInBackgroundWithBlock:^(BOOL success,NSError *error){
                    if(success)
                    {
                        NSLog(@"Now you are friends...");
                        //Delete the friend request record from FriendRequest class on Parse...
                        [object deleteInBackgroundWithBlock:^(BOOL success,NSError *error){
                            
                            dataArray = nil;
                            //Refetch friend list and fetch the remaining requests...
                            [self fetchFriendRequests];
                        }];

                    }
                    else
                    {
                        NSLog(@"Error Occured...");
                    }
                    
                }];
            }
        }
    }];
}

-(void)declineFriend:(UIButton *)sender
{
    //@System Integration...
    //Decline the friend request...
    PFObject *object = [dataArray objectAtIndex:sender.tag];
    PFQuery *query = [PFQuery queryWithClassName:@"Friends"];
    [query whereKey:@"currentUserID" equalTo:object[PF_FROM_USER_ID]];
    [query whereKey:@"friendsUserID" equalTo:object[PF_TO_USER_ID]];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(error)
        {
            NSLog(@"Error occured...");
        }
        else
        {
            if([objects count] > 0)
            {
                //Delete the record from FriendRequest class...
                PFObject *friendObject = [objects objectAtIndex:0];
                [friendObject deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (succeeded) {
                        [object deleteInBackgroundWithBlock:^(BOOL success,NSError *error){
                            
                            dataArray = nil;
                            [self fetchFriendRequests];
                        }];
                    }
                }];
            }
        }
    }];
}

@end
