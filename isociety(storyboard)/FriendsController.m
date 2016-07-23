//
//  FriendsController.m
//  Seik
//
//  Created by Gavin on 10/26/14.
//  Copyright (c) 2014 Seik, Inc. All rights reserved.
//

#import "FriendsController.h"
#import "AppDelegate.h"
#import "iSociety.h"
#import "Localization.h"
#import "ProfileViewController.h"
#import "Helper.h"

#define kFriendsTableViewCellReuse @"FriendsTableViewCell"

//Used to identify the type of action
typedef NS_ENUM(NSUInteger, FriendRequestActionType) {
    FriendRequestActionTypeInvite = 0,
    FriendRequestActionTypeAdd,
    FriendRequestActionTypePending,
    FriendRequestActionTypeAlreadyAdded
};

//Used to identify the type of the users.
typedef NS_ENUM(NSUInteger, ListType) {
    ListTypeUsers = 0,
    ListTypeAddressBookUsers
};

@class FriendsTableViewCell;
typedef void(^AccessoryBtnClickedHandler)(FriendsTableViewCell *_cell);

@interface FriendsTableViewCell : UITableViewCell
@property (nonatomic, assign) FriendRequestActionType friendType;
@property (nonatomic, readonly) UIButton *rightAccessoryBtn;
@property (nonatomic, strong) AccessoryBtnClickedHandler accessoryClickedHandler;


@end

@implementation FriendsTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        UIButton *accessoryBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        accessoryBtn.frame = CGRectMake(0, 0, 60, 32);
        //accessoryBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [accessoryBtn setTitleColor:[UIColor brownColor] forState:UIControlStateNormal];
        [accessoryBtn addTarget:self action:@selector(accessoryBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        self.accessoryView = accessoryBtn;
    }
    return self;
}

- (void) setFriendRequestActionType:(FriendRequestActionType) type {
    switch (type) {
        case FriendRequestActionTypeInvite: {
            [self.rightAccessoryBtn setImage:nil forState:UIControlStateNormal];
            [self.rightAccessoryBtn setTitle:[[Localization sharedInstance] localizedStringForKey:@"Invite"]
                                    forState:UIControlStateNormal];
            break;
        }
        case FriendRequestActionTypeAdd: {
            [self.rightAccessoryBtn setImage:[UIImage imageNamed:@"Adduser"] forState:UIControlStateNormal];
            [self.rightAccessoryBtn setTitle:nil
                                    forState:UIControlStateNormal];
            break;
        }
        case FriendRequestActionTypePending: {
            [self.rightAccessoryBtn setImage:[UIImage imageNamed:@"pendinguser"] forState:UIControlStateNormal];
            [self.rightAccessoryBtn setTitle:nil
                                    forState:UIControlStateNormal];
            break;
        }
        case FriendRequestActionTypeAlreadyAdded: {
            [self.rightAccessoryBtn setImage:[UIImage imageNamed:@"accepted"] forState:UIControlStateNormal];
            [self.rightAccessoryBtn setTitle:nil
                                    forState:UIControlStateNormal];
            break;
        }
        default:
            break;
    }
    
    self.friendType = type;
}

- (UIButton *)rightAccessoryBtn {
    return (UIButton *)self.accessoryView;
}

- (void) accessoryBtnClicked {
    if (self.accessoryClickedHandler) {
        self.accessoryClickedHandler(self);
    }
}

- (void)setAccessoryClickedHandler:(AccessoryBtnClickedHandler) accessoryClickedHandler
{
    _accessoryClickedHandler = accessoryClickedHandler;
}

@end

@interface FriendsController ()<UISearchBarDelegate,UISearchResultsUpdating, UIAlertViewDelegate>
{
    NSArray *parseUsers;
    NSMutableArray *addressBookUsers, *usersArray;
//    BOOL showAddressBook;
    __weak IBOutlet UILabel *toLabel;
    
    __weak IBOutlet UILabel *messageLabel;
    IBOutlet UIView *mailComposerBGView,*mailComposerView;
    IBOutlet UITextView *textView;
    IBOutlet UILabel *toAddressLabel,*topLabel;
    
    IBOutlet UIButton *sendButton,*cancelButton;
    
//    BOOL isSearching;
}

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentControl;
@property (strong, nonatomic) NSMutableArray *myFriends, *friendsArray;

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong) NSMutableArray *searchResults;
@end

@implementation FriendsController

@synthesize from;
@synthesize to;
@synthesize ignoreDrag;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [AppDelegate sharedAppDelegate].controllerRef = self;
    self.navigationController.navigationBarHidden = NO;

    [self customiseView];
//    [self addDashboardButton];
    [self getContacts];
    [self getFriends];
    [self initialiseSearchBar];
    NSLog(@"key string1 = %@", _keyString);
    
    self.usernameLabelOriginalText = self.usernameLabel.text;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    if ([_keyString isEqualToString:@"friends"]) {
        [self removeSearchBar];
    }
    NSLog(@"key string2 = %@", _keyString);
    
    PFUser *user = [PFUser currentUser];

    self.username = [user objectForKey:PF_USER_USERNAME];

    NSString *usernameTextComposed = [NSString stringWithFormat:@"%@ %@", self.username, self.usernameLabelOriginalText];
    self.usernameLabel.text = usernameTextComposed;
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

-(void)getFriends
{
    usersArray = [[NSMutableArray alloc] init];
    [ProgressHUD show:[NSString stringWithFormat:@"%@...",[[Localization sharedInstance] localizedStringForKey:@"Fetching Data"]] Interaction:NO];
    PFQuery *friendQuery = [PFQuery queryWithClassName:@"Friends"];
    
    [friendQuery whereKey:PF_CHATROOMS_ROOM containsString:[PFUser currentUser].objectId];
        [friendQuery findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
        // results contains players with lots of wins or only a few wins.
        if (!error && results.count)  {
            _friendsArray = [[NSMutableArray alloc] initWithArray:results];
            for (PFObject *friend in results) {
                PFQuery *query = [PFUser query];
                //@System Integration...
                //Check the user id and make request to get the friend request record from Friend class on parse...
                
                if([friend[PF_USER_FRIEND_ID] isEqualToString:[PFUser currentUser].objectId])
                {
                    [query whereKey:PF_USER_OBJECTID equalTo:friend[PF_USER_ID]];
                }
                else
                {
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
        }
        else{
           // [ProgressHUD showError:[[Localization sharedInstance] localizedStringForKey:@"No Friends To Display!"]];
            [ProgressHUD shared].interaction = YES;
            [ProgressHUD dismiss];
        }
    }];
}

-(void)getContacts
{
    addressBookUsers = [[NSMutableArray alloc] init];
    
    __weak FriendsController *weakSelf = self;
    
    
    PFQuery *myfriend_query = [PFQuery queryWithClassName:PF_FRIENDS];
    [myfriend_query whereKey:PF_USER_ID equalTo:[PFUser currentUser].objectId];
    [myfriend_query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (objects) {
            weakSelf.myFriends = [NSMutableArray arrayWithArray:objects];
            DLog(@"%@", objects);
        }
        [weakSelf.tableView reloadData];
    }];
    
    PFQuery *query = [PFUser query];
    [query whereKey:PF_USER_OBJECTID notEqualTo:[PFUser currentUser].objectId];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        DLog(@"%@", objects);
        parseUsers = objects;
        
        if (parseUsers.count>0)
            self.usernameLabelParent.alpha = 0.0;
        
        [weakSelf.tableView reloadData];
    }];
    
    
    [self requestAddresBookAuthorizationWithCompletions:^{
        [self getPersonOutOfAddressBook];
        [weakSelf.tableView reloadData];
    } error:^(NSError *error) {
        NSLog(@"AdressBook error:%@", [error description]);
    }];
}



-(void)addDashboardButton
{
    UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Dashboard.png"] style:UIBarButtonItemStyleDone target:[AppDelegate sharedAppDelegate] action:@selector(menuClick:)];
    
    self.navigationItem.leftBarButtonItem = menuButton;
}

-(void)customiseView
{
    
    [AppDelegate sharedAppDelegate].controllerRef = self;
    
    [self customiseValues];
}

-(void)initialiseSearchBar
{
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    
    self.searchBar = self.searchController.searchBar;
    self.searchBar.placeholder = [[Localization sharedInstance] localizedStringForKey:@"Search"];
    [self.searchBar sizeToFit];
    self.tableView.tableHeaderView = self.searchBar;
    
    self.searchController.searchResultsUpdater = self;
    
    self.definesPresentationContext = YES;
    
    self.searchResults = [NSMutableArray array];
    
    self.searchController.delegate = self;
    self.searchController.dimsBackgroundDuringPresentation = NO; // default is YES
    self.searchController.searchBar.delegate = self;
}

- (void)removeSearchBar{
    self.tableView.tableHeaderView = nil;
}

-(void)customiseValues
{
    self.title = [[Localization sharedInstance] localizedStringForKey:@"Friends"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(IBAction)segmentSelect:(UISegmentedControl *)sender
{
    __weak FriendsController *weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (weakSelf.segmentControl.selectedSegmentIndex == ListTypeUsers) {
            weakSelf.tableView.tableHeaderView = self.searchBar;
        } else {
            weakSelf.tableView.tableHeaderView = nil;
        }
        
        
        [weakSelf.tableView reloadData];
    });
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger rows = 0;
    
    if ([_keyString isEqualToString:@"user"]) {
        if (self.searchController.isActive) {
            rows = self.searchResults.count;
        } else {
            rows = parseUsers.count;
        }
    }
    else if ([_keyString isEqualToString:@"contact"]){
        rows = addressBookUsers.count;
    }else if ([_keyString isEqualToString:@"friends"]){
        rows = usersArray.count;
    }

    
    
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FriendsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kFriendsTableViewCellReuse];
    if (cell == nil) {
        cell = [[FriendsTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kFriendsTableViewCellReuse];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    __weak FriendsController *_weakSelf = self;
    
    if ([_keyString isEqualToString:@"user"]) {
        PFUser *user = nil;
        if (self.searchController.isActive) {
            user = [self.searchResults objectAtIndex:indexPath.row];
        }
        else {
            user = [parseUsers objectAtIndex:indexPath.row];
        }
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", PF_USER_FRIEND_ID, user.objectId];
        PFObject *friendIf = [[self.myFriends filteredArrayUsingPredicate:predicate] lastObject];
        if (friendIf) {
            BOOL isMyFriend = [[friendIf objectForKey:PF_STATUS] boolValue];
            if (isMyFriend) {
                //My friend then Added
                [cell setFriendRequestActionType:FriendRequestActionTypeAlreadyAdded];
            } else {
                //If status is false then request is pending
                [cell setFriendRequestActionType:FriendRequestActionTypePending];
            }
        } else {
            //It will be fresh user to whom i can send invite
            [cell setFriendRequestActionType:FriendRequestActionTypeAdd];
        }
        
        [cell setAccessoryClickedHandler:^(FriendsTableViewCell *_cell){
            NSIndexPath *indexPathForCell = [_weakSelf.tableView indexPathForCell:_cell];
            if (_cell.friendType == FriendRequestActionTypeAdd) {
                [_weakSelf addFriendAtIndex:indexPathForCell.row];
            } else if(_cell.friendType == FriendRequestActionTypePending) {
                [_weakSelf editFriendRequestWithIndex:indexPathForCell.row];
            }
        }];
        
        cell.textLabel.text = [user[PF_USER_FULLNAME] capitalizedString];
        cell.detailTextLabel.text = [user objectForKey:PF_USER_USERNAME];
    }else if ([_keyString isEqualToString:@"contact"]){
        Contact *person = [addressBookUsers objectAtIndex:indexPath.row];
        cell.textLabel.text = person.fullName;
        cell.detailTextLabel.text = person.homeEmail ? person.homeEmail : person.workEmail;
        
        [cell setAccessoryClickedHandler:^(FriendsTableViewCell *_cell){
            NSIndexPath *indexPathForCell = [_weakSelf.tableView indexPathForCell:_cell];
            [_weakSelf sendInviteForAddrressBookUserAtIndex:indexPathForCell.row];
        }];
        
        //Set the cell status as Invite for address book users
        [cell setFriendRequestActionType:FriendRequestActionTypeInvite];
    }else if ([_keyString isEqualToString:@"friends"]){
        PFUser *tempDict = usersArray[indexPath.row];
        cell.textLabel.text = tempDict.username;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

-(void)sendInviteForAddrressBookUserAtIndex:(NSInteger) index
{
    Contact *contact = [addressBookUsers objectAtIndex:index];
    if (contact.homeEmail || contact.workEmail) {
        //
        [self sendEmail:contact.homeEmail ? contact.homeEmail : contact.workEmail];
    }
    else{
        [ProgressHUD showError:[[Localization sharedInstance] localizedStringForKey:@"Email is not available for the selected user"]];
    }
}

// Function to be edited for client
- (void)editFriendRequestWithIndex:(NSInteger) index
{
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Edit Friend Request" message:@"Choose the action to perform" delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:@"Resend" , @"Cancel", nil];
    alertView.tag = index;
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    PFUser *selectedUser;
    if (self.searchController.isActive) {
        selectedUser = self.searchResults[alertView.tag];
    }else{
        selectedUser = parseUsers[alertView.tag];
    }
    PFQuery * query = [[PFQuery alloc] initWithClassName:@"Friends"];
    [query whereKey:PF_USER_ID equalTo:[PFUser currentUser].objectId];
    [query whereKey:PF_USER_FRIEND_ID equalTo:selectedUser.objectId];
    switch (buttonIndex) {
        {case 1:
            [ProgressHUD show:@"Resending Request"];
            PFUser* currentUser = [PFUser currentUser];
            PFObject *friend = [PFObject objectWithClassName:@"Friends"];
            friend[PF_USER_ID] = currentUser.objectId;
            friend[PF_USER_FRIEND_ID] = selectedUser.objectId;
            [friend saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!succeeded) {
                    [ProgressHUD showError:[[Localization sharedInstance] localizedStringForKey:@"Unable to add friend, there may be an issue"]];
                }
                
                [Helper sendPushNotificationToUser:selectedUser withMessage:[NSString stringWithFormat:@"%@  sent you a friend request!", currentUser[@"username"]]];
                PFObject *friendRequestObject = [PFObject objectWithClassName:@"FriendRequest"];
                friendRequestObject[PF_FROM_USER] = currentUser.username;
                friendRequestObject[PF_FROM_USER_ID] = currentUser.objectId;
                friendRequestObject[PF_TO_USER] = selectedUser.username;
                friendRequestObject[PF_TO_USER_ID] = selectedUser.objectId;
                friendRequestObject[PF_STATUS] = [NSNumber numberWithInt:1];
                [friendRequestObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    
                    if(succeeded) {
                        NSLog(@"Friend Request sent...");
                        //update local variable.
                        [self.myFriends addObject:friend];
                    }
                    else
                        NSLog(@"Friend request not sent...");
                    
                    [ProgressHUD shared].interaction = YES;
                    [ProgressHUD showSuccess:@"Friend Request Sent"];
                    [self.tableView reloadData];
                }];
            }];
            break;}
        {case 2:
            [ProgressHUD show:@"Cancelling Request"];
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if(!error)
                    for (PFObject * object in objects) {
                        [object deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                            if(succeeded){
                                [ProgressHUD showSuccess:@"Cancelled"];
                                
                                [Helper sendPushNotificationToUser:selectedUser withMessage:@"Your request has been cancelled!"];
                                
                                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", PF_USER_FRIEND_ID, selectedUser.objectId];
                                PFObject *friendIf = [[self.myFriends filteredArrayUsingPredicate:predicate] lastObject];
                                if (friendIf) {
                                    [self.myFriends removeObject:friendIf];
                                }
                                
                                //Update the cell
                                [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:alertView.tag
                                                                                            inSection:0]]
                                                      withRowAnimation:UITableViewRowAnimationAutomatic];
                            }
                        }];
                    }
            }];
            break;}
        default:
            break;
    }
}

-(void)addFriendAtIndex:(NSInteger) index
{
    [ProgressHUD show:[NSString stringWithFormat:@"%@...",[[Localization sharedInstance] localizedStringForKey:@"Sending"]] Interaction:NO];
    PFUser *selectedUser = nil;
    if (self.searchController.isActive) {
        selectedUser = self.searchResults[index];
    }
    else {
        selectedUser = parseUsers[index];
    }
    PFUser *currentUser = [PFUser currentUser];
    PFObject *friend = [PFObject objectWithClassName:@"Friends"];
    friend[PF_USER_ID] = currentUser.objectId;
    friend[PF_USER_FRIEND_ID] = selectedUser.objectId;
    friend[PF_CHAT_ROOM] = [NSString stringWithFormat:@"%@%@",currentUser.objectId,selectedUser.objectId];
    
    [friend saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!succeeded) {
            [ProgressHUD showError:[[Localization sharedInstance] localizedStringForKey:@"Unable To Add Friend, There May Be An Issue"]];
        }
        else
        {
            
            [Helper sendPushNotificationToUser:selectedUser withMessage:[NSString stringWithFormat:@"%@  sent you a friend request!", currentUser[@"username"]]];
            
//            // Send a notification to a particular user... To get particular user detect the channel by installation query...
//            PFQuery *pushQuery = [PFInstallation query];
//            [pushQuery whereKey:@"channels" equalTo:[NSString stringWithFormat:@"test%@",selectedUser.objectId]]; // Set channel
//            
//            // Send push notification to query
//            PFPush *push = [[PFPush alloc] init];
//            [push setQuery:pushQuery];
//            //Draft message to send the push notification including the username who is sending the friend request...
//            [push setMessage:[NSString stringWithFormat:@"%@ has sent you a friend request!",[PFUser currentUser].username]];
//            [push sendPushInBackground];
            
            //Save the friend request in another class on Parse to manage the friends request separately for each user...
            //Add friend request record in FriendRequest class...
            PFObject *friendRequestObject = [PFObject objectWithClassName:@"FriendRequest"];
            friendRequestObject[PF_FROM_USER] = currentUser.username;
            friendRequestObject[PF_FROM_USER_ID] = currentUser.objectId;
            friendRequestObject[PF_TO_USER] = selectedUser.username;
            friendRequestObject[PF_TO_USER_ID] = selectedUser.objectId;
            friendRequestObject[PF_STATUS] = [NSNumber numberWithInt:0];
            friendRequestObject[@"request_status"] = @NO;
            [friendRequestObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                
                if(succeeded) {
                    NSLog(@"Friend Request sent...");
                    //update local variable.
                    [self.myFriends addObject:friend];
                    //update the cell
                    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index
                                                                                inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
                }
                else
                    NSLog(@"Friend request not sent...");
                
                [ProgressHUD shared].interaction = YES;
                [ProgressHUD showSuccess:@"Friend Request Sent"];
            }];
        }
    }];
    
    [self.tableView reloadData];
    [((UITableViewController *)self.searchController.searchResultsController).tableView reloadData];
}

#pragma mark - AdressBook

- (void)requestAddresBookAuthorizationWithCompletions:(void(^)(void))successBlock error:(void(^)(NSError *error))errorBlock
{
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusDenied ||
        ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusRestricted)
    {
        if (errorBlock)
            errorBlock([NSError errorWithDomain:@"Can't Access Your Contacts!" code:0 userInfo:nil]);
    }
    else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized)
    {
        if (successBlock)
            successBlock();
    }
    else
    {
        
        ABAddressBookRequestAccessWithCompletion(ABAddressBookCreateWithOptions(NULL, nil), ^(bool granted, CFErrorRef error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!granted)
                {
                    if (errorBlock)
                        errorBlock((__bridge NSError *)error);
                    return;
                }
                else
                {
                    if (successBlock)
                        successBlock();
                }
                
            });
        });
    }
}



- (void)getPersonOutOfAddressBook
{
    
    //1
    CFErrorRef error = NULL;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &error);
    
    if(!addressBook){
        
        NSLog(@"Error reading Address Book");
        return;
    }
    NSLog(@"Successful.");
    
    //2
    NSArray *allContacts = (__bridge_transfer NSArray *)ABAddressBookCopyArrayOfAllPeople(addressBook);
    
    //3
    NSUInteger i = 0; for (i = 0; i < [allContacts count]; i++)
    {
        Contact *person = [[Contact alloc] init];
        ABRecordRef contactPerson = (__bridge ABRecordRef)allContacts[i];
        
        //4
        NSString *firstName = (__bridge_transfer NSString *)ABRecordCopyValue(contactPerson,
                                                                              kABPersonFirstNameProperty);
        NSString *lastName = (__bridge_transfer NSString *)ABRecordCopyValue(contactPerson, kABPersonLastNameProperty);
        
        person.firstName = firstName;
        person.lastName = lastName ? lastName : @"";
        person.fullName = [NSString stringWithFormat:@"%@ %@", person.firstName, person.lastName];
        person.phone = @"";
        
        //email
        //5
        ABMultiValueRef emails = ABRecordCopyValue(contactPerson, kABPersonEmailProperty);
        
        //6
        NSUInteger j = 0;
        for (j = 0; j < ABMultiValueGetCount(emails); j++) {
            NSString *email = (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(emails, j);
            if (j == 0) {
                person.homeEmail = email;
            }
            else if (j==1)
                person.workEmail = email;
        }
        
        //7
        [addressBookUsers addObject:person];
    }
    
//    [self.tableView reloadData];
    //8
    CFRelease(addressBook);
}

#pragma mark - Mail

-(void)sendEmail:(NSString *)mailId
{
    [sendButton setTitle:[[Localization sharedInstance] localizedStringForKey:@"Send"] forState:UIControlStateNormal];
    [cancelButton setTitle:[[Localization sharedInstance] localizedStringForKey:@"Cancel"] forState:UIControlStateNormal];
    [topLabel setText:[[Localization sharedInstance] localizedStringForKey:@"Invitation"]];
    
    toAddressLabel.text = mailId;
    textView.text = [NSString stringWithFormat:@"%@ %@",[[PFUser currentUser].username capitalizedString] ,[[Localization sharedInstance] localizedStringForKey:@"invites you to check out Seik, a social networking app allowing you to anonymously post text/photos/videos among your 5 mile radius and more!"]];
    textView.userInteractionEnabled = NO;
    textView.layer.borderWidth = 1;
    textView.layer.borderColor = [UIColor grayColor].CGColor;
    
    toLabel.text = [[Localization sharedInstance] localizedStringForKey:@"To:"];
    messageLabel.text = [[Localization sharedInstance] localizedStringForKey:@"Message:"];

    
    mailComposerBGView.frame = [UIScreen mainScreen].bounds;
    mailComposerView.frame = CGRectMake(15, 15, mailComposerBGView.frame.size.width-30, mailComposerBGView.frame.size.height-30);
    
    topLabel.frame = CGRectMake(0, 0, mailComposerView.frame.size.width, topLabel.frame.size.height);
    UIBezierPath *maskPath;
    maskPath = [UIBezierPath bezierPathWithRoundedRect:topLabel.bounds byRoundingCorners:UIRectCornerTopRight | UIRectCornerTopLeft cornerRadii:CGSizeMake(10.0f, 10.0f)];
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame=topLabel.bounds;
    maskLayer.path = maskPath.CGPath;
    topLabel.layer.mask = maskLayer;
    
    mailComposerView.layer.borderWidth = 1;
    mailComposerView.layer.borderColor = [UIColor blackColor].CGColor;
    mailComposerView.layer.cornerRadius = 10;
    
    cancelButton.frame = CGRectMake(12, cancelButton.frame.origin.y, (mailComposerView.frame.size.width-20)/2, 60);
    sendButton.frame = CGRectMake(cancelButton.frame.size.width+20, cancelButton.frame.origin.y, (mailComposerView.frame.size.width-20)/2, 60);
    [[AppDelegate sharedAppDelegate].window addSubview:mailComposerBGView];
    [[AppDelegate sharedAppDelegate].window addSubview:mailComposerView];
}

-(IBAction)sendInvitationMail:(id)sender
{
    if ([BATUtil validateEmailWithString:toAddressLabel.text]){
        
        [PFCloud callFunctionInBackground:@"Email" withParameters:@{@"email": toAddressLabel.text, @"text": textView.text} block:^(NSString *result, NSError *error) {
            if (result && !error) {
                [ProgressHUD showSuccess:[NSString stringWithFormat:@"%@ to \n%@",[[Localization sharedInstance] localizedStringForKey:@"Mail sent successfully"],toAddressLabel.text]];
            }
            else{
                [ProgressHUD showError:[[Localization sharedInstance] localizedStringForKey:@"Unable To Send Mail"]];
            }
            
            [mailComposerView removeFromSuperview];
            [mailComposerBGView removeFromSuperview];
        }];
    }
    else{
        [ProgressHUD showError:[[Localization sharedInstance] localizedStringForKey:@"Please Enter a Valid Email Address."]];
        
        [mailComposerView removeFromSuperview];
        [mailComposerBGView removeFromSuperview];
    }
}

-(IBAction)cancelMail:(id)sender
{
    [mailComposerView removeFromSuperview];
    [mailComposerBGView removeFromSuperview];
}


#pragma mark - Private

-(void)filterResults:(NSString *)searchTerm {
    if(![searchTerm length]) {
        
        self.searchResults = [NSMutableArray arrayWithArray:parseUsers];
        [self.tableView reloadData];
        return;
    }
    
    [self.searchResults removeAllObjects];
    for (PFUser *user in parseUsers)
    {
        if ([[user.username lowercaseString] rangeOfString:[searchTerm lowercaseString]].location != NSNotFound)
        {
            [self.searchResults addObject:user];
            
        }
    }
    
    [self.tableView reloadData];
}



#pragma mark - UISearchControllerDelegate

-(BOOL)searchDisplayController:(UISearchController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    [self filterResults:searchString];
    return YES;
}

-(void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSString *searchString = [self.searchController.searchBar text];
    [self filterResults:searchString];
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *searchString = [NSString stringWithFormat:@"%@%@",[textField text],string];
    [self filterResults:searchString];
    
    return YES;
}

#pragma mark - SlideNavigationController Methods -

- (BOOL)slideNavigationControllerShouldDisplayLeftMenu
{
    return YES;
}

- (BOOL)slideNavigationControllerShouldDisplayRightMenu
{
    return NO;
}


#pragma mark - UISearchBarDelegateMethods  -

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (searchText.length > 0)
    {
        [UIView animateWithDuration:0.3 animations:^{
            self.usernameLabelParent.alpha = 0.0;
        }];
    } else
    {
        [UIView animateWithDuration:0.3 animations:^{
            
            if (parseUsers.count == 0)
            self.usernameLabelParent.alpha = 1.0;
        }];
    }
}

#pragma mark - gesture recognizer action  -

- (IBAction)didPressUsername:(UIGestureRecognizer*)sender {
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        UIMenuController *popover = [UIMenuController sharedMenuController];
        
        [popover setTargetRect:self.usernameLabel.frame inView:self.usernameLabel.superview];
        popover.menuItems = nil;
        [popover setMenuVisible:YES animated:YES];
    }
}

-(BOOL)canBecomeFirstResponder
{
    return  YES;
}

-(BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
        if (action == @selector(copy:))
        {
            return YES;
        } else
        {
            return NO;
        }
}

-(void)copy:(id)sender
{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = self.username;
}

@end
