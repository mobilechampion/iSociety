//
//  AddNewPostViewController.m
//  Seik
//
//  Created by Gavin on 10/26/14.
//  Copyright (c) 2014 Seik, Inc. All rights reserved.
//

#import "AddNewPostViewController.h"
#import "DimeRecordAdViewController.h"
#import "DimeReviewVideoViewController.h"
#import "PBJVideoPlayerController.h"
#import "Localization.h"
#import "UIImageView+WebCache.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "ProgressHUD.h"
#import "Helper.h"

@interface AddNewPostViewController ()

@end

@implementation AddNewPostViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self customiseValues];

    NSArray *mediaTypes = [[NSArray alloc] initWithObjects:
                          [[Localization sharedInstance] localizedStringForKey:@"Video"],
                          [[Localization sharedInstance] localizedStringForKey:@"Photo"], nil];
    mediaType = [[UISegmentedControl alloc] initWithItems:mediaTypes];
    mediaType.tintColor = [UIColor grayColor];
    
    if ([AppDelegate sharedAppDelegate].dev_type == IPHONE_4) {
        mediaType.frame = CGRectMake(14, 28, 123, 28);
    }else if ([AppDelegate sharedAppDelegate].dev_type == IPHONE_6P){
        mediaType.frame = CGRectMake(14, 53, 123, 28);
    }else if ([AppDelegate sharedAppDelegate].dev_type == IPHONE_6){
        mediaType.frame = CGRectMake(14, 47, 123, 28);
    }else{
        mediaType.frame = CGRectMake(14, 38, 123, 28);
    }

    mediaType.selectedSegmentIndex = 0;
    [typeView addSubview:mediaType];
    
    [addMediaButton setTitle:[[Localization sharedInstance] localizedStringForKey:@"Add Media"] forState:UIControlStateNormal];
    [postButton setTitle:[[Localization sharedInstance] localizedStringForKey:@"Post"] forState:UIControlStateNormal];

    // Adding the tap gesture to minimize the enlarge photo view
    UITapGestureRecognizer *singleFingerTap;
    singleFingerTap.enabled = YES;
    singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap)];
    [enlargedView addGestureRecognizer:singleFingerTap];
    
    typeLabel.text = [NSString stringWithFormat:@"  %@", [[Localization sharedInstance] localizedStringForKey:@"Media Type"]];
    descLabel.text = [[Localization sharedInstance] localizedStringForKey:@"Description"];
    headlineLabel.text = [[Localization sharedInstance] localizedStringForKey:@"Headline"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.navigationBar.backgroundColor = [UIColor blueColor];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];

    if (!_bNew) {
        [self displayInformation];
        [mediaType setEnabled:NO];
        [playButton setHidden:NO];
    }else{
        [playButton setHidden:YES];
    }
}

- (void)customiseValues{
    self.title = [[Localization sharedInstance] localizedStringForKey:@"Post"];
}

- (void)displayInformation{
    titleTxtField.text = _infoDict[@"postTitle"];
    descTxtView.text = _infoDict[@"postText"];

    
    PFFile *imgFile = _infoDict[@"thumbImage"];
    [imgView sd_setImageWithURL:[NSURL URLWithString:imgFile.url] placeholderImage:nil];

    [addMediaButton setHidden:YES];
    [postButton setHidden:YES];
    
    if ([_infoDict[@"mediaType"] isEqualToString:@"Photo"]) {
        [playButton setImage:nil forState:UIControlStateNormal];
        [mediaType setSelectedSegmentIndex:1];
    }else{
        [playButton setImage:[UIImage imageNamed:@"PlayButton-40x40.png"] forState:UIControlStateNormal];
        [mediaType setSelectedSegmentIndex:0];
    }
}


- (void)showImagePicker{
    if (!self.manualImagePickerController) {
        self.manualImagePickerController = [[UIImagePickerController alloc] init];
        [self.manualImagePickerController setDelegate:self];
    }
    
    [self.manualImagePickerController setSourceType:self.imagePickerSourceType];
    self.manualImagePickerController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-50);
    [self.view addSubview:self.manualImagePickerController.view];

//    [self presentViewController:self.manualImagePickerController animated:YES completion:nil];
}

#pragma mark - IBAction methods
- (IBAction)PlayVideo:(id)sender{
    if (mediaType.selectedSegmentIndex == 1) {
        [enlargedView setHidden:NO];
        enlargedView.image = imgView.image;
    }else{
        NSLog(@"%@", _infoDict[@"postVideo"]);
        PFFile *videoFile = _infoDict[@"postVideo"];
        
        PBJVideoPlayerController *controller = [[PBJVideoPlayerController alloc] init];
        controller.videoPath = videoFile.url;
        controller.delegate = self;
        controller.videoFillMode = AVLayerVideoGravityResizeAspectFill;
        [self.navigationController pushViewController:controller animated:YES];
    }
}

- (void)handleSingleTap{
    [enlargedView setHidden:YES];
}

- (IBAction)AddNewMedia:(id)sender{
    if (mediaType.selectedSegmentIndex == 0) {
        DimeRecordAdViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"DimeRecordAdViewController"];
        controller.delegate = self;
        [self.navigationController pushViewController:controller animated:YES];
    }else{
        BOOL isAnySourceAvailable = NO;
        BOOL isCameraAvailable = NO;
        BOOL isLibraryAvailable = NO;
        
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            isCameraAvailable = YES;
            isAnySourceAvailable = YES;
        }
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
            isLibraryAvailable = YES;
            isAnySourceAvailable = YES;
        }
        
        if (isAnySourceAvailable) {
            if (isCameraAvailable && isLibraryAvailable) {
                UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                         delegate:self
                                                                cancelButtonTitle:[[Localization sharedInstance] localizedStringForKey:@"Cancel"]
                                                           destructiveButtonTitle:nil
                                                                otherButtonTitles:nil];
                [actionSheet addButtonWithTitle:[[Localization sharedInstance] localizedStringForKey:@"Camera"]];
                [actionSheet addButtonWithTitle:[[Localization sharedInstance] localizedStringForKey:@"Photo Library"]];
                [actionSheet showInView:self.view];
            } else {
                if (isCameraAvailable) {
                    self.imagePickerSourceType = UIImagePickerControllerSourceTypeCamera;
                } else {
                    self.imagePickerSourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                }
                [self showImagePicker];
            }
        }
    }
}

- (IBAction)Post:(id)sender{
    if (imgView.image) {
        PFUser *user = [PFUser currentUser];
        NSData *data = UIImageJPEGRepresentation(imgView.image, 1.0);
        PFFile *imagefile = [PFFile fileWithName:@"post.png" data:data];
        
        PFGeoPoint *point = [PFGeoPoint geoPointWithLatitude:[AppDelegate sharedAppDelegate].currentLoc.coordinate.latitude longitude:[AppDelegate sharedAppDelegate].currentLoc.coordinate.longitude];
        
        PFObject *mediaPost = [PFObject objectWithClassName:@"AnonymousPost"];
        mediaPost[@"User"] = user.objectId;
        mediaPost[@"postUser"] = user;
        mediaPost[@"postText"] = descTxtView.text;
        mediaPost[@"postTitle"] = titleTxtField.text;
        mediaPost[@"thumbImage"] = imagefile;
        mediaPost[@"postPosition"] = point;
        
        if (mediaType.selectedSegmentIndex == 0) {
            data = [NSData dataWithContentsOfFile:self.videoPathString];
            PFFile *videoFile = [PFFile fileWithName:@"post.m4v" data:data];
            
            mediaPost[@"postVideo"] = videoFile;
            mediaPost[@"mediaType"] = @"Video";
        }else{
            mediaPost[@"postImage"] = imagefile;
            mediaPost[@"mediaType"] = @"Photo";
        }
        
        [ProgressHUD show:@"Worth the wait, promise!"];
        UIButton *postBtn = (UIButton*)sender;
        [postBtn setEnabled:NO];
        
        [mediaPost saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            [ProgressHUD dismiss];
            [postBtn setEnabled:YES];
            
            if (succeeded) {
                //[Helper sendFeedNotificationToAllUserWithMessage:@"Someone commented on your post!" toPostObject:mediaPost];
                // The object has been saved.
                [self.navigationController popViewControllerAnimated:YES];
            } else {
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Error" message:error.description delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                [alertView show];
                // There was a problem, check error.description
            }
        }];
    }else{
        [BATUtil showAlertWithMessage:@"Please add your type of media above prior to posting." title:@"Seik" delegate:self];
    }
}

#pragma mark - PBJVideoController Delegate
- (void)videoPlayerReady:(PBJVideoPlayerController *)videoPlayer{
    NSLog(@"1");
}

- (void)videoPlayerPlaybackStateDidChange:(PBJVideoPlayerController *)videoPlayer{
    NSLog(@"2");
}

- (void)videoPlayerPlaybackWillStartFromBeginning:(PBJVideoPlayerController *)videoPlayer{
    NSLog(@"3");
}

- (void)videoPlayerPlaybackDidEnd:(PBJVideoPlayerController *)videoPlayer{
    [videoPlayer dismissViewControllerAnimated:NO completion:nil];
    NSLog(@"4");
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (buttonIndex != 0) {
        if (buttonIndex == 1) {
            self.imagePickerSourceType = UIImagePickerControllerSourceTypeCamera;
        } else {
            self.imagePickerSourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        }
        [self showImagePicker];
    }
}

- (void) playbackDidFinish:(NSNotification*)notification {
    int reason = [[[notification userInfo] valueForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey] intValue];
    if (reason == MPMovieFinishReasonPlaybackEnded) {
        [self.moviePlayer.view removeFromSuperview];
        [self.moviePlayer stop];
    }else if (reason == MPMovieFinishReasonUserExited) {
        //user hit the done button
    }else if (reason == MPMovieFinishReasonPlaybackError) {
        //error
    }
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    NSLog(@"Data: %@", info);
    self.capturedImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    if(NULL == self.capturedImage){
        ALAssetsLibrary *assetLibrary=[[ALAssetsLibrary alloc] init];
        [assetLibrary assetForURL:[info objectForKey:@"UIImagePickerControllerReferenceURL"] resultBlock:^(ALAsset *asset) {
            ALAssetRepresentation *rep = [asset defaultRepresentation];
            Byte *buffer = (Byte*)malloc(rep.size);
            NSUInteger buffered = [rep getBytes:buffer fromOffset:0.0 length:rep.size error:nil];
            NSData *data = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];
            self.capturedImage = [UIImage imageWithData:data];
            //            completion(img);
            imgView.image = self.capturedImage;
        } failureBlock:^(NSError *err) {
            NSLog(@"Error: %@",[err localizedDescription]);
        }];
    }else{
        //image not null here
        imgView.image = self.capturedImage;
    }
    
    [playButton setImage:nil forState:UIControlStateNormal];
    [self.manualImagePickerController.view removeFromSuperview];
//    [self.manualImagePickerController dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self.manualImagePickerController.view removeFromSuperview];

}

#pragma mark - GetVideoLink Delegate
- (void)setVideoPath:(NSString*)videoPathString{
    self.videoPathString = videoPathString;
    NSURL *vidURL = [NSURL fileURLWithPath:videoPathString];
    imgView.image = [[AppDelegate sharedAppDelegate] loadImage:vidURL];
    [playButton setImage:[UIImage imageNamed:@"PlayButton-40x40.png"] forState:UIControlStateNormal];
}

#pragma mark - UITextField & UITextView Delegate
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [titleTxtField resignFirstResponder];
    [descTxtView resignFirstResponder];
    [self keyboardWillHide];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    textField.text = @"";
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;   // return NO to not change text
{
    if ([string isEqualToString:@"\n"]) {
        [textField resignFirstResponder];
    }
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView{
    textView.text = @"";
    [self keyboardWillShow];
}

- (void)textViewDidEndEditing:(UITextView *)textView{
    [self keyboardWillHide];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
    }
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

//method to move the view up/down whenever the keyboard is shown/dismissed
-(void)setViewMovedUp:(BOOL)movedUp{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3]; // if you want to slide up the view
    
    CGRect rect = self.view.frame;
    if (movedUp){
                rect.origin.y -= kOFFSET_KEYBOARD;
    }
    else{
        // revert back to the normal state.
        rect.origin.y += kOFFSET_KEYBOARD;
        //        rect.size.height -= kOFFSET_FOR_KEYBOARD;
    }
    self.view.frame = rect;
    
    [UIView commitAnimations];
}

@end
