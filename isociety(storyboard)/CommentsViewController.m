//
//  CommentsViewController.m
//  Seik
//
//  Created by Gavin on 10/26/14.
//  Copyright (c) 2014 Seik, Inc. All rights reserved.
//

#import "CommentsViewController.h"
#import "CommentCell.h"
#import "Helper.h"
#import "Gradient.h"

@interface CommentsViewController ()
{
    IBOutlet NSLayoutConstraint *yForBottomEdtingView;
    NSInteger intKeyBoardHeight;
    CGFloat tabBarHeight;
}

@property (nonatomic, strong) IBOutlet UIView *inputBar;

@end

@implementation CommentsViewController

@synthesize postObject;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    commentsTblView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    commentsTblView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectZero];
    commentsTblView.backgroundColor = [UIColor clearColor];
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor orangeColor];
    [self setupGradients];
    
//     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(myNotificationMethod:) name:UIKeyboardDidShowNotification object:nil];

    // register  notification for keyboard show and hide
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillChange:)
                                                 name:UIKeyboardWillChangeFrameNotification
                                               object:nil];

    tabBarHeight = APP_DELEGATE.MainTabBar.tabBar.bounds.size.height;
    CGRect frame = _inputBar.frame;
    frame.origin.y = self.view.bounds.size.height - tabBarHeight - frame.size.height;
    _inputBar.frame = frame;
}

- (void)viewDidAppear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadComments) name:NOTIFICATION_LOAD_COMMENTS object:nil];
    [self loadComments];
    [self customiseView];
    [self customiseValues];
    
    txtField.placeholder = [[Localization sharedInstance] localizedStringForKey:@"What're your thoughts?"];
}

-(void)setupGradients
{
    [self.view.layer insertSublayer:[Gradient setupGradient:self.view.frame] atIndex:0];
}

-(void) viewDidDisappear:(BOOL)animated{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_LOAD_COMMENTS object:nil];
}

- (void)customiseView{
    [AppDelegate sharedAppDelegate].controllerRef = self;
}

- (void)customiseValues{
    self.title = [[Localization sharedInstance] localizedStringForKey:@"Anonymous"];
}

- (void)loadComments{
    NSUInteger limitRecords = 100;
    NSUInteger skipRecords = 0;

    NSString *queryString = [NSString stringWithFormat:@"flagCount < 4 OR flagCount = NULL"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:queryString];

    PFQuery *query = [PFQuery queryWithClassName:@"APostCommentTable" predicate:predicate];
    [query whereKey:@"postId" equalTo:postObject];

    
    _commentsList = [[NSMutableArray alloc] init];
    
    [self getRecords:query withLimit:limitRecords withSkips:skipRecords];
    
}

- (void) getRecords:(PFQuery*)query withLimit:(NSUInteger) limitRecords withSkips:(NSUInteger) skipRecords {
    __block NSUInteger blockSkipRecord = skipRecords;
    
    [query setLimit:limitRecords];
    [query setSkip:skipRecords];

    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSLog(@"%@", objects);
        [self filterComments:objects];
        if(objects.count==limitRecords)
        {
            blockSkipRecord = blockSkipRecord + limitRecords;
            [self getRecords:query withLimit:limitRecords withSkips:blockSkipRecord];
        }
    }];

}

- (void)filterComments:(NSArray*)comments{
    for (int i=0; i<comments.count; i++) {
        PFObject *tempObject = [comments objectAtIndex:i];
        PFUser *tempUser = tempObject[@"postId"];
        NSLog(@"%@\n%@", tempUser.objectId, postObject.objectId);

        if ([tempUser.objectId isEqualToString:postObject.objectId]) {
            [_commentsList addObject:tempObject];
        }
    }
    [commentsTblView reloadData];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UITableView Delegate & Datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _commentsList.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    CommentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"commentCell"];
    if(!cell){
        cell = (CommentCell *)[[[NSBundle mainBundle] loadNibNamed:@"CommentCell" owner:self options:nil] objectAtIndex:0];
    }

    
    if (_commentsList.count > 0) {
        PFObject *tempObject = _commentsList[indexPath.row];
        cell.descLabel.text = tempObject[@"commentText"];

        PFUser *tempUser = tempObject[@"commentUser"];
//        PFUser *commentUser = [PFQuery getUserObjectWithId:tempUser.objectId];
        
        NSArray *flaggedByUsersIDs = tempObject[@"flaggedByUsers"];
        

        // user owns this comment
        if([[PFUser currentUser].objectId isEqualToString:tempUser.objectId]){
            // hide flag button when user owns the comment
            cell.buttonFlagComment.hidden = YES;
            
            // display flag count when it is greater than zero only
            if([flaggedByUsersIDs count]>0)
            {
                cell.flagCountLabel.text = [NSString stringWithFormat:@"Flag Count: %lu",(unsigned long)flaggedByUsersIDs.count];
            }
            
        }
        
        else{
            //user does not own this comment so hide thhe delete button
            cell.buttonDeleteComment.hidden = YES;
            
            // if the user has flagged the comment, show flag count
            NSLog(@"userId = %@", [PFUser currentUser].objectId);
            NSLog(@"userIDs = %@", flaggedByUsersIDs);
            if([flaggedByUsersIDs containsObject:[PFUser currentUser].objectId])
            {
                cell.flagCountLabel.text = [NSString stringWithFormat:@"Flag Count: %lu",(unsigned long)flaggedByUsersIDs.count];
                cell.buttonFlagComment.hidden = YES;
            } else {
                cell.buttonFlagComment.hidden = NO;
            }
        }

        
        
        
        
        
        
      
        
        cell.currentCommentParseObject = tempObject;
        
    
        
     /*   cell.colorLabel.frame = CGRectMake(cell.colorLabel.frame.origin.x, cell.colorLabel.frame.origin.y, cell.colorLabel.frame.size.width, cell.colorLabel.frame.size.height);
        CALayer *roundRect = [cell.colorLabel layer];
        [roundRect setCornerRadius:cell.colorLabel.frame.size.width / 2];
        [roundRect setMasksToBounds:YES];

        CGFloat hue, sat, brg;
        hue = [commentUser[@"ColorHue"] floatValue];
        sat = [commentUser[@"ColorSat"] floatValue];
        brg = [commentUser[@"ColorBrg"] floatValue];
        
        cell.colorLabel.backgroundColor = [UIColor colorWithHue:hue saturation:sat brightness:brg alpha:1];*/
    }
    
    return cell;
}

//Swipe to delete
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES if you want the specified item to be editable.
    
    PFObject *objUser = self.commentsList[indexPath.row];
    PFUser *currentUser = objUser[@"commentUser"];

    [currentUser fetchInBackground];
    
    if([currentUser.objectId isEqualToString:[PFUser currentUser].objectId])
        return YES;
    else
        return NO;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        PFObject *comment =   _commentsList[indexPath.row];
        [comment deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    // Send Post notification
                    //n[Helper sendFeedNotificationToAllUserWithMessage:@"Someone commented on your post!" toPostObject:_postObject];
                    PFQuery *query = [PFQuery queryWithClassName:@"AnonymousPost"];
                    
                    // Retrieve the object by id
                    [query getObjectInBackgroundWithId:postObject.objectId block:^(PFObject *gameScore, NSError *error) {
                        // Now let's update it with some new data. In this case, only cheatMode and score
                        // will get sent to the cloud. playerName hasn't changed.
                        NSNumber *commentCount = gameScore[@"commentCount"];
                        if ([commentCount integerValue] <= 0){
                            commentCount = [NSNumber numberWithInt:0];
                        }else{
                            commentCount = [NSNumber numberWithInt:[commentCount intValue] - 1];
                        }
                        
                        gameScore[@"commentCount"] = commentCount;
                        [gameScore saveInBackground];
                        
                        [self loadComments];
//                        [txtField resignFirstResponder];
//                        [self keyboardWillHide];
                    }];
                }else {
                    // There was a problem, check error.description
                    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Error" message:error.description delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                    [alertView show];
                }
                sendButton.enabled = YES;
            }];
        
        [_commentsList removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [commentsTblView reloadData];
        
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - IBAction 
- (IBAction)Post:(id)sender{

    NSString *inputData = txtField.text;

    if (inputData.length == 0) {
        // alert message

        UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"Oops!" message:@"Type a comment!" preferredStyle:UIAlertControllerStyleAlert];
        [controller addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:controller animated:YES completion:nil];

        return;
    }

    PFUser *user = [PFUser currentUser];
    sendButton.enabled = NO;
    NSString *postCount = postObject[@"voteCount"];
    if ([postCount integerValue] < 0){
        postCount = @"0";
    }else{
        postCount = [NSString stringWithFormat:@"%d", [postCount intValue] + 1];
    }
    
    PFObject *mediaPost = [PFObject objectWithClassName:@"APostCommentTable"];
    mediaPost[@"commentText"] = txtField.text;
    mediaPost[@"commentUser"] = user;
    mediaPost[@"postId"] = postObject;
    mediaPost[@"voteCount"] = postCount;
    mediaPost[@"StatusComment"] = @"1";
    
    [mediaPost saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            PFQuery *query = [PFQuery queryWithClassName:@"AnonymousPost"];
            
            // Retrieve the object by id
            [query getObjectInBackgroundWithId:postObject.objectId block:^(PFObject *gameScore, NSError *error) {
          
                NSNumber *commentCount = gameScore[@"commentCount"];
                if ([commentCount integerValue] < 0){
                    commentCount = [NSNumber numberWithInt:0];
                }else{
                    commentCount = [NSNumber numberWithInt:[commentCount intValue] + 1];
                }
                    
                gameScore[@"commentCount"] = commentCount;
                [gameScore saveInBackground];
                
                [self loadComments];
                [txtField resignFirstResponder];
                [self keyboardWillHide];
                [self setViewMovedUp:NO];
            }];
        }else {
            // There was a problem, check error.description
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Error" message:error.description delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alertView show];
        }
        sendButton.enabled = YES;
    }];
}

#pragma mark - UITextField delegates
- (void)textFieldDidBeginEditing:(UITextField *)textField{
//    [self keyboardWillShow];
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    [textField resignFirstResponder];
//    [self keyboardWillHide];
    txtField.text = @"";
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;   // return NO to not change text
{

    return YES;
}

-(void)keyboardWillShow {
    // Animate the current view out of the way
    if (self.view.frame.origin.y >= 0){
        [self setViewMovedUp:YES];
    }
    else if (self.view.frame.origin.y < 0){
        //        [self setViewMovedUp:NO];
    }
}

-(void)keyboardWillHide {
    if (self.view.frame.origin.y >= 0){
        //        [self setViewMovedUp:YES];
    }
    else if (self.view.frame.origin.y < 0){
        [self setViewMovedUp:NO];
    }
}

#pragma mark- Keyboard Notification Method

- (void)myNotificationMethod:(NSNotification*)notification
{
    NSDictionary* keyboardInfo = [notification userInfo];
    NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey];
    CGRect keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];
    
    intKeyBoardHeight = keyboardFrameBeginRect.size.height;
    
    [self setViewMovedUp:YES];
}


-(void)setViewMovedUp:(BOOL)movedUp{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3]; 
    
    CGRect rect = self.view.frame;
    if (movedUp){

        
        yForBottomEdtingView.constant = 0;//intKeyBoardHeight - 50;

    }
    else{
        // revert back to the normal state.
        yForBottomEdtingView.constant = 0;

        //rect.origin.y += 170;
        //        rect.size.height -= kOFFSET_FOR_KEYBOARD;
    }
    self.view.frame = rect;
    
    [UIView commitAnimations];
}

#pragma mark - TextField

- (void)keyboardWillChange:(NSNotification *)notification {
    
    CGRect keyboardRect = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat height = keyboardRect.size.height - tabBarHeight; // minus tabbar height

    [UIView animateWithDuration:0.2 animations:^{
        self.inputBar.transform = CGAffineTransformMakeTranslation(0, -height);
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    
    [UIView animateWithDuration:0.2 animations:^{
        self.inputBar.transform = CGAffineTransformIdentity;
    }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [self.view endEditing:YES];
    return YES;
}


- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {

    if (scrollView == commentsTblView) {
        [self.view endEditing:YES];
    }
}

@end
