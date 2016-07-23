//
//  DimeReviewVideoViewController.m
//  Seik
//
//  Created by Gavin on 10/26/14.
//  Copyright (c) 2014 Seik, Inc. All rights reserved.
//

#import "DimeReviewVideoViewController.h"
//#import "AdInfoTableViewController.h"
//#import "ManageAdsTableViewController.h"
//#import "Constants.h"
#import "AppDelegate.h"

typedef enum {
	UploadOperationVideo,
	UploadOperationThumbnail,
	UploadOperationAd
} UploadOperation;

typedef enum {
	UploadStatusCancelled = 1,
	UploadStatusSuccessful,
	UploadStatusS3VideoFailed,
	UploadStatusS3ThumbnailFailed,
    UploadStatusDynamoDBFailed
} UploadStatus;

@interface DimeReviewVideoViewController ()
{
    UploadOperation currentUploadOperation;
    NSString *uniqueID;
}

@end

@implementation DimeReviewVideoViewController
- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.view bringSubviewToFront:self.activityIndicator];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (NSString*)documentsDirectory{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentationDirectory, NSUserDomainMask, YES);
    NSLog(@"%@",paths);
    BOOL isDirectory;
    if ([[NSFileManager defaultManager] fileExistsAtPath:[paths objectAtIndex:0] isDirectory:&isDirectory]) {
        return [paths objectAtIndex:0];
    }else{
        BOOL success = [[NSFileManager defaultManager] createDirectoryAtPath:[paths objectAtIndex:0] withIntermediateDirectories:NO attributes:nil error:nil];
        if (success) {
            return [paths objectAtIndex:0];
        }else{
            return nil;
        }
    }
}

- (void)handlePublishButton:(UIButton *)button{
    // Disable the publish and retake buttons
    /*publishButton.enabled = NO;
    publishButton.alpha = .5;
    retakeButton.enabled = NO;
    retakeButton.alpha = .5;
    playPauseButton.enabled = NO;
    playPauseButton.alpha = .5;
    self.btnCancel.enabled = NO;
    self.btnCancel.alpha = .5;

    [super handlePublishButton:button];
    
    // Generate a unique ID
    uniqueID = [[NSUUID UUID] UUIDString];
    
    // Upload the video
    [self uploadVideo];*/
}

- (void)uploadVideo{
    // Upload the video
    currentUploadOperation = UploadOperationVideo;
    NSString *videoName = [uniqueID stringByAppendingString:@".mp4"];
//    self.adEntity.mediaURL = videoName;
    
//    AmazonClientManager *provider = [AmazonClientManager new];
//    self.s3 = [[AmazonS3Client alloc] initWithCredentialsProvider:provider];
//    self.s3.endpoint = [AmazonEndpoints s3Endpoint:S3REGION];
//    S3PutObjectRequest *request = [[S3PutObjectRequest alloc] initWithKey:videoName inBucket:S3BUCKET_NAME];
//    request.contentType = @"video/mp4";
//    request.data = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:self.videoPath]];
//    request.delegate = self;
//    [self.s3 putObject:request];
//    [self.activityIndicator startAnimating];
}

- (void)uploadThumbnail{
    // Create a thumbnail from the beginning of the video
    NSURL *url = [NSURL fileURLWithPath:self.videoPath];
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:url options:nil];
    AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    generator.appliesPreferredTrackTransform = YES;
    CMTime time = CMTimeMakeWithSeconds(0.0, 600);
    NSError *error = nil;
    CMTime actualTime;
    CGImageRef image = [generator copyCGImageAtTime:time actualTime:&actualTime error:&error];
    UIImage *thumb = [[UIImage alloc] initWithCGImage:image];
    NSData *imageData = UIImageJPEGRepresentation(thumb, 50);
    NSString *thumbName = [uniqueID stringByAppendingString:@".jpg"];
//    self.adEntity.thumbURL = thumbName;
    
    // Upload the thumbnail
//    currentUploadOperation = UploadOperationThumbnail;
//    S3PutObjectRequest *request = [[S3PutObjectRequest alloc] initWithKey:thumbName inBucket:S3BUCKET_NAME];
//    request.contentType = @"image/jpeg";
//    request.data = imageData;
//    request.delegate = self;
//    [self.s3 putObject:request];
//    [self.activityIndicator startAnimating];
}

//- (void)uploadAd
//{
//    currentUploadOperation = UploadOperationAd;
//    [self.activityIndicator startAnimating];
//    
//    self.adEntity.adId = uniqueID;
//    
//    mmSaveEntityResult *result = [self.ad saveEntity:self.adEntity];
//    
//    [self.activityIndicator stopAnimating];
//    
//    if (result.saveState == SaveStateSaveComplete) {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: UPLOAD_SUCCESSFUL_TITLE
//                                                        message: UPLOAD_SUCCESSFUL_MESSAGE
//                                                       delegate:self
//                                              cancelButtonTitle:nil
//                                              otherButtonTitles:@"OK", nil];
//        alert.tag = 2;
//        [alert show];
//    }
//    else
//    {
//        [self handUploadFailed];
//    }
//}
//
//- (void)request:(AmazonServiceRequest *)request didCompleteWithResponse:(AmazonServiceResponse *)response
//{
//    [self.activityIndicator stopAnimating];
//    
//    if (currentUploadOperation == UploadOperationVideo) {
//        self.adEntity.mediaURL = [request.url absoluteString];
//        [self uploadThumbnail];
//    }
//    else if (currentUploadOperation == UploadOperationThumbnail)
//    {
//        self.adEntity.thumbURL = [request.url absoluteString];
//        [self uploadAd];
//    }
//}
//-(void)request:(AmazonServiceRequest *)request didFailWithError:(NSError *)theError
//{
//    // The request failed with error.
//    [self.activityIndicator stopAnimating];
//    [self handUploadFailed];
//}
//
//- (void)handUploadFailed
//{
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: UPLOAD_FAILED_TITLE
//                                                    message: UPLOAD_FAILED_MESSAGE
//                                                   delegate:self
//                                          cancelButtonTitle:@"NO"
//                                          otherButtonTitles:@"Retry", nil];
//    
//    switch (currentUploadOperation) {
//        case UploadOperationVideo:
//            alert.tag = UploadStatusS3VideoFailed;
//            break;
//        case UploadOperationThumbnail:
//            alert.tag = UploadStatusS3ThumbnailFailed;
//            break;
//        case UploadOperationAd:
//            alert.tag = UploadStatusDynamoDBFailed;
//            break;
//        default:
//            break;
//    }
//    [alert show];
//}

//#pragma mark - UIAlertViewDelegate
//- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
//{
//    publishButton.enabled = YES;
//    publishButton.alpha = 1;
//    retakeButton.enabled = YES;
//    retakeButton.enabled = 1;
//    playPauseButton.enabled = YES;
//    playPauseButton.alpha = 1;
//    self.btnCancel.enabled = YES;
//    self.btnCancel.alpha = 1;
//    
//    NSArray *viewControllers;
//    switch (alertView.tag) {
//        case UploadStatusCancelled:
//            self.navigationItem.leftBarButtonItem.enabled = YES;
//            self.navigationItem.rightBarButtonItem.enabled = YES;
//            if (buttonIndex == 1) {
//                // User has chosen to discard the video
//                viewControllers = [[self navigationController] viewControllers];
//                for( int i=0;i<[viewControllers count];i++){
//                    id obj=[viewControllers objectAtIndex:i];
//                    if([obj isKindOfClass:[AdInfoTableViewController class]]){
//                        [[self navigationController] popToViewController:obj animated:YES];
//                        return;
//                    }
//                }
//            }
//            break;
//        case UploadStatusSuccessful:
//            // Upload successful
//            [Member sharedInstance].postedAds = [NSNumber numberWithBool:YES];
//            
//            // TO DO: Update the seller's email address if changed. SaveEntity saves both locally and remotely
//            [[Member sharedInstance] saveEntity];
//            viewControllers = [[self navigationController] viewControllers];
//
//            for( int i=0;i<[viewControllers count];i++){
//                id obj=[viewControllers objectAtIndex:i];
//                if([obj isKindOfClass:[HomeViewController class]]){
//                    [[self navigationController] popToViewController:obj animated:YES];
//                    return;
//                }
//            }
//            break;
//        case UploadStatusS3VideoFailed:
//            // Upload failed!
//            if (buttonIndex == 1) {
//                // Try again
//                [alertView dismissWithClickedButtonIndex:1 animated:YES];
//                [self uploadVideo];
//            }
//            else {
//                // Cancel upload
//                [self navigateToAdInfoController];
//            }
//            break;
//        case UploadStatusS3ThumbnailFailed:
//            // Upload failed!
//            if (buttonIndex == 1) {
//                // Try again
//                [alertView dismissWithClickedButtonIndex:1 animated:YES];
//                [self uploadThumbnail];
//            }
//            else {
//                // Cancel upload
//                [self navigateToAdInfoController];
//            }
//            break;
//        case UploadStatusDynamoDBFailed:
//            // Upload failed!
//            if (buttonIndex == 1) {
//                // Try again
//                [alertView dismissWithClickedButtonIndex:1 animated:YES];
//                [self uploadAd];
//            }
//            else {
//                // Cancel upload
//                [self navigateToAdInfoController];
//            }
//            break;
//        default:
//            break;
//    }
//}

//- (void)navigateToAdInfoController
//{
//    NSArray *viewControllers = [[self navigationController] viewControllers];
//    for( int i=0;i<[viewControllers count];i++){
//        id obj=[viewControllers objectAtIndex:i];
//        if([obj isKindOfClass:[AdInfoTableViewController class]]){
//            [[self navigationController] popToViewController:obj animated:YES];
//            return;
//        }
//    }
//}

- (IBAction)close:(id)sender {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Discard Video"
                                                    message: @"If you close the camera your video will be discarded. Are you sure?"
                                                   delegate:self
                                          cancelButtonTitle:@"No"
                                          otherButtonTitles:@"Yes", nil];
    alert.tag = UploadStatusCancelled;
    [alert show];
}

@end
