//
//  ProfileViewController.m
//  Seik
//
//  Created by Gavin on 10/26/14.
//  Copyright (c) 2014 Seik, Inc. All rights reserved.
//

#import "ProfileViewController.h"
#import "AppDelegate.h"
#import "Localization.h"
#import "ProfileCell.h"
#import <ParseUI/ParseUI.h>

@interface ProfileViewController ()<UIActionSheetDelegate,UIAlertViewDelegate, UIImagePickerControllerDelegate>
{
    NSString *userName,*status;
    
    NSInteger avialblity;
    
    UIButton *avialblityButton;

}
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) PFImageView *imageUser;
@property (strong, nonatomic) UIButton *imageButton;


@end

@implementation ProfileViewController

@synthesize from;
@synthesize to;
@synthesize ignoreDrag;

@synthesize tableView, imageUser,imageButton;

- (void)viewDidLoad {
    [super viewDidLoad];
    [AppDelegate sharedAppDelegate].controllerRef = self;
    [self.navigationController setNavigationBarHidden:NO];
    _sendButton.hidden = YES;

    if(_otherUser != nil)
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(done)];
    [self customiseValues];
    
//    UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Dashboard.png"] style:UIBarButtonItemStyleDone target:[AppDelegate sharedAppDelegate] action:@selector(menuClick:)];
//    self.navigationItem.leftBarButtonItem = menuButton;
    
    //---------------------------------------------------------------------------------------------------------------------------------------------
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)]];
    [self addProfilePic];
    [self getProfilePicture];
    [self createRequestButton];
    // Do any additional setup after loading the view.


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

- (void)createRequestButton
{
    if(_otherUser == nil)
        return;
    PFQuery * friendQuery = [PFQuery queryWithClassName:@"Friends"];
    [friendQuery whereKey:PF_USER_ID equalTo:[PFUser currentUser].objectId];
    [friendQuery whereKey:PF_USER_FRIEND_ID equalTo:_otherUser.objectId];
    /**
     *  This block is added to add "pending friend reqs" functionality.
     */
    PFQuery *friendRequestQuery = [PFQuery queryWithClassName:@"Friends"];
    [friendRequestQuery whereKey:PF_USER_ID equalTo:_otherUser.objectId];
    [friendRequestQuery whereKey:PF_USER_FRIEND_ID equalTo:[PFUser currentUser].objectId];
    
    [friendQuery findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
        if(!error && results.count){
            [friendRequestQuery findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
                if (!error && results.count)  {
                    
                }else{
                    [_sendButton setTitle:@"Cancel Request" forState:UIControlStateNormal];
                    [_sendButton addTarget:self action:@selector(cancelRequest:) forControlEvents:UIControlEventTouchUpInside];
                    _sendButton.hidden = NO;
                }
            }];
        }else{
            [_sendButton setTitle:@"Send Request" forState:UIControlStateNormal];
            [_sendButton addTarget:self action:@selector(addFriend:) forControlEvents:UIControlEventTouchUpInside];
            _sendButton.hidden = NO;
        }
    }];
}

- (void)done
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)cancelRequest:(UIButton *)sender
{
    PFQuery * query = [[PFQuery alloc] initWithClassName:@"Friends"];
    [query whereKey:PF_USER_ID equalTo:[PFUser currentUser].objectId];
    [query whereKey:PF_USER_FRIEND_ID equalTo:_otherUser.objectId];
    [ProgressHUD show:@"Cancelling Request"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(!error)
            for (PFObject * object in objects) {
                [object deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if(succeeded){
                        [self createRequestButton];
                        [ProgressHUD showSuccess:@"Cancelled"];
                    }
                }];
            }
    }];
}

- (void)addFriend:(UIButton *)sender
{
    [ProgressHUD show:@"Sending Request"];
    PFUser * currentUser = [PFUser currentUser];
    PFObject *friend = [PFObject objectWithClassName:@"Friends"];
    friend[PF_USER_ID] = currentUser.objectId;
    friend[PF_USER_FRIEND_ID] = _otherUser.objectId;
    [friend saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!succeeded) {
            [ProgressHUD showError:[[Localization sharedInstance] localizedStringForKey:@"Unable to add friend, there may be an issue"]];
        }
        [ProgressHUD shared].interaction = YES;
        
        PFQuery *pushQuery = [PFInstallation query];
        [pushQuery whereKey:@"channels" equalTo:[NSString stringWithFormat:@"test%@",_otherUser.objectId]]; // Set channel
        
        // Send push notification to query
        PFPush *push = [[PFPush alloc] init];
        [push setQuery:pushQuery];
        [push setMessage:[NSString stringWithFormat:@"%@ has sent you a friend request!",[PFUser currentUser].username]];
        [push sendPushInBackground];
        
        [self createRequestButton];
        [ProgressHUD showSuccess:[[Localization sharedInstance] localizedStringForKey:@"Friend Request Sent"]];
    }];
    
    //Add friend request record in FriendRequest class...
    PFObject *friendRequestObject = [PFObject objectWithClassName:@"FriendRequest"];
    friendRequestObject[PF_FROM_USER] = currentUser.username;
    friendRequestObject[PF_TO_USER] = _otherUser.username;
    friendRequestObject[PF_STATUS] = @"1";
    [friendRequestObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if(succeeded)
        {
            //Friend request saved...
            //Send push notification to other user...
            NSLog(@"Friend Request sent...");
        }
        else
        {
            NSLog(@"Friend request not sent...");
        }
    }];
}


-(void)customiseValues
{
    self.title = [[Localization sharedInstance] localizedStringForKey:@"Profile"];
}


-(void)addProfilePic
{
    //---------------------------------------------------------------------------------------------------------------------------------------------
    imageUser = [[PFImageView alloc] initWithFrame:CGRectMake(([UIScreen mainScreen].bounds.size.width-100)/2, 50, 100, 100)];
    imageUser.layer.cornerRadius = imageUser.frame.size.width / 2;
    imageUser.layer.masksToBounds = YES;
    [self.view addSubview:imageUser];
    
    imageButton = [[UIButton alloc] initWithFrame:CGRectMake(([UIScreen mainScreen].bounds.size.width-100)/2,50, 100, 100)];
    [imageButton addTarget:self action:@selector(actionPhoto:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:imageButton];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)dismissKeyboard
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    [self.view endEditing:YES];
}


-(void)getProfilePicture
{
    PFUser *user;
    if (self.otherUser == nil) {
        user = [PFUser currentUser];
    }
    else
    {
        user = self.otherUser;
    }
    NSLog(@"file--%@",[user objectForKey:PF_USER_PICTURE]);
    
    userName = user[PF_USER_USERNAME];
    status = user[PF_USER_STATUS];
    
    if ([user objectForKey:PF_USER_PICTURE]) {
        [imageUser setFile:[user objectForKey:PF_USER_PICTURE]];
        [imageUser loadInBackground];
    }
    else{
        imageUser.image = [UIImage imageNamed:@"blank_profile@2x.png"];
    }
    
    
    //    fieldName.text = user[PF_USER_FULLNAME];
}

#pragma mark - UIActionSheetDelegate


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex

{
    if (buttonIndex < 3 && actionSheet.tag == 9) {
        avialblity = buttonIndex;
        [avialblityButton setImage:[self getPersonStatus:avialblity] forState:UIControlStateNormal];
    }
    else if (buttonIndex != actionSheet.cancelButtonIndex)
    {
        [PFUser logOut];
        PostNotification(NOTIFICATION_USER_LOGGED_OUT);
        
        imageUser.image = [UIImage imageNamed:@"blank_profile"];
        LoginUser(self);
    }
}

- (IBAction)actionPhoto:(id)sender
{
    if(_otherUser != nil)
        return;

    self.sidemenuController.view.translatesAutoresizingMaskIntoConstraints = YES;
    
    ShouldStartPhotoLibrary(self, YES);
}


- (IBAction)actionSave:(id)sender

{
    if(_otherUser != nil)
        return;
    [self dismissKeyboard];
    
    if ([userName isEqualToString:@""] == NO && [status isEqualToString:@""] == NO)
    {
        [ProgressHUD show:[NSString stringWithFormat:@"%@...",[[Localization sharedInstance] localizedStringForKey:@"Please Wait"]]];
        
        PFUser *user = [PFUser currentUser];
        user[PF_USER_FULLNAME] = userName;
        user[PF_USER_FULLNAME_LOWER] = [userName lowercaseString];
        user[PF_USER_STATUS] = status;
        user[PF_USER_USERNAME] = userName;
        user[PF_USER_AVIALABLITY] = [NSString stringWithFormat:@"%ld",(long)avialblity];;
        
        [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
         {
             if (error == nil)
             {
                 [ProgressHUD showSuccess:[[Localization sharedInstance] localizedStringForKey:@"Saved"]];
             }
             else [ProgressHUD showError:[[Localization sharedInstance] localizedStringForKey:@"Network Error"]];
         }];
    }
    else [ProgressHUD showError:[[Localization sharedInstance] localizedStringForKey:@"Please Fill In All Blanks!"]];
}

#pragma mark - UIImagePickerControllerDelegate


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info

{
    if(_otherUser != nil)
        return;

    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    
    if (image.size.width > 140) image = ResizeImage(image, 140, 140);
    
    PFFile *filePicture = [PFFile fileWithName:@"picture.jpg" data:UIImageJPEGRepresentation(image, 0.6)];
    [filePicture saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
     {
         if (error != nil) [ProgressHUD showError:[[Localization sharedInstance] localizedStringForKey:@"Network Error"]];
     }];
    
    imageUser.image = image;
    
    if (image.size.width > 34) image = ResizeImage(image, 34, 34);
    
    PFFile *fileThumbnail = [PFFile fileWithName:@"thumbnail.jpg" data:UIImageJPEGRepresentation(image, 0.6)];
    [fileThumbnail saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
     {
         if (error != nil) [ProgressHUD showError:[[Localization sharedInstance] localizedStringForKey:@"Network Error"]];
     }];
    
    PFUser *user = [PFUser currentUser];
    user[PF_USER_PICTURE] = filePicture;
    user[PF_USER_THUMBNAIL] = fileThumbnail;
    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
     {
         if (error != nil) [ProgressHUD showError:[[Localization sharedInstance] localizedStringForKey:@"Network Error"]];
     }];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellIdentifier = @"Cell";
    ProfileCell *cell = [aTableView dequeueReusableCellWithIdentifier:cellIdentifier];
    cell = nil;
    if(!cell){
        cell = [[ProfileCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    NSString *title =  indexPath.row == 0 ? [NSString stringWithFormat:@"%@ :",[[[Localization sharedInstance] localizedStringForKey:@"Username"] capitalizedString]] : [NSString stringWithFormat:@"%@ :",[[[Localization sharedInstance] localizedStringForKey:@"Status"] capitalizedString]];
    NSString *descrText = indexPath.row == 0 ? userName: status;

    // USerName
    UILabel *titleLabel = [BATUtil initLabelWithFrame:CGRectMake(10, 10, 100, 40) text:title textAlignment:NSTextAlignmentLeft textColor:[UIColor blackColor] font:[UIFont fontWithName:@"HelveticaNeue-Thin" size:20]];
    [cell.contentView addSubview:titleLabel];
    
    // USer Status
    UILabel *descriptonLabel = [BATUtil initLabelWithFrame:CGRectMake(120, 10, self.view.bounds.size.width-180, 40) text:descrText textAlignment:NSTextAlignmentLeft textColor:[UIColor grayColor] font:[UIFont fontWithName:@"HelveticaNeue" size:18]];
    [cell.contentView addSubview:descriptonLabel];
    
    UIButton *cellButton =  [UIButton buttonWithType:UIButtonTypeCustom];
    cellButton.frame = CGRectMake(0, 0, self.view.bounds.size.width, 60);
    [cellButton addTarget:self action:@selector(cellAction:) forControlEvents:UIControlEventTouchUpInside];
    cellButton.tag = indexPath.row;
    [cell.contentView addSubview:cellButton];
    
    NSInteger statusAvailablity = [[PFUser currentUser][PF_USER_AVIALABLITY] integerValue];
    if (indexPath.row == 1) {
        // USer AVailablity
        avialblityButton =  [UIButton buttonWithType:UIButtonTypeCustom];
        avialblityButton.frame = CGRectMake(self.view.bounds.size.width-50, 10, 40, 40);
        
        [avialblityButton setImage:[self getPersonStatus:statusAvailablity] forState:UIControlStateNormal];
        [avialblityButton addTarget:self action:@selector(changeAvailablity:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:avialblityButton];
        // Configure the cell...
    }

    return cell;
}


-(void)cellAction:(UIButton *)button
{
    if(_otherUser != nil)
        return;
    NSString *message = button.tag == 0 ? [[Localization sharedInstance] localizedStringForKey:@"Enter Username"] : [[Localization sharedInstance] localizedStringForKey:@"Enter Your Status"];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:message message:nil delegate:self cancelButtonTitle:[[Localization sharedInstance] localizedStringForKey:@"Cancel"] otherButtonTitles:[[Localization sharedInstance] localizedStringForKey:@"Update"], nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alertView textFieldAtIndex:0].text = button.tag == 0 ? [PFUser currentUser][PF_USER_USERNAME] : [PFUser currentUser][PF_USER_STATUS];;
    alertView.tag = button.tag;
    
    [alertView show];
}

// Perform Segue for showing Chat Screen
-(IBAction)changeAvailablity:(UIButton *)sender
{
    if(_otherUser != nil)
        return;
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:[[Localization sharedInstance] localizedStringForKey:@"Update Availablity to"] delegate:self cancelButtonTitle:[[Localization sharedInstance] localizedStringForKey:@"Cancel"] destructiveButtonTitle:nil otherButtonTitles:
                                  [[Localization sharedInstance] localizedStringForKey:@"Available"],
                                  [[Localization sharedInstance] localizedStringForKey:@"Idle"],
                                  [[Localization sharedInstance] localizedStringForKey:@"Busy"], nil];
    actionSheet.tag = 9;
    [actionSheet showInView:self.view];
}

-(UIImage *)getPersonStatus:(NSInteger)statusCode
{
    switch (statusCode) {
        case kStatusAvailable:
            return [UIImage imageNamed:@"green"];
            break;
            
        case kStatusIdle:
            return [UIImage imageNamed:@"orange"];
            break;
            
        case kStatusBusy:
            return [UIImage imageNamed:@"red"];
            break;
    }
    
    return nil;
}



#pragma mark - UIAlertView Delegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1 && alertView.tag == 1) {
        status = [alertView textFieldAtIndex:0].text;
    }
    else if (buttonIndex == 1 && alertView.tag == 0) {
        userName = [alertView textFieldAtIndex:0].text;
    }
    [tableView reloadData];
}

#pragma mark - Autorotation Delegates
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    [tableView reloadData];
}

@end
