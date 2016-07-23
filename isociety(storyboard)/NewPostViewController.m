//
//  NewPostViewController.m
//  Seik
//
//  Created by Gavin on 10/26/14.
//  Copyright (c) 2014 Seik, Inc. All rights reserved.
//

#define kFilterImageViewTag 9999
#define kFilterImageViewContainerViewTag 9998

#import "NewPostViewController.h"
#import "UITextView+Placeholder.h"
#import "InstaFilters.h"
#import "NSLayoutConstraint+Helper.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "ProgressHUD.h"
#import "Helper.h"
#import "AppDelegate.h"
#import "Gradient.h"

@interface NewPostViewController ()<UITextViewDelegate, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate,GPUImageVideoCameraDelegate>
@property (strong, nonatomic) IBOutlet UIScrollView *mainScrollView;
@property (strong, nonatomic) IBOutlet UIButton *textButton;
@property (strong, nonatomic) IBOutlet UILabel *textBottomLine;
@property (strong, nonatomic) IBOutlet UIButton *photoButton;
@property (strong, nonatomic) IBOutlet UILabel *photoBottomLine;
@property (strong, nonatomic) IBOutlet UIButton *videoButton;
@property (strong, nonatomic) IBOutlet UILabel *videoBottomLine;
@property (strong, nonatomic) IBOutlet UITextView *postTextView;

@property (strong, nonatomic) UIBarButtonItem       *closeButton;
@property (strong, nonatomic) UIBarButtonItem       *postButton;
@property (strong, nonatomic) UIBarButtonItem       *nextButton;
@property (strong, nonatomic) UIBarButtonItem       *muteButton;
@property (strong, nonatomic) UIButton              *muteCustomButton;

@property (strong, nonatomic) UIButton              *cameraRollButton;
@property (strong, nonatomic) IBOutlet UIView *videoCameraContentView;
@property (strong, nonatomic) GPUImageVideoCamera *videoCamera;
@property (strong, nonatomic) GPUImageStillCamera *photoCamera;
@property (strong, nonatomic) IBOutlet GPUImageView *gpuCameraView;
@property (strong, nonatomic) IBOutlet GPUImageView *gpuCameraView_HD;

@property (nonatomic, assign) IFFilterType currentType;
@property (nonatomic, strong) GPUImageFilter        *currentFilter;
@property (strong, nonatomic) IBOutlet UIButton *recordPhotoButton;
@property (strong, nonatomic) IBOutlet UIButton *recordVideoButton;
@property (strong, nonatomic) IBOutlet UIScrollView *cameraScrollView;
@property (strong, nonatomic) IBOutlet UIButton *switchCameraButton;

@property (strong, nonatomic) IBOutlet UIView *filterTableViewContainer;
@property (strong, nonatomic) UITableView           *filtersTableView;
@property (strong, nonatomic) UIView                *filterBottomLine;
@property (strong, nonatomic) GPUImagePicture *sourcePicture;

@property (strong, nonatomic) UIImage*              rawImage;

@property (strong, nonatomic) IBOutlet UIImageView *selectedImageView;
@property (nonatomic, strong) GPUImagePicture *stillImageSource;

@property (nonatomic, strong) GPUImageFilter *internalFilter;
@property (nonatomic, strong) GPUImagePicture *internalSourcePicture1;
@property (nonatomic, strong) GPUImagePicture *internalSourcePicture2;
@property (nonatomic, strong) GPUImagePicture *internalSourcePicture3;
@property (nonatomic, strong) GPUImagePicture *internalSourcePicture4;
@property (nonatomic, strong) GPUImagePicture *internalSourcePicture5;

@property (nonatomic, strong) GPUImagePicture *sourcePicture1;
@property (nonatomic, strong) GPUImagePicture *sourcePicture2;
@property (nonatomic, strong) GPUImagePicture *sourcePicture3;
@property (nonatomic, strong) GPUImagePicture *sourcePicture4;
@property (nonatomic, strong) GPUImagePicture *sourcePicture5;
@property (nonatomic, strong) dispatch_queue_t prepareFilterQueue;

@property (strong, nonatomic) AVPlayerItem *playItem;
@property (strong, nonatomic) AVPlayer *player;
@property (strong, nonatomic) GPUImageMovie *movieFile;
@property (strong, nonatomic) GPUImageMovieWriter *movieWriter;
@property (nonatomic)         BOOL isRecorded;
@property (strong, nonatomic) NSURL     *videoUrl;
@end

@implementation NewPostViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initPostTextView];
    [self initPhotoView];
    [self.view.layer insertSublayer:[Gradient setupGradient:self.view.frame] atIndex:0];
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.videoCamera stopCameraCapture];
    [self.photoCamera stopCameraCapture];
//    [[NSNotificationCenter defaultCenter] removeObserver:AVPlayerItemDidPlayToEndTimeNotification];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.f green:(float)0x7A/0xff blue:1 alpha:1.0];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(repeatPlayVideo:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
}

#pragma mark - InitViews
- (void) initPostTextView
{
    self.closeButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleDone target:self action:@selector(closeButtonClicked)];
    self.navigationItem.leftBarButtonItem = self.closeButton;
    
    self.postButton = [[UIBarButtonItem alloc] initWithTitle:@"Post" style:UIBarButtonItemStyleDone target:self action:@selector(postButtonClicked)];
    self.postButton.enabled = NO;
    self.navigationItem.rightBarButtonItem = self.postButton;
    
    self.muteCustomButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [self.muteCustomButton setImage:[UIImage imageNamed:@"unmute.png"] forState:UIControlStateNormal];
    [self.muteCustomButton setImage:[UIImage imageNamed:@"mute.png"] forState:UIControlStateSelected];
    [self.muteCustomButton addTarget:self action:@selector(muteButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    
    self.muteButton = [[UIBarButtonItem alloc] initWithCustomView:self.muteCustomButton];
    
    self.postTextView.placeholder = @"What's on your mind?";
    self.postTextView.placeholderColor = [UIColor lightGrayColor];
    UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height, self.view.bounds.size.width, 44)];
    toolBar.barStyle = UIBarStyleBlackTranslucent;
    toolBar.barTintColor = [UIColor colorWithRed:0.f green:(float)0x7A/0xff blue:1 alpha:1.0];
    toolBar.translucent = YES;
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneWriting)];
    doneButton.tintColor = [UIColor whiteColor];
    [toolBar setItems:[NSArray arrayWithObjects:doneButton, nil]];
    self.postTextView.inputAccessoryView = toolBar;
}

- (void) initPhotoView
{
    self.cameraRollButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
    [self.cameraRollButton addTarget:self action:@selector(cameraRollButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.cameraRollButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.cameraRollButton setTitle:@"CAMERA ROLL" forState:UIControlStateNormal];
    
    self.nextButton = [[UIBarButtonItem alloc] initWithTitle:@"Preview" style:UIBarButtonItemStyleDone target:self action:@selector(nextButtonClicked)];
    self.nextButton.enabled = NO;

    self.photoCamera = [[GPUImageStillCamera alloc] init];
    self.photoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    self.photoCamera.runBenchmark = YES;
    
    self.videoCamera = [[GPUImageVideoCamera alloc] init];
    self.videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    self.videoCamera.runBenchmark = YES;
    
    self.currentFilter = [[GPUImageFilter alloc] init];

    [self.photoCamera addTarget:self.currentFilter];
    [self.currentFilter addTarget:self.gpuCameraView];
    [self.photoCamera startCameraCapture];
    
    [self.gpuCameraView setFillMode:kGPUImageFillModeStretch];
    [self.gpuCameraView_HD setFillMode:kGPUImageFillModeStretch];
    
    
    [self.mainScrollView setContentSize:CGSizeMake(self.mainScrollView.frame.size.width*2, self.mainScrollView.frame.size.height)];
    [self.mainScrollView setDelegate:self];
    self.mainScrollView.bounces = NO;
    [self.cameraScrollView setDelegate:self];
    self.cameraScrollView.bounces = NO;
    
    
    [self.recordPhotoButton setImage:[UIImage imageNamed:@"record_pic_button"] forState:UIControlStateNormal];
    [self.recordPhotoButton addTarget:self action:@selector(recordButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    
    [self.recordVideoButton setImage:[UIImage imageNamed:@"Record_Normal"] forState:UIControlStateNormal];
    [self.recordVideoButton setImage:[UIImage imageNamed:@"Record_Pressed"] forState:UIControlStateSelected];
    [self.recordVideoButton addTarget:self action:@selector(recordVideoButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    
    self.filtersTableView = [[UITableView alloc] initWithFrame:CGRectMake(100, -100, 120, 320) style:UITableViewStylePlain];
    self.filtersTableView.backgroundColor = [UIColor colorWithRed:0.f green:(float)0x7A/0xff blue:1 alpha:1.0];
    self.filtersTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.filtersTableView.showsVerticalScrollIndicator = NO;
    self.filtersTableView.delegate = self;
    self.filtersTableView.dataSource = self;
    self.filtersTableView.transform	= CGAffineTransformMakeRotation(-M_PI/2);
    [self.filterTableViewContainer addSubview:self.filtersTableView];
    
    self.filterBottomLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 2, 120)];
    self.filterBottomLine.backgroundColor = [UIColor whiteColor];
    [self.filtersTableView addSubview:self.filterBottomLine];
    
    self.prepareFilterQueue = dispatch_queue_create("com.diwublog.prepareFilterQueue", NULL);
}

- (void) recordVideoButtonClicked{
    if (self.recordVideoButton.tag == 0)
    {
        self.recordVideoButton.selected = !self.recordVideoButton.selected;
        [self takeVideo];
        if(!self.recordVideoButton.selected)
            [self recordButtonEnabled:NO];
    }else
    {
        self.gpuCameraView_HD.hidden = YES;
        
        if(self.stillImageSource != nil)
        {
            
        }else
        {
            [self.player pause];
            [self.movieFile removeAllTargets];
            [self.movieFile endProcessing];
            self.movieFile = nil;
        }
        [self recordButtonEnabled:YES];
        [self buttonProcess:self.videoButton];
    }
}

-(void) recordButtonClicked{
    if (self.recordPhotoButton.tag == 0)
    {
        [self takePhoto];
        [self recordButtonEnabled:NO];
    }else
    {
//        [self.videoCamera cancelAlbumPhotoAndGoBackToNormal];
        self.gpuCameraView_HD.hidden = YES;
        if(self.stillImageSource != nil)
        {
            
        }else
        {
            [self.player pause];
            [self.movieFile removeAllTargets];
            [self.movieFile endProcessing];
            self.movieFile = nil;
        }
        [self recordButtonEnabled:YES];
        [self buttonProcess:self.photoButton];
    }
}

- (void)playVideo
{
    double delayInSeconds = 0.5;
    dispatch_time_t stopTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(stopTime, dispatch_get_main_queue(), ^(void){
        NSString *pathToMovie = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Movie.m4v"];
        NSURL *movieURL = [NSURL fileURLWithPath:pathToMovie];
        self.videoUrl = movieURL;
        self.playItem = [[AVPlayerItem alloc] initWithURL:movieURL];
        self.player = [AVPlayer playerWithPlayerItem:self.playItem];
        
        self.movieFile = [[GPUImageMovie alloc] initWithPlayerItem:self.playItem];
        self.movieFile.runBenchmark = YES;
        self.movieFile.playAtActualSpeed = YES;
        self.currentFilter = [[GPUImageFilter alloc] init];
        
        [self.movieFile addTarget:self.currentFilter];
        
        // Only rotate the video for display, leave orientation the same for recording
        [self.currentFilter addTarget:self.gpuCameraView_HD];
        self.gpuCameraView_HD.hidden = NO;
        [self.movieFile startProcessing];
        self.player.rate = 1.0f;
        
        self.stillImageSource = nil;
        
        self.recordVideoButton.selected = NO;
        [self recordButtonEnabled:NO];
        NSLog(@"Movie completed");
    });
}

- (void)takeVideo
{
    if(!self.recordVideoButton.selected)
    {
        [self.videoCamera stopCameraCapture];
        [self.currentFilter removeTarget:self.movieWriter];
        self.videoCamera.audioEncodingTarget = nil;
        [self.movieWriter finishRecording];

        [self playVideo];
        self.isRecorded = NO;
        return;
    }
    
    NSString *pathToMovie = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Movie.m4v"];
    unlink([pathToMovie UTF8String]); // If a file already exists, AVAssetWriter won't let you record new frames, so delete the old movie
    NSURL *movieURL = [NSURL fileURLWithPath:pathToMovie];
    self.movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:movieURL size:CGSizeMake(480.0, 640.0)];
    self.movieWriter.encodingLiveVideo = YES;
    [self.currentFilter addTarget:self.movieWriter];
    [self.currentFilter addTarget:self.gpuCameraView];
    
    NSLog(@"Start recording");
    
    self.videoCamera.audioEncodingTarget = self.movieWriter;
    [self.movieWriter startRecording];
    
    self.isRecorded = YES;
    double delayInSeconds = 20.0;
    dispatch_time_t stopTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(stopTime, dispatch_get_main_queue(), ^(void){
        if (self.isRecorded)
        {
            [self.videoCamera stopCameraCapture];
            [self.currentFilter removeTarget:self.movieWriter];
            self.videoCamera.audioEncodingTarget = nil;
            [self.movieWriter finishRecording];
            [self playVideo];
        }
    });
}

- (void)takePhoto
{
    [self.photoCamera capturePhotoAsSampleBufferWithCompletionHandler:^(CMSampleBufferRef imageSampleBuffer, NSError *error) {
        [self.photoCamera stopCameraCapture];
        NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
        UIImage *image = [[UIImage alloc] initWithData:imageData];
        image = [image imageRotatedByDegrees:90];
        self.rawImage = image;
        self.currentFilter = [[GPUImageFilter alloc] init];
        self.stillImageSource = [[GPUImagePicture alloc] initWithImage:self.rawImage smoothlyScaleOutput:YES];
        [self.stillImageSource addTarget:self.currentFilter];
        
        [self.currentFilter addTarget:self.gpuCameraView_HD];

        dispatch_async(self.prepareFilterQueue, ^{
            
            [self performSelectorOnMainThread:@selector(stillImageProcess) withObject:nil waitUntilDone:NO];
        });
    }];
}
- (IBAction)switchCameraButtonClicked:(id)sender {
    if (self.photoCamera.cameraPosition == AVCaptureDevicePositionBack)
    {
        self.photoCamera = [[GPUImageStillCamera alloc] initWithSessionPreset:AVCaptureSessionPresetPhoto cameraPosition:AVCaptureDevicePositionFront];
        [self.photoCamera setHorizontallyMirrorFrontFacingCamera:YES];
        self.photoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
        self.photoCamera.runBenchmark = YES;
        
        self.videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPresetPhoto cameraPosition:AVCaptureDevicePositionFront];
        [self.videoCamera setHorizontallyMirrorFrontFacingCamera:YES];
        self.videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
        self.videoCamera.runBenchmark = YES;
        if (self.photoButton.selected)
            [self buttonProcess:self.photoButton];
        else if (self.videoButton.selected)
            [self buttonProcess:self.videoButton];
    }else
    {
        self.photoCamera = [[GPUImageStillCamera alloc] initWithSessionPreset:AVCaptureSessionPresetPhoto cameraPosition:AVCaptureDevicePositionBack];
        [self.photoCamera setHorizontallyMirrorFrontFacingCamera:YES];
        self.photoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
        self.photoCamera.runBenchmark = YES;
        
        self.videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPresetPhoto cameraPosition:AVCaptureDevicePositionBack];
        [self.videoCamera setHorizontallyMirrorFrontFacingCamera:YES];
        self.videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
        self.videoCamera.runBenchmark = YES;
        if (self.photoButton.selected)
            [self buttonProcess:self.photoButton];
        else if (self.videoButton.selected)
            [self buttonProcess:self.videoButton];
    }
}

#pragma mark - Proper Size For Resizing Large Image
- (CGSize)properSizeForResizingLargeImage:(UIImage *)originaUIImage {
    float originalWidth = originaUIImage.size.width;
    float originalHeight = originaUIImage.size.height;
    float smallerSide = 0.0f;
    float scalingFactor = 0.0f;
    
    if (originalWidth < originalHeight) {
        smallerSide = originalWidth;
        scalingFactor = 640.0f / smallerSide;
        return CGSizeMake(640.0f, originalHeight*scalingFactor);
    } else {
        smallerSide = originalHeight;
        scalingFactor = 640.0f / smallerSide;
        return CGSizeMake(originalWidth*scalingFactor, 640.0f);
    }
}

- (void) recordButtonEnabled:(BOOL)enabled
{
    if (enabled)
    {
        [self.recordPhotoButton setImage:[UIImage imageNamed:@"record_pic_button"] forState:UIControlStateNormal];
        self.recordPhotoButton.tag = 0;
        self.nextButton.enabled = NO;
        
        [self.recordVideoButton setImage:[UIImage imageNamed:@"Record_Normal"] forState:UIControlStateNormal];
        [self.recordVideoButton setImage:[UIImage imageNamed:@"Record_Pressed"] forState:UIControlStateSelected];
        self.recordVideoButton.tag = 0;
//        self.switchCameraButton.hidden = NO;
        self.switchCameraButton.hidden = YES;
    }else
    {
        [self.recordPhotoButton setImage:[UIImage imageNamed:@"delete.png"] forState:UIControlStateNormal];
        self.recordPhotoButton.tag = 1;
        
        [self.recordVideoButton setImage:[UIImage imageNamed:@"delete.png"] forState:UIControlStateNormal];
        self.recordVideoButton.tag = 1;
        self.nextButton.enabled = YES;
        self.switchCameraButton.hidden = YES;
    }
}
#pragma mark - Post TextView
- (void) doneWriting{
    [self.view endEditing:YES];
}

- (void)textViewDidChange:(UITextView *)textView
{
    if(textView.text.length > 0)
    {
        self.postButton.enabled = YES;
    }else
    {
        self.postButton.enabled = NO;
    }
}

#pragma mark - UIScrollView delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{

}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat pageWidth = scrollView.frame.size.width;
    int page = floor((scrollView.contentOffset.x - pageWidth/2) / pageWidth) + 1;
    if (scrollView == self.mainScrollView && !self.videoButton.selected)
    {
        if (self.photoButton.tag == page+1)
        {
            [self buttonProcess:self.photoButton];
        }else if (self.textButton.tag == page+1)
        {
            [self buttonProcess:self.textButton];
        }
    }else if (scrollView == self.cameraScrollView)
    {
        if (self.photoButton.tag == page+2)
        {
            [self buttonProcess:self.photoButton];
        }else if (self.videoButton.tag == page+2)
        {
            [self buttonProcess:self.videoButton];
        }
    }
}

#pragma mark - Top Navigation Process

- (void) closeButtonClicked{
    if (!self.filterTableViewContainer.hidden)
    {
        self.filterTableViewContainer.hidden = YES;
        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:self.nextButton, nil];
        self.title = @"";
        self.navigationItem.titleView = self.cameraRollButton;
        self.mainScrollView.scrollEnabled = YES;
        self.cameraScrollView.scrollEnabled = YES;
        self.currentType = IF_NORMAL_FILTER;
//        [self.videoCamera switchFilter:IF_NORMAL_FILTER];
        CGRect cellRect = [self.filtersTableView rectForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        CGRect tempRect = self.filterBottomLine.frame;
        tempRect.origin.y = cellRect.origin.y;
        self.filterBottomLine.frame = tempRect;
        [self.filtersTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }else
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void) muteButtonClicked
{
    self.muteCustomButton.selected = !self.muteCustomButton.selected;
    [self.player setMuted:self.muteCustomButton.selected];
}

- (void) postButtonClicked{
    [self.view endEditing:YES];
    PFUser *user = [PFUser currentUser];
    [ProgressHUD show:@"Worth the wait, promise!"];
    
//    NSData *data = UIImageJPEGRepresentation(self.rawImage, 1.0);
//    PFFile *imagefile = [PFFile fileWithName:@"post.png" data:data];
    
    PFGeoPoint *point = [PFGeoPoint geoPointWithLatitude:[AppDelegate sharedAppDelegate].currentLoc.coordinate.latitude longitude:[AppDelegate sharedAppDelegate].currentLoc.coordinate.longitude];
    
    PFObject *mediaPost = [PFObject objectWithClassName:@"AnonymousPost"];
    mediaPost[@"User"] = user.objectId;
    mediaPost[@"postUser"] = user;

//    mediaPost[@"thumbImage"] = imagefile;
    mediaPost[@"postPosition"] = point;
    
    if (self.textButton.selected) {
        mediaPost[@"postText"] = self.postTextView.text;
        mediaPost[@"postTitle"] = [self.postTextView.text substringToIndex:MIN(self.postTextView.text.length,10)];
        mediaPost[@"mediaType"] = @"Text";
        
        [mediaPost saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            [ProgressHUD dismiss];
            
            if (succeeded) {
                // The object has been saved.
                [self dismissViewControllerAnimated:YES completion:nil];
            } else {
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Error" message:error.description delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                [alertView show];
            }
        }];
    }else if (self.photoButton.selected)
    {

        UIImage *filterimage = [self getFilterImage];
        NSData *data = UIImageJPEGRepresentation(filterimage, 1.0);
        PFFile *imagefile = [PFFile fileWithName:@"post.png" data:data];
        mediaPost[@"thumbImage"] = imagefile;
        mediaPost[@"postImage"] = imagefile;
        mediaPost[@"mediaType"] = @"Photo";
        
        [mediaPost saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            [ProgressHUD dismiss];
            
            if (succeeded) {
                // The object has been saved.
                [self dismissViewControllerAnimated:YES completion:nil];
            } else {
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Error" message:error.description delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                [alertView show];
            }
        }];
    }else if (self.videoButton.selected)
    {
        [self getFilterVideo:^{
            NSString *pathToPostMovie = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Post.m4v"];
            NSURL *postMovieURL = [NSURL fileURLWithPath:pathToPostMovie];
            NSData *data = [NSData dataWithContentsOfFile:pathToPostMovie];
            PFFile *videoFile = [PFFile fileWithName:@"post.m4v" data:data];
            
            data = UIImageJPEGRepresentation([[AppDelegate sharedAppDelegate] loadImage:postMovieURL], 1.0);
            PFFile *imagefile = [PFFile fileWithName:@"post.png" data:data];
            
            mediaPost[@"postVideo"] = videoFile;
            mediaPost[@"mediaType"] = @"Video";
            mediaPost[@"thumbImage"] = imagefile;
            [mediaPost saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                [ProgressHUD dismiss];
                
                if (succeeded) {
                    // The object has been saved.
                    [self dismissViewControllerAnimated:YES completion:nil];
                } else {
                    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Error" message:error.description delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                    [alertView show];
                }
            }];
        }];
    }
}

- (void) getFilterVideo:(void(^)())handler
{
    self.movieFile = [[GPUImageMovie alloc] initWithURL:self.videoUrl];
    self.movieFile.runBenchmark = YES;
    self.movieFile.playAtActualSpeed = NO;
    
    switch (self.currentType) {
            //            case IF_AMARO_FILTER: {
            //                self.currentFilter = [[IFAmaroFilter alloc] init];
            //                if (self.stillImageSource != nil)
            //                {
            //                    self.stillImageSource = [[GPUImagePicture alloc] initWithImage:self.rawImage smoothlyScaleOutput:YES];
            //                }
            //                self.internalSourcePicture1 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"blackboard1024" ofType:@"png"]]];
            //                self.internalSourcePicture2 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"overlayMap" ofType:@"png"]]];
            //                self.internalSourcePicture3 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"amaroMap" ofType:@"png"]]];
            //
            //                [self.internalSourcePicture1 addTarget:self.currentFilter];
            //                [self.internalSourcePicture2 addTarget:self.currentFilter];
            //                [self.internalSourcePicture3 addTarget:self.currentFilter];
            //                break;
            //            }
            
        case IF_NORMAL_FILTER: {
            self.currentFilter = [[GPUImageFilter alloc] init];
            [self.movieFile addTarget:self.currentFilter];
            
            break;
        }
            
            //            case IF_RISE_FILTER: {
            //                self.currentFilter = [[IFRiseFilter alloc] init];
            //                if (self.stillImageSource != nil)
            //                {
            //                    self.stillImageSource = [[GPUImagePicture alloc] initWithImage:self.rawImage smoothlyScaleOutput:YES];
            //                }
            //                self.internalSourcePicture1 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"blackboard1024" ofType:@"png"]]];
            //                self.internalSourcePicture2 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"overlayMap" ofType:@"png"]]];
            //                self.internalSourcePicture3 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"riseMap" ofType:@"png"]]];
            //
            //                [self.internalSourcePicture1 addTarget:self.currentFilter];
            //                [self.internalSourcePicture2 addTarget:self.currentFilter];
            //                [self.internalSourcePicture3 addTarget:self.currentFilter];
            //                break;
            //            }
            
            //            case IF_HUDSON_FILTER: {
            //                self.currentFilter = [[IFHudsonFilter alloc] init];
            //                if (self.stillImageSource != nil)
            //                {
            //                    self.stillImageSource = [[GPUImagePicture alloc] initWithImage:self.rawImage smoothlyScaleOutput:YES];
            //                }
            //                self.internalSourcePicture1 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"hudsonBackground" ofType:@"png"]]];
            //                self.internalSourcePicture2 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"overlayMap" ofType:@"png"]]];
            //                self.internalSourcePicture3 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"hudsonMap" ofType:@"png"]]];
            //
            //                [self.internalSourcePicture1 addTarget:self.currentFilter];
            //                [self.internalSourcePicture2 addTarget:self.currentFilter];
            //                [self.internalSourcePicture3 addTarget:self.currentFilter];
            //                break;
            //            }
            
        case IF_XPROII_FILTER: {
            self.currentFilter = [[IFXproIIFilter alloc] init];
            [self.movieFile addTarget:self.currentFilter];
            self.internalSourcePicture1 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"xproMap" ofType:@"png"]]];
            self.internalSourcePicture2 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"vignetteMap" ofType:@"png"]]];
            [self.internalSourcePicture1 addTarget:self.currentFilter];
            [self.internalSourcePicture2 addTarget:self.currentFilter];
            [self.internalSourcePicture1 processImage];
            [self.internalSourcePicture2 processImage];
            break;
        }
            
            //            case IF_SIERRA_FILTER: {
            //                self.currentFilter = [[IFSierraFilter alloc] init];
            //                if (self.stillImageSource != nil)
            //                {
            //                    self.stillImageSource = [[GPUImagePicture alloc] initWithImage:self.rawImage smoothlyScaleOutput:YES];
            //                }
            //                self.internalSourcePicture1 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"sierraVignette" ofType:@"png"]]];
            //                self.internalSourcePicture2 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"overlayMap" ofType:@"png"]]];
            //                self.internalSourcePicture3 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"sierraMap" ofType:@"png"]]];
            //
            //                [self.internalSourcePicture1 addTarget:self.currentFilter];
            //                [self.internalSourcePicture2 addTarget:self.currentFilter];
            //                [self.internalSourcePicture3 addTarget:self.currentFilter];
            //
            //                break;
            //            }
            
        case IF_LOMOFI_FILTER: {
            self.currentFilter = [[IFLomofiFilter alloc] init];
            [self.movieFile addTarget:self.currentFilter];
            self.internalSourcePicture1 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"lomoMap" ofType:@"png"]]];
            self.internalSourcePicture2 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"vignetteMap" ofType:@"png"]]];
            
            [self.internalSourcePicture1 addTarget:self.currentFilter];
            [self.internalSourcePicture2 addTarget:self.currentFilter];
            [self.internalSourcePicture1 processImage];
            [self.internalSourcePicture2 processImage];
            break;
        }
            
            //            case IF_EARLYBIRD_FILTER: {
            //                self.currentFilter = [[IFEarlybirdFilter alloc] init];
            //                if (self.stillImageSource != nil)
            //                {
            //                    self.stillImageSource = [[GPUImagePicture alloc] initWithImage:self.rawImage smoothlyScaleOutput:YES];
            //                }
            //                self.internalSourcePicture1 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"earlyBirdCurves" ofType:@"png"]]];
            //                self.internalSourcePicture2 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"earlybirdOverlayMap" ofType:@"png"]]];
            //                self.internalSourcePicture3 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"vignetteMap" ofType:@"png"]]];
            //                self.internalSourcePicture4 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"earlybirdBlowout" ofType:@"png"]]];
            //                self.internalSourcePicture5 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"earlybirdMap" ofType:@"png"]]];
            //
            //                [self.internalSourcePicture1 addTarget:self.currentFilter];
            //                [self.internalSourcePicture2 addTarget:self.currentFilter];
            //                [self.internalSourcePicture3 addTarget:self.currentFilter];
            //                [self.internalSourcePicture4 addTarget:self.currentFilter];
            //                [self.internalSourcePicture5 addTarget:self.currentFilter];
            //                break;
            //            }
            
            //            case IF_SUTRO_FILTER: {
            //                self.currentFilter = [[IFSutroFilter alloc] init];
            //                if (self.stillImageSource != nil)
            //                {
            //                    self.stillImageSource = [[GPUImagePicture alloc] initWithImage:self.rawImage smoothlyScaleOutput:YES];
            //                }
            //                self.internalSourcePicture1 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"vignetteMap" ofType:@"png"]]];
            //                self.internalSourcePicture2 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"sutroMetal" ofType:@"png"]]];
            //                self.internalSourcePicture3 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"softLight" ofType:@"png"]]];
            //                self.internalSourcePicture4 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"sutroEdgeBurn" ofType:@"png"]]];
            //                self.internalSourcePicture5 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"sutroCurves" ofType:@"png"]]];
            //
            //                [self.internalSourcePicture1 addTarget:self.currentFilter];
            //                [self.internalSourcePicture2 addTarget:self.currentFilter];
            //                [self.internalSourcePicture3 addTarget:self.currentFilter];
            //                [self.internalSourcePicture4 addTarget:self.currentFilter];
            //                [self.internalSourcePicture5 addTarget:self.currentFilter];
            //                break;
            //            }
            
            //            case IF_TOASTER_FILTER: {
            //                self.currentFilter = [[IFToasterFilter alloc] init];
            //                if (self.stillImageSource != nil)
            //                {
            //                    self.stillImageSource = [[GPUImagePicture alloc] initWithImage:self.rawImage smoothlyScaleOutput:YES];
            //                }
            //                self.internalSourcePicture1 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"toasterMetal" ofType:@"png"]]];
            //                self.internalSourcePicture2 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"toasterSoftLight" ofType:@"png"]]];
            //                self.internalSourcePicture3 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"toasterCurves" ofType:@"png"]]];
            //                self.internalSourcePicture4 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"toasterOverlayMapWarm" ofType:@"png"]]];
            //                self.internalSourcePicture5 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"toasterColorShift" ofType:@"png"]]];
            //
            //                [self.internalSourcePicture1 addTarget:self.currentFilter];
            //                [self.internalSourcePicture2 addTarget:self.currentFilter];
            //                [self.internalSourcePicture3 addTarget:self.currentFilter];
            //                [self.internalSourcePicture4 addTarget:self.currentFilter];
            //                [self.internalSourcePicture5 addTarget:self.currentFilter];
            //                break;
            //            }
            
            //            case IF_BRANNAN_FILTER: {
            //                self.currentFilter = [[IFBrannanFilter alloc] init];
            //                if (self.stillImageSource != nil)
            //                {
            //                    self.stillImageSource = [[GPUImagePicture alloc] initWithImage:self.rawImage smoothlyScaleOutput:YES];
            //                }
            //                self.internalSourcePicture1 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"brannanProcess" ofType:@"png"]]];
            //                self.internalSourcePicture2 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"brannanBlowout" ofType:@"png"]]];
            //                self.internalSourcePicture3 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"brannanContrast" ofType:@"png"]]];
            //                self.internalSourcePicture4 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"brannanLuma" ofType:@"png"]]];
            //                self.internalSourcePicture5 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"brannanScreen" ofType:@"png"]]];
            //
            //                [self.internalSourcePicture1 addTarget:self.currentFilter];
            //                [self.internalSourcePicture2 addTarget:self.currentFilter];
            //                [self.internalSourcePicture3 addTarget:self.currentFilter];
            //                [self.internalSourcePicture4 addTarget:self.currentFilter];
            //                [self.internalSourcePicture5 addTarget:self.currentFilter];
            //                break;
            //            }
            
        case IF_INKWELL_FILTER: {
            self.currentFilter = [[IFInkwellFilter alloc] init];
            [self.movieFile addTarget:self.currentFilter];
            
            self.internalSourcePicture1 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"inkwellMap" ofType:@"png"]]];
            [self.internalSourcePicture1 addTarget:self.currentFilter];
            [self.internalSourcePicture1 processImage];
            break;
        }
            
        case IF_WALDEN_FILTER: {
            self.currentFilter = [[IFWaldenFilter alloc] init];
            [self.movieFile addTarget:self.currentFilter];
            self.internalSourcePicture1 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"waldenMap" ofType:@"png"]]];
            self.internalSourcePicture2 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"vignetteMap" ofType:@"png"]]];
            
            [self.internalSourcePicture1 addTarget:self.currentFilter];
            [self.internalSourcePicture2 addTarget:self.currentFilter];
            [self.internalSourcePicture1 processImage];
            [self.internalSourcePicture2 processImage];
            break;
        }
            
            //            case IF_HEFE_FILTER: {
            //                self.currentFilter = [[IFHefeFilter alloc] init];
            //                if (self.stillImageSource != nil)
            //                {
            //                    self.stillImageSource = [[GPUImagePicture alloc] initWithImage:self.rawImage smoothlyScaleOutput:YES];
            //                }
            //                self.internalSourcePicture1 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"edgeBurn" ofType:@"png"]]];
            //                self.internalSourcePicture2 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"hefeMap" ofType:@"png"]]];
            //                self.internalSourcePicture3 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"hefeGradientMap" ofType:@"png"]]];
            //                self.internalSourcePicture4 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"hefeSoftLight" ofType:@"png"]]];
            //                self.internalSourcePicture5 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"hefeMetal" ofType:@"png"]]];
            //
            //                [self.internalSourcePicture1 addTarget:self.currentFilter];
            //                [self.internalSourcePicture2 addTarget:self.currentFilter];
            //                [self.internalSourcePicture3 addTarget:self.currentFilter];
            //                [self.internalSourcePicture4 addTarget:self.currentFilter];
            //                [self.internalSourcePicture5 addTarget:self.currentFilter];
            //                break;
            //            }
            
        case IF_VALENCIA_FILTER: {
            self.currentFilter = [[IFValenciaFilter alloc] init];
            [self.movieFile addTarget:self.currentFilter];
            self.internalSourcePicture1 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"valenciaMap" ofType:@"png"]]];
            self.internalSourcePicture2 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"valenciaGradientMap" ofType:@"png"]]];
            
            [self.internalSourcePicture1 addTarget:self.currentFilter];
            [self.internalSourcePicture2 addTarget:self.currentFilter];
            [self.internalSourcePicture1 processImage];
            [self.internalSourcePicture2 processImage];
            break;
        }
            
        case IF_NASHVILLE_FILTER: {
            self.currentFilter = [[IFNashvilleFilter alloc] init];
            [self.movieFile addTarget:self.currentFilter];
            self.internalSourcePicture1 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"nashvilleMap" ofType:@"png"]]];
            
            [self.internalSourcePicture1 addTarget:self.currentFilter];
            [self.internalSourcePicture1 processImage];
            break;
        }
            
        case IF_1977_FILTER: {
            self.currentFilter = [[IF1977Filter alloc] init];
            [self.movieFile addTarget:self.currentFilter];
            self.internalSourcePicture1 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"1977map" ofType:@"png"]]];
            self.internalSourcePicture2 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"1977blowout" ofType:@"png"]]];
            
            [self.internalSourcePicture1 addTarget:self.currentFilter];
            [self.internalSourcePicture2 addTarget:self.currentFilter];
            [self.internalSourcePicture1 processImage];
            [self.internalSourcePicture2 processImage];
            break;
        }
            
        case IF_LORDKELVIN_FILTER: {
            self.currentFilter = [[IFLordKelvinFilter alloc] init];
            [self.movieFile addTarget:self.currentFilter];
            self.internalSourcePicture1 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"kelvinMap" ofType:@"png"]]];
            
            [self.internalSourcePicture1 addTarget:self.currentFilter];
            [self.internalSourcePicture1 processImage];
            break;
        }
            
        default:
            break;
    }
    
    // In addition to displaying to the screen, write out a processed version of the movie to disk
    NSString *pathToPostMovie = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Post.m4v"];
    unlink([pathToPostMovie UTF8String]); // If a file already exists, AVAssetWriter won't let you record new frames, so delete the old movie
    NSURL *postMovieURL = [NSURL fileURLWithPath:pathToPostMovie];

    self.movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:postMovieURL size:CGSizeMake(640.0, 480.0)];
    [self.currentFilter addTarget:self.movieWriter];

    // Configure this for video from the movie file, where we want to preserve all video frames and audio samples
    self.movieWriter.shouldPassthroughAudio = !self.muteCustomButton.selected;
    if (!self.muteCustomButton.selected)
        self.movieFile.audioEncodingTarget = self.movieWriter;
    [self.movieFile enableSynchronizedEncodingUsingMovieWriter:self.movieWriter];

    [self.movieWriter startRecording];
    [self.movieFile startProcessing];

    __weak NewPostViewController *weakSelf = self;
    [self.movieWriter setCompletionBlock:^{
        [weakSelf.currentFilter removeTarget:weakSelf.movieWriter];
        [weakSelf.movieWriter finishRecording];
        if (handler)
            handler();
    }];
}

- (UIImage*) getFilterImage
{
    switch (self.currentType) {
//            case IF_AMARO_FILTER: {
//                self.currentFilter = [[IFAmaroFilter alloc] init];
//                if (self.stillImageSource != nil)
//                {
//                    self.stillImageSource = [[GPUImagePicture alloc] initWithImage:self.rawImage smoothlyScaleOutput:YES];
//                }
//                self.internalSourcePicture1 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"blackboard1024" ofType:@"png"]]];
//                self.internalSourcePicture2 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"overlayMap" ofType:@"png"]]];
//                self.internalSourcePicture3 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"amaroMap" ofType:@"png"]]];
//
//                [self.internalSourcePicture1 addTarget:self.currentFilter];
//                [self.internalSourcePicture2 addTarget:self.currentFilter];
//                [self.internalSourcePicture3 addTarget:self.currentFilter];
//                break;
//            }
            
        case IF_NORMAL_FILTER: {
            self.currentFilter = [[IFNormalFilter alloc] init];
            if (self.stillImageSource != nil)
            {
                self.stillImageSource = [[GPUImagePicture alloc] initWithImage:self.rawImage smoothlyScaleOutput:YES];
                [self.stillImageSource addTarget:self.currentFilter];
            }
            [self.stillImageSource processImage];
            
            break;
        }
            
//            case IF_RISE_FILTER: {
//                self.currentFilter = [[IFRiseFilter alloc] init];
//                if (self.stillImageSource != nil)
//                {
//                    self.stillImageSource = [[GPUImagePicture alloc] initWithImage:self.rawImage smoothlyScaleOutput:YES];
//                }
//                self.internalSourcePicture1 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"blackboard1024" ofType:@"png"]]];
//                self.internalSourcePicture2 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"overlayMap" ofType:@"png"]]];
//                self.internalSourcePicture3 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"riseMap" ofType:@"png"]]];
//
//                [self.internalSourcePicture1 addTarget:self.currentFilter];
//                [self.internalSourcePicture2 addTarget:self.currentFilter];
//                [self.internalSourcePicture3 addTarget:self.currentFilter];
//                break;
//            }

//            case IF_HUDSON_FILTER: {
//                self.currentFilter = [[IFHudsonFilter alloc] init];
//                if (self.stillImageSource != nil)
//                {
//                    self.stillImageSource = [[GPUImagePicture alloc] initWithImage:self.rawImage smoothlyScaleOutput:YES];
//                }
//                self.internalSourcePicture1 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"hudsonBackground" ofType:@"png"]]];
//                self.internalSourcePicture2 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"overlayMap" ofType:@"png"]]];
//                self.internalSourcePicture3 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"hudsonMap" ofType:@"png"]]];
//
//                [self.internalSourcePicture1 addTarget:self.currentFilter];
//                [self.internalSourcePicture2 addTarget:self.currentFilter];
//                [self.internalSourcePicture3 addTarget:self.currentFilter];
//                break;
//            }
            
        case IF_XPROII_FILTER: {
            self.currentFilter = [[IFXproIIFilter alloc] init];
            if (self.stillImageSource != nil)
            {
                self.stillImageSource = [[GPUImagePicture alloc] initWithImage:self.rawImage smoothlyScaleOutput:YES];
                [self.stillImageSource addTarget:self.currentFilter];
                [self.stillImageSource processImage];
            }
            [self.currentFilter useNextFrameForImageCapture];
            self.internalSourcePicture1 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"xproMap" ofType:@"png"]]];
            self.internalSourcePicture2 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"vignetteMap" ofType:@"png"]]];
            [self.internalSourcePicture1 addTarget:self.currentFilter];
            [self.internalSourcePicture2 addTarget:self.currentFilter];
            [self.internalSourcePicture1 processImage];
            [self.internalSourcePicture2 processImage];
            break;
        }
            
//            case IF_SIERRA_FILTER: {
//                self.currentFilter = [[IFSierraFilter alloc] init];
//                if (self.stillImageSource != nil)
//                {
//                    self.stillImageSource = [[GPUImagePicture alloc] initWithImage:self.rawImage smoothlyScaleOutput:YES];
//                }
//                self.internalSourcePicture1 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"sierraVignette" ofType:@"png"]]];
//                self.internalSourcePicture2 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"overlayMap" ofType:@"png"]]];
//                self.internalSourcePicture3 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"sierraMap" ofType:@"png"]]];
//
//                [self.internalSourcePicture1 addTarget:self.currentFilter];
//                [self.internalSourcePicture2 addTarget:self.currentFilter];
//                [self.internalSourcePicture3 addTarget:self.currentFilter];
//
//                break;
//            }
            
        case IF_LOMOFI_FILTER: {
            self.currentFilter = [[IFLomofiFilter alloc] init];
            if (self.stillImageSource != nil)
            {
                self.stillImageSource = [[GPUImagePicture alloc] initWithImage:self.rawImage smoothlyScaleOutput:YES];
                [self.stillImageSource addTarget:self.currentFilter];
                [self.stillImageSource processImage];
            }
            [self.currentFilter useNextFrameForImageCapture];
            self.internalSourcePicture1 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"lomoMap" ofType:@"png"]]];
            self.internalSourcePicture2 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"vignetteMap" ofType:@"png"]]];
            
            [self.internalSourcePicture1 addTarget:self.currentFilter];
            [self.internalSourcePicture2 addTarget:self.currentFilter];
            [self.internalSourcePicture1 processImage];
            [self.internalSourcePicture2 processImage];
            break;
        }
            
//            case IF_EARLYBIRD_FILTER: {
//                self.currentFilter = [[IFEarlybirdFilter alloc] init];
//                if (self.stillImageSource != nil)
//                {
//                    self.stillImageSource = [[GPUImagePicture alloc] initWithImage:self.rawImage smoothlyScaleOutput:YES];
//                }
//                self.internalSourcePicture1 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"earlyBirdCurves" ofType:@"png"]]];
//                self.internalSourcePicture2 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"earlybirdOverlayMap" ofType:@"png"]]];
//                self.internalSourcePicture3 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"vignetteMap" ofType:@"png"]]];
//                self.internalSourcePicture4 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"earlybirdBlowout" ofType:@"png"]]];
//                self.internalSourcePicture5 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"earlybirdMap" ofType:@"png"]]];
//
//                [self.internalSourcePicture1 addTarget:self.currentFilter];
//                [self.internalSourcePicture2 addTarget:self.currentFilter];
//                [self.internalSourcePicture3 addTarget:self.currentFilter];
//                [self.internalSourcePicture4 addTarget:self.currentFilter];
//                [self.internalSourcePicture5 addTarget:self.currentFilter];
//                break;
//            }

//            case IF_SUTRO_FILTER: {
//                self.currentFilter = [[IFSutroFilter alloc] init];
//                if (self.stillImageSource != nil)
//                {
//                    self.stillImageSource = [[GPUImagePicture alloc] initWithImage:self.rawImage smoothlyScaleOutput:YES];
//                }
//                self.internalSourcePicture1 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"vignetteMap" ofType:@"png"]]];
//                self.internalSourcePicture2 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"sutroMetal" ofType:@"png"]]];
//                self.internalSourcePicture3 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"softLight" ofType:@"png"]]];
//                self.internalSourcePicture4 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"sutroEdgeBurn" ofType:@"png"]]];
//                self.internalSourcePicture5 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"sutroCurves" ofType:@"png"]]];
//
//                [self.internalSourcePicture1 addTarget:self.currentFilter];
//                [self.internalSourcePicture2 addTarget:self.currentFilter];
//                [self.internalSourcePicture3 addTarget:self.currentFilter];
//                [self.internalSourcePicture4 addTarget:self.currentFilter];
//                [self.internalSourcePicture5 addTarget:self.currentFilter];
//                break;
//            }

//            case IF_TOASTER_FILTER: {
//                self.currentFilter = [[IFToasterFilter alloc] init];
//                if (self.stillImageSource != nil)
//                {
//                    self.stillImageSource = [[GPUImagePicture alloc] initWithImage:self.rawImage smoothlyScaleOutput:YES];
//                }
//                self.internalSourcePicture1 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"toasterMetal" ofType:@"png"]]];
//                self.internalSourcePicture2 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"toasterSoftLight" ofType:@"png"]]];
//                self.internalSourcePicture3 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"toasterCurves" ofType:@"png"]]];
//                self.internalSourcePicture4 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"toasterOverlayMapWarm" ofType:@"png"]]];
//                self.internalSourcePicture5 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"toasterColorShift" ofType:@"png"]]];
//
//                [self.internalSourcePicture1 addTarget:self.currentFilter];
//                [self.internalSourcePicture2 addTarget:self.currentFilter];
//                [self.internalSourcePicture3 addTarget:self.currentFilter];
//                [self.internalSourcePicture4 addTarget:self.currentFilter];
//                [self.internalSourcePicture5 addTarget:self.currentFilter];
//                break;
//            }

//            case IF_BRANNAN_FILTER: {
//                self.currentFilter = [[IFBrannanFilter alloc] init];
//                if (self.stillImageSource != nil)
//                {
//                    self.stillImageSource = [[GPUImagePicture alloc] initWithImage:self.rawImage smoothlyScaleOutput:YES];
//                }
//                self.internalSourcePicture1 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"brannanProcess" ofType:@"png"]]];
//                self.internalSourcePicture2 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"brannanBlowout" ofType:@"png"]]];
//                self.internalSourcePicture3 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"brannanContrast" ofType:@"png"]]];
//                self.internalSourcePicture4 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"brannanLuma" ofType:@"png"]]];
//                self.internalSourcePicture5 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"brannanScreen" ofType:@"png"]]];
//
//                [self.internalSourcePicture1 addTarget:self.currentFilter];
//                [self.internalSourcePicture2 addTarget:self.currentFilter];
//                [self.internalSourcePicture3 addTarget:self.currentFilter];
//                [self.internalSourcePicture4 addTarget:self.currentFilter];
//                [self.internalSourcePicture5 addTarget:self.currentFilter];
//                break;
//            }
            
        case IF_INKWELL_FILTER: {
            self.currentFilter = [[IFInkwellFilter alloc] init];
            if (self.stillImageSource != nil)
            {
                self.stillImageSource = [[GPUImagePicture alloc] initWithImage:self.rawImage smoothlyScaleOutput:YES];
                [self.stillImageSource addTarget:self.currentFilter];
                [self.stillImageSource processImage];
            }
            [self.currentFilter useNextFrameForImageCapture];
            
            self.internalSourcePicture1 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"inkwellMap" ofType:@"png"]]];
            [self.internalSourcePicture1 addTarget:self.currentFilter];
            [self.internalSourcePicture1 processImage];
            break;
        }
            
        case IF_WALDEN_FILTER: {
            self.currentFilter = [[IFWaldenFilter alloc] init];
            if (self.stillImageSource != nil)
            {
                self.stillImageSource = [[GPUImagePicture alloc] initWithImage:self.rawImage smoothlyScaleOutput:YES];
                [self.stillImageSource addTarget:self.currentFilter];
                [self.stillImageSource processImage];
            }
            [self.currentFilter useNextFrameForImageCapture];
            self.internalSourcePicture1 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"waldenMap" ofType:@"png"]]];
            self.internalSourcePicture2 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"vignetteMap" ofType:@"png"]]];
            
            [self.internalSourcePicture1 addTarget:self.currentFilter];
            [self.internalSourcePicture2 addTarget:self.currentFilter];
            [self.internalSourcePicture1 processImage];
            [self.internalSourcePicture2 processImage];
            break;
        }
            
//            case IF_HEFE_FILTER: {
//                self.currentFilter = [[IFHefeFilter alloc] init];
//                if (self.stillImageSource != nil)
//                {
//                    self.stillImageSource = [[GPUImagePicture alloc] initWithImage:self.rawImage smoothlyScaleOutput:YES];
//                }
//                self.internalSourcePicture1 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"edgeBurn" ofType:@"png"]]];
//                self.internalSourcePicture2 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"hefeMap" ofType:@"png"]]];
//                self.internalSourcePicture3 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"hefeGradientMap" ofType:@"png"]]];
//                self.internalSourcePicture4 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"hefeSoftLight" ofType:@"png"]]];
//                self.internalSourcePicture5 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"hefeMetal" ofType:@"png"]]];
//
//                [self.internalSourcePicture1 addTarget:self.currentFilter];
//                [self.internalSourcePicture2 addTarget:self.currentFilter];
//                [self.internalSourcePicture3 addTarget:self.currentFilter];
//                [self.internalSourcePicture4 addTarget:self.currentFilter];
//                [self.internalSourcePicture5 addTarget:self.currentFilter];
//                break;
//            }
            
        case IF_VALENCIA_FILTER: {
            self.currentFilter = [[IFValenciaFilter alloc] init];
            if (self.stillImageSource != nil)
            {
                self.stillImageSource = [[GPUImagePicture alloc] initWithImage:self.rawImage smoothlyScaleOutput:YES];
                [self.stillImageSource addTarget:self.currentFilter];
                [self.stillImageSource processImage];
            }
            [self.currentFilter useNextFrameForImageCapture];
            self.internalSourcePicture1 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"valenciaMap" ofType:@"png"]]];
            self.internalSourcePicture2 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"valenciaGradientMap" ofType:@"png"]]];
            
            [self.internalSourcePicture1 addTarget:self.currentFilter];
            [self.internalSourcePicture2 addTarget:self.currentFilter];
            [self.internalSourcePicture1 processImage];
            [self.internalSourcePicture2 processImage];
            break;
        }
            
        case IF_NASHVILLE_FILTER: {
            self.currentFilter = [[IFNashvilleFilter alloc] init];
            if (self.stillImageSource != nil)
            {
                self.stillImageSource = [[GPUImagePicture alloc] initWithImage:self.rawImage smoothlyScaleOutput:YES];
                [self.stillImageSource addTarget:self.currentFilter];
                [self.stillImageSource processImage];
            }
            [self.currentFilter useNextFrameForImageCapture];
            self.internalSourcePicture1 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"nashvilleMap" ofType:@"png"]]];
            
            [self.internalSourcePicture1 addTarget:self.currentFilter];
            [self.internalSourcePicture1 processImage];
            break;
        }
            
        case IF_1977_FILTER: {
            self.currentFilter = [[IF1977Filter alloc] init];
            if (self.stillImageSource != nil)
            {
                self.stillImageSource = [[GPUImagePicture alloc] initWithImage:self.rawImage smoothlyScaleOutput:YES];
                [self.stillImageSource addTarget:self.currentFilter];
                [self.stillImageSource processImage];
            }
            [self.currentFilter useNextFrameForImageCapture];
            self.internalSourcePicture1 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"1977map" ofType:@"png"]]];
            self.internalSourcePicture2 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"1977blowout" ofType:@"png"]]];
            
            [self.internalSourcePicture1 addTarget:self.currentFilter];
            [self.internalSourcePicture2 addTarget:self.currentFilter];
            [self.internalSourcePicture1 processImage];
            [self.internalSourcePicture2 processImage];
            break;
        }
            
        case IF_LORDKELVIN_FILTER: {
            self.currentFilter = [[IFLordKelvinFilter alloc] init];
            if (self.stillImageSource != nil)
            {
                self.stillImageSource = [[GPUImagePicture alloc] initWithImage:self.rawImage smoothlyScaleOutput:YES];
                [self.stillImageSource addTarget:self.currentFilter];
                [self.stillImageSource processImage];
            }
            [self.currentFilter useNextFrameForImageCapture];
            self.internalSourcePicture1 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"kelvinMap" ofType:@"png"]]];
            
            [self.internalSourcePicture1 addTarget:self.currentFilter];
            [self.internalSourcePicture1 processImage];
            break;
        }
            
        default:
            break;
    }
    return [self.currentFilter imageFromCurrentFramebuffer];
}
- (void) nextButtonClicked
{
    self.mainScrollView.scrollEnabled = NO;
    self.cameraScrollView.scrollEnabled = NO;
    self.filterTableViewContainer.hidden = NO;
    self.navigationItem.titleView = nil;
    self.postButton.enabled = YES;
    if (self.stillImageSource != nil)
        self.navigationItem.rightBarButtonItem = self.postButton;
    else
    {
        self.muteCustomButton.selected = NO;
        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:self.postButton,self.muteButton, nil];
    }
    self.title = @"FILTERS";
}

- (void) cameraRollButtonClicked
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    if (self.videoButton.selected)
    {
        picker.mediaTypes = [NSArray arrayWithObject:(NSString*)kUTTypeMovie];
        picker.videoMaximumDuration = 20.0f;
    }
    
    [self presentViewController:picker animated:YES completion:nil];
}

#pragma mark - Process Album Photo from Image Pick
- (UIImage *)processAlbumPhoto:(NSDictionary *)info {
    UIImage *originalImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    float original_width = originalImage.size.width;
    float original_height = originalImage.size.height;
    
    if ([info objectForKey:UIImagePickerControllerCropRect] == nil) {
        if (original_width < original_height) {
            /*
             UIGraphicsBeginImageContext(mask.size);
             [ori drawAtPoint:CGPointMake(0,0)];
             [mask drawAtPoint:CGPointMake(0,0)];
             
             UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
             UIGraphicsEndImageContext();
             return newImage;
             */
            return nil;
        } else {
            return nil;
        }
    } else {
        CGRect crop_rect = [[info objectForKey:UIImagePickerControllerCropRect] CGRectValue];
        float crop_width = crop_rect.size.width;
        float crop_height = crop_rect.size.height;
        float crop_x = crop_rect.origin.x;
        float crop_y = crop_rect.origin.y;
        float remaining_width = original_width - crop_x;
        float remaining_height = original_height - crop_y;
        
        // due to a bug in iOS
        if ( (crop_x + crop_width) > original_width) {
            NSLog(@" - a bug in x direction occurred! now we fix it!");
            crop_width = original_width - crop_x;
        }
        if ( (crop_y + crop_height) > original_height) {
            NSLog(@" - a bug in y direction occurred! now we fix it!");
            
            crop_height = original_height - crop_y;
        }
        
        float crop_longer_side = 0.0f;
        
        if (crop_width > crop_height) {
            crop_longer_side = crop_width;
        } else {
            crop_longer_side = crop_height;
        }
        //NSLog(@" - ow = %g, oh = %g", original_width, original_height);
        //NSLog(@" - cx = %g, cy = %g, cw = %g, ch = %g", crop_x, crop_y, crop_width, crop_height);
        //NSLog(@" - cls=%g, rw = %g, rh = %g", crop_longer_side, remaining_width, remaining_height);
        if ( (crop_longer_side <= remaining_width) && (crop_longer_side <= remaining_height) ) {
            UIImage *tmpImage = [originalImage cropImageWithBounds:CGRectMake(crop_x, crop_y, crop_longer_side, crop_longer_side)];
            
            return tmpImage;
        } else if ( (crop_longer_side <= remaining_width) && (crop_longer_side > remaining_height) ) {
            UIImage *tmpImage = [originalImage cropImageWithBounds:CGRectMake(crop_x, crop_y, crop_longer_side, remaining_height)];
            
            float new_y = (crop_longer_side - remaining_height) / 2.0f;
            //UIGraphicsBeginImageContext(CGSizeMake(crop_longer_side, crop_longer_side));
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(crop_longer_side, crop_longer_side), YES, 1.0f);
            [tmpImage drawAtPoint:CGPointMake(0.0f,new_y)];
            
            UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            return newImage;
        } else if ( (crop_longer_side > remaining_width) && (crop_longer_side <= remaining_height) ) {
            UIImage *tmpImage = [originalImage cropImageWithBounds:CGRectMake(crop_x, crop_y, remaining_width, crop_longer_side)];
            
            float new_x = (crop_longer_side - remaining_width) / 2.0f;
            //UIGraphicsBeginImageContext(CGSizeMake(crop_longer_side, crop_longer_side));
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(crop_longer_side, crop_longer_side), YES, 1.0f);
            [tmpImage drawAtPoint:CGPointMake(new_x,0.0f)];
            
            UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            return newImage;
        } else {
            return nil;
        }
        
    }
}

#pragma mark - UIImagePicker Delegate methods
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:(NSString*)kUTTypeMovie])
    {
        NSURL *url = [info objectForKey:UIImagePickerControllerMediaURL];
        self.videoUrl = url;
        self.playItem = [[AVPlayerItem alloc] initWithURL:url];
        self.player = [AVPlayer playerWithPlayerItem:self.playItem];
        
        self.movieFile = [[GPUImageMovie alloc] initWithPlayerItem:self.playItem];
        self.movieFile.runBenchmark = YES;
        self.movieFile.playAtActualSpeed = YES;
        self.currentFilter = [[GPUImageFilter alloc] init];
        
        [self.movieFile addTarget:self.currentFilter];
        
        // Only rotate the video for display, leave orientation the same for recording
        [self.currentFilter addTarget:self.gpuCameraView_HD];
        self.gpuCameraView_HD.hidden = NO;
        [self.movieFile startProcessing];
        self.player.rate = 1.0f;
        
        self.stillImageSource = nil;
        [self dismissViewControllerAnimated:YES completion:^(){
            [self recordButtonEnabled:NO];
        }];
    }else
    {
//        [self.videoCamera goBackToNormal];
//        self.videoCamera.rawImage = [self processAlbumPhoto:info];
//        [self.videoCamera switchFilter:self.currentType];
        [self.photoCamera stopCameraCapture];
        self.rawImage = [self processAlbumPhoto:info];
        self.currentFilter = [[GPUImageFilter alloc] init];
        self.stillImageSource = [[GPUImagePicture alloc] initWithImage:self.rawImage smoothlyScaleOutput:YES];
        [self.stillImageSource addTarget:self.currentFilter];
        [self.currentFilter addTarget:self.gpuCameraView_HD];
        [self.stillImageSource processImage];
//        [self.gpuCameraView_HD setInputRotation:kGPUImageRotateRight atIndex:0];
        double delayInSeconds = 0.5;
        dispatch_time_t stopTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(stopTime, dispatch_get_main_queue(), ^(void){
            [self performSelectorOnMainThread:@selector(stillImageProcess) withObject:nil waitUntilDone:NO];
        });
        [self dismissViewControllerAnimated:YES completion:^(){
            [self recordButtonEnabled:NO];
        }];
    }
}

-(void)repeatPlayVideo:(NSNotification*)notification
{
    [self.player seekToTime:CMTimeMake(0, 600.0)];
    [self.player play];
}
- (void) stillImageProcess
{
    self.gpuCameraView_HD.hidden = NO;
    [self.stillImageSource processImage];
    
//    UIImage *filterimage = [self.currentFilter imageFromCurrentFramebuffer];
//    [self.selectedImageView setImage:filterimage];
}

- (void)forceSwitchToNewFilter:(IFFilterType)type {
    
    dispatch_async(self.prepareFilterQueue, ^{
        switch (type) {
//            case IF_AMARO_FILTER: {
//                self.currentFilter = [[IFAmaroFilter alloc] init];
//                if (self.stillImageSource != nil)
//                {
//                    self.stillImageSource = [[GPUImagePicture alloc] initWithImage:self.rawImage smoothlyScaleOutput:YES];
//                    [self.stillImageSource addTarget:self.currentFilter];
//                }else
//                {
//                    [self.movieFile removeAllTargets];
//                    [self.movieFile addTarget:self.currentFilter];
//                }
//                self.internalSourcePicture1 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"blackboard1024" ofType:@"png"]]];
//                self.internalSourcePicture2 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"overlayMap" ofType:@"png"]]];
//                self.internalSourcePicture3 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"amaroMap" ofType:@"png"]]];
//                
//                [self.internalSourcePicture1 addTarget:self.currentFilter];
//                [self.internalSourcePicture2 addTarget:self.currentFilter];
//                [self.internalSourcePicture3 addTarget:self.currentFilter];
//                break;
//            }
                
            case IF_NORMAL_FILTER: {
                self.currentFilter = [[IFNormalFilter alloc] init];
                if (self.stillImageSource != nil)
                {
                    self.stillImageSource = [[GPUImagePicture alloc] initWithImage:self.rawImage smoothlyScaleOutput:YES];
                    [self.stillImageSource addTarget:self.currentFilter];
                }else
                {
                    [self.movieFile removeAllTargets];
                    [self.movieFile addTarget:self.currentFilter];
                }
                break;
            }
                
//            case IF_RISE_FILTER: {
//                self.currentFilter = [[IFRiseFilter alloc] init];
//                if (self.stillImageSource != nil)
//                {
//                    self.stillImageSource = [[GPUImagePicture alloc] initWithImage:self.rawImage smoothlyScaleOutput:YES];
//                    [self.stillImageSource addTarget:self.currentFilter];
//                }else
//                {
//                    [self.movieFile removeAllTargets];
//                    [self.movieFile addTarget:self.currentFilter];
//                }
//                self.internalSourcePicture1 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"blackboard1024" ofType:@"png"]]];
//                self.internalSourcePicture2 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"overlayMap" ofType:@"png"]]];
//                self.internalSourcePicture3 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"riseMap" ofType:@"png"]]];
//                
//                [self.internalSourcePicture1 addTarget:self.currentFilter];
//                [self.internalSourcePicture2 addTarget:self.currentFilter];
//                [self.internalSourcePicture3 addTarget:self.currentFilter];
//                break;
//            }
                
//            case IF_HUDSON_FILTER: {
//                self.currentFilter = [[IFHudsonFilter alloc] init];
//                if (self.stillImageSource != nil)
//                {
//                    self.stillImageSource = [[GPUImagePicture alloc] initWithImage:self.rawImage smoothlyScaleOutput:YES];
//                    [self.stillImageSource addTarget:self.currentFilter];
//                }else
//                {
//                    [self.movieFile removeAllTargets];
//                    [self.movieFile addTarget:self.currentFilter];
//                }
//                self.internalSourcePicture1 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"hudsonBackground" ofType:@"png"]]];
//                self.internalSourcePicture2 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"overlayMap" ofType:@"png"]]];
//                self.internalSourcePicture3 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"hudsonMap" ofType:@"png"]]];
//                
//                [self.internalSourcePicture1 addTarget:self.currentFilter];
//                [self.internalSourcePicture2 addTarget:self.currentFilter];
//                [self.internalSourcePicture3 addTarget:self.currentFilter];
//                break;
//            }
                
            case IF_XPROII_FILTER: {
                self.currentFilter = [[IFXproIIFilter alloc] init];
                if (self.stillImageSource != nil)
                {
                    self.stillImageSource = [[GPUImagePicture alloc] initWithImage:self.rawImage smoothlyScaleOutput:YES];
                    [self.stillImageSource addTarget:self.currentFilter];
                }else
                {
                    [self.movieFile removeAllTargets];
                    [self.movieFile addTarget:self.currentFilter];
                }
                self.internalSourcePicture1 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"xproMap" ofType:@"png"]]];
                self.internalSourcePicture2 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"vignetteMap" ofType:@"png"]]];
                [self.internalSourcePicture1 addTarget:self.currentFilter];
                [self.internalSourcePicture2 addTarget:self.currentFilter];
                break;
            }
                
//            case IF_SIERRA_FILTER: {
//                self.currentFilter = [[IFSierraFilter alloc] init];
//                if (self.stillImageSource != nil)
//                {
//                    self.stillImageSource = [[GPUImagePicture alloc] initWithImage:self.rawImage smoothlyScaleOutput:YES];
//                    [self.stillImageSource addTarget:self.currentFilter];
//                }else
//                {
//                    [self.movieFile removeAllTargets];
//                    [self.movieFile addTarget:self.currentFilter];
//                }
//                self.internalSourcePicture1 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"sierraVignette" ofType:@"png"]]];
//                self.internalSourcePicture2 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"overlayMap" ofType:@"png"]]];
//                self.internalSourcePicture3 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"sierraMap" ofType:@"png"]]];
//                
//                [self.internalSourcePicture1 addTarget:self.currentFilter];
//                [self.internalSourcePicture2 addTarget:self.currentFilter];
//                [self.internalSourcePicture3 addTarget:self.currentFilter];
//                
//                break;
//            }
                
            case IF_LOMOFI_FILTER: {
                self.currentFilter = [[IFLomofiFilter alloc] init];
                if (self.stillImageSource != nil)
                {
                    self.stillImageSource = [[GPUImagePicture alloc] initWithImage:self.rawImage smoothlyScaleOutput:YES];
                    [self.stillImageSource addTarget:self.currentFilter];
                }else
                {
                    [self.movieFile removeAllTargets];
                    [self.movieFile addTarget:self.currentFilter];
                }
                self.internalSourcePicture1 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"lomoMap" ofType:@"png"]]];
                self.internalSourcePicture2 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"vignetteMap" ofType:@"png"]]];
                
                [self.internalSourcePicture1 addTarget:self.currentFilter];
                [self.internalSourcePicture2 addTarget:self.currentFilter];
                break;
            }
                
//            case IF_EARLYBIRD_FILTER: {
//                self.currentFilter = [[IFEarlybirdFilter alloc] init];
//                if (self.stillImageSource != nil)
//                {
//                    self.stillImageSource = [[GPUImagePicture alloc] initWithImage:self.rawImage smoothlyScaleOutput:YES];
//                    [self.stillImageSource addTarget:self.currentFilter];
//                }else
//                {
//                    [self.movieFile removeAllTargets];
//                    [self.movieFile addTarget:self.currentFilter];
//                }
//                self.internalSourcePicture1 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"earlyBirdCurves" ofType:@"png"]]];
//                self.internalSourcePicture2 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"earlybirdOverlayMap" ofType:@"png"]]];
//                self.internalSourcePicture3 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"vignetteMap" ofType:@"png"]]];
//                self.internalSourcePicture4 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"earlybirdBlowout" ofType:@"png"]]];
//                self.internalSourcePicture5 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"earlybirdMap" ofType:@"png"]]];
//                
//                [self.internalSourcePicture1 addTarget:self.currentFilter];
//                [self.internalSourcePicture2 addTarget:self.currentFilter];
//                [self.internalSourcePicture3 addTarget:self.currentFilter];
//                [self.internalSourcePicture4 addTarget:self.currentFilter];
//                [self.internalSourcePicture5 addTarget:self.currentFilter];
//                break;
//            }
                
//            case IF_SUTRO_FILTER: {
//                self.currentFilter = [[IFSutroFilter alloc] init];
//                if (self.stillImageSource != nil)
//                {
//                    self.stillImageSource = [[GPUImagePicture alloc] initWithImage:self.rawImage smoothlyScaleOutput:YES];
//                    [self.stillImageSource addTarget:self.currentFilter];
//                }else
//                {
//                    [self.movieFile removeAllTargets];
//                    [self.movieFile addTarget:self.currentFilter];
//                }
//                self.internalSourcePicture1 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"vignetteMap" ofType:@"png"]]];
//                self.internalSourcePicture2 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"sutroMetal" ofType:@"png"]]];
//                self.internalSourcePicture3 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"softLight" ofType:@"png"]]];
//                self.internalSourcePicture4 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"sutroEdgeBurn" ofType:@"png"]]];
//                self.internalSourcePicture5 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"sutroCurves" ofType:@"png"]]];
//                
//                [self.internalSourcePicture1 addTarget:self.currentFilter];
//                [self.internalSourcePicture2 addTarget:self.currentFilter];
//                [self.internalSourcePicture3 addTarget:self.currentFilter];
//                [self.internalSourcePicture4 addTarget:self.currentFilter];
//                [self.internalSourcePicture5 addTarget:self.currentFilter];
//                break;
//            }
                
//            case IF_TOASTER_FILTER: {
//                self.currentFilter = [[IFToasterFilter alloc] init];
//                if (self.stillImageSource != nil)
//                {
//                    self.stillImageSource = [[GPUImagePicture alloc] initWithImage:self.rawImage smoothlyScaleOutput:YES];
//                    [self.stillImageSource addTarget:self.currentFilter];
//                }else
//                {
//                    [self.movieFile removeAllTargets];
//                    [self.movieFile addTarget:self.currentFilter];
//                }
//                self.internalSourcePicture1 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"toasterMetal" ofType:@"png"]]];
//                self.internalSourcePicture2 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"toasterSoftLight" ofType:@"png"]]];
//                self.internalSourcePicture3 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"toasterCurves" ofType:@"png"]]];
//                self.internalSourcePicture4 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"toasterOverlayMapWarm" ofType:@"png"]]];
//                self.internalSourcePicture5 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"toasterColorShift" ofType:@"png"]]];
//                
//                [self.internalSourcePicture1 addTarget:self.currentFilter];
//                [self.internalSourcePicture2 addTarget:self.currentFilter];
//                [self.internalSourcePicture3 addTarget:self.currentFilter];
//                [self.internalSourcePicture4 addTarget:self.currentFilter];
//                [self.internalSourcePicture5 addTarget:self.currentFilter];
//                break;
//            }
                
//            case IF_BRANNAN_FILTER: {
//                self.currentFilter = [[IFBrannanFilter alloc] init];
//                if (self.stillImageSource != nil)
//                {
//                    self.stillImageSource = [[GPUImagePicture alloc] initWithImage:self.rawImage smoothlyScaleOutput:YES];
//                    [self.stillImageSource addTarget:self.currentFilter];
//                }else
//                {
//                    [self.movieFile removeAllTargets];
//                    [self.movieFile addTarget:self.currentFilter];
//                }
//                self.internalSourcePicture1 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"brannanProcess" ofType:@"png"]]];
//                self.internalSourcePicture2 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"brannanBlowout" ofType:@"png"]]];
//                self.internalSourcePicture3 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"brannanContrast" ofType:@"png"]]];
//                self.internalSourcePicture4 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"brannanLuma" ofType:@"png"]]];
//                self.internalSourcePicture5 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"brannanScreen" ofType:@"png"]]];
//                
//                [self.internalSourcePicture1 addTarget:self.currentFilter];
//                [self.internalSourcePicture2 addTarget:self.currentFilter];
//                [self.internalSourcePicture3 addTarget:self.currentFilter];
//                [self.internalSourcePicture4 addTarget:self.currentFilter];
//                [self.internalSourcePicture5 addTarget:self.currentFilter];
//                break;
//            }
                
            case IF_INKWELL_FILTER: {
                self.currentFilter = [[IFInkwellFilter alloc] init];
                if (self.stillImageSource != nil)
                {
                    self.stillImageSource = [[GPUImagePicture alloc] initWithImage:self.rawImage smoothlyScaleOutput:YES];
                    [self.stillImageSource addTarget:self.currentFilter];
                }else
                {
                    [self.movieFile removeAllTargets];
                    [self.movieFile addTarget:self.currentFilter];
                }
                
                
                self.internalSourcePicture1 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"inkwellMap" ofType:@"png"]]];
                [self.internalSourcePicture1 addTarget:self.currentFilter];
                break;
            }
                
            case IF_WALDEN_FILTER: {
                self.currentFilter = [[IFWaldenFilter alloc] init];
                if (self.stillImageSource != nil)
                {
                    self.stillImageSource = [[GPUImagePicture alloc] initWithImage:self.rawImage smoothlyScaleOutput:YES];
                    [self.stillImageSource addTarget:self.currentFilter];
                }else
                {
                    [self.movieFile removeAllTargets];
                    [self.movieFile addTarget:self.currentFilter];
                }
                self.internalSourcePicture1 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"waldenMap" ofType:@"png"]]];
                self.internalSourcePicture2 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"vignetteMap" ofType:@"png"]]];
                
                [self.internalSourcePicture1 addTarget:self.currentFilter];
                [self.internalSourcePicture2 addTarget:self.currentFilter];
                break;
            }
                
//            case IF_HEFE_FILTER: {
//                self.currentFilter = [[IFHefeFilter alloc] init];
//                if (self.stillImageSource != nil)
//                {
//                    self.stillImageSource = [[GPUImagePicture alloc] initWithImage:self.rawImage smoothlyScaleOutput:YES];
//                    [self.stillImageSource addTarget:self.currentFilter];
//                }else
//                {
//                    [self.movieFile removeAllTargets];
//                    [self.movieFile addTarget:self.currentFilter];
//                }
//                self.internalSourcePicture1 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"edgeBurn" ofType:@"png"]]];
//                self.internalSourcePicture2 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"hefeMap" ofType:@"png"]]];
//                self.internalSourcePicture3 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"hefeGradientMap" ofType:@"png"]]];
//                self.internalSourcePicture4 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"hefeSoftLight" ofType:@"png"]]];
//                self.internalSourcePicture5 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"hefeMetal" ofType:@"png"]]];
//                
//                [self.internalSourcePicture1 addTarget:self.currentFilter];
//                [self.internalSourcePicture2 addTarget:self.currentFilter];
//                [self.internalSourcePicture3 addTarget:self.currentFilter];
//                [self.internalSourcePicture4 addTarget:self.currentFilter];
//                [self.internalSourcePicture5 addTarget:self.currentFilter];
//                break;
//            }
                
            case IF_VALENCIA_FILTER: {
                self.currentFilter = [[IFValenciaFilter alloc] init];
                if (self.stillImageSource != nil)
                {
                    self.stillImageSource = [[GPUImagePicture alloc] initWithImage:self.rawImage smoothlyScaleOutput:YES];
                    [self.stillImageSource addTarget:self.currentFilter];
                }else
                {
                    [self.movieFile removeAllTargets];
                    [self.movieFile addTarget:self.currentFilter];
                }
                self.internalSourcePicture1 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"valenciaMap" ofType:@"png"]]];
                self.internalSourcePicture2 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"valenciaGradientMap" ofType:@"png"]]];
                
                [self.internalSourcePicture1 addTarget:self.currentFilter];
                [self.internalSourcePicture2 addTarget:self.currentFilter];
                break;
            }
                
            case IF_NASHVILLE_FILTER: {
                self.currentFilter = [[IFNashvilleFilter alloc] init];
                if (self.stillImageSource != nil)
                {
                    self.stillImageSource = [[GPUImagePicture alloc] initWithImage:self.rawImage smoothlyScaleOutput:YES];
                    [self.stillImageSource addTarget:self.currentFilter];
                }else
                {
                    [self.movieFile removeAllTargets];
                    [self.movieFile addTarget:self.currentFilter];
                }
                self.internalSourcePicture1 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"nashvilleMap" ofType:@"png"]]];
                
                [self.internalSourcePicture1 addTarget:self.currentFilter];
                break;
            }
                
            case IF_1977_FILTER: {
                self.currentFilter = [[IF1977Filter alloc] init];
                if (self.stillImageSource != nil)
                {
                    self.stillImageSource = [[GPUImagePicture alloc] initWithImage:self.rawImage smoothlyScaleOutput:YES];
                    [self.stillImageSource addTarget:self.currentFilter];
                }else
                {
                    [self.movieFile removeAllTargets];
                    [self.movieFile addTarget:self.currentFilter];
                }
                self.internalSourcePicture1 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"1977map" ofType:@"png"]]];
                self.internalSourcePicture2 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"1977blowout" ofType:@"png"]]];
                
                [self.internalSourcePicture1 addTarget:self.currentFilter];
                [self.internalSourcePicture2 addTarget:self.currentFilter];
                break;
            }
                
            case IF_LORDKELVIN_FILTER: {
                self.currentFilter = [[IFLordKelvinFilter alloc] init];
                if (self.stillImageSource != nil)
                {
                    self.stillImageSource = [[GPUImagePicture alloc] initWithImage:self.rawImage smoothlyScaleOutput:YES];
                    [self.stillImageSource addTarget:self.currentFilter];
                }else
                {
                    [self.movieFile removeAllTargets];
                    [self.movieFile addTarget:self.currentFilter];
                }
                self.internalSourcePicture1 = [[GPUImagePicture alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"kelvinMap" ofType:@"png"]]];
                
                [self.internalSourcePicture1 addTarget:self.currentFilter];
                break;
            }
                
            default:
                break;
        }
        
        [self performSelectorOnMainThread:@selector(switchToNewFilter) withObject:nil waitUntilDone:NO];
        
    });
}

- (void) switchToNewFilter
{
    switch (self.currentType) {
//        case IF_AMARO_FILTER: {
//            self.sourcePicture1 = self.internalSourcePicture1;
//            self.sourcePicture2 = self.internalSourcePicture2;
//            self.sourcePicture3 = self.internalSourcePicture3;
//            [self.sourcePicture1 processImage];
//            [self.sourcePicture2 processImage];
//            [self.sourcePicture3 processImage];
//            break;
//        }
//            
//        case IF_RISE_FILTER: {
//            self.sourcePicture1 = self.internalSourcePicture1;
//            self.sourcePicture2 = self.internalSourcePicture2;
//            self.sourcePicture3 = self.internalSourcePicture3;
// 
//            [self.sourcePicture1 processImage];
//            [self.sourcePicture2 processImage];
//            [self.sourcePicture3 processImage];
//            
//            break;
//        }
//            
//        case IF_HUDSON_FILTER: {
//            self.sourcePicture1 = self.internalSourcePicture1;
//            self.sourcePicture2 = self.internalSourcePicture2;
//            self.sourcePicture3 = self.internalSourcePicture3;
//
//            [self.sourcePicture1 processImage];
//            [self.sourcePicture2 processImage];
//            [self.sourcePicture3 processImage];
//            break;
//        }
            
        case IF_XPROII_FILTER: {
            self.sourcePicture1 = self.internalSourcePicture1;
            self.sourcePicture2 = self.internalSourcePicture2;

            [self.sourcePicture1 processImage];
            [self.sourcePicture2 processImage];
            break;
        }
            
//        case IF_SIERRA_FILTER: {
//            self.sourcePicture1 = self.internalSourcePicture1;
//            self.sourcePicture2 = self.internalSourcePicture2;
//            self.sourcePicture3 = self.internalSourcePicture3;
//
//            [self.sourcePicture1 processImage];
//            [self.sourcePicture2 processImage];
//            [self.sourcePicture3 processImage];
//            break;
//        }
            
        case IF_LOMOFI_FILTER: {
            self.sourcePicture1 = self.internalSourcePicture1;
            self.sourcePicture2 = self.internalSourcePicture2;
            
            [self.sourcePicture1 processImage];
            [self.sourcePicture2 processImage];
            break;
        }
            
//        case IF_EARLYBIRD_FILTER: {
//            self.sourcePicture1 = self.internalSourcePicture1;
//            self.sourcePicture2 = self.internalSourcePicture2;
//            self.sourcePicture3 = self.internalSourcePicture3;
//            self.sourcePicture4 = self.internalSourcePicture4;
//            self.sourcePicture5 = self.internalSourcePicture5;
//
//            [self.sourcePicture1 processImage];
//            [self.sourcePicture2 processImage];
//            [self.sourcePicture3 processImage];
//            [self.sourcePicture4 processImage];
//            [self.sourcePicture5 processImage];
//            break;
//        }
//            
//        case IF_SUTRO_FILTER: {
//            self.sourcePicture1 = self.internalSourcePicture1;
//            self.sourcePicture2 = self.internalSourcePicture2;
//            self.sourcePicture3 = self.internalSourcePicture3;
//            self.sourcePicture4 = self.internalSourcePicture4;
//            self.sourcePicture5 = self.internalSourcePicture5;
//            
//            [self.sourcePicture1 processImage];
//            [self.sourcePicture2 processImage];
//            [self.sourcePicture3 processImage];
//            [self.sourcePicture4 processImage];
//            [self.sourcePicture5 processImage];
//            break;
//        }
//            
//        case IF_TOASTER_FILTER: {
//            self.sourcePicture1 = self.internalSourcePicture1;
//            self.sourcePicture2 = self.internalSourcePicture2;
//            self.sourcePicture3 = self.internalSourcePicture3;
//            self.sourcePicture4 = self.internalSourcePicture4;
//            self.sourcePicture5 = self.internalSourcePicture5;
//
//            [self.sourcePicture1 processImage];
//            [self.sourcePicture2 processImage];
//            [self.sourcePicture3 processImage];
//            [self.sourcePicture4 processImage];
//            [self.sourcePicture5 processImage];
//            break;
//        }
//            
//        case IF_BRANNAN_FILTER: {
//            self.sourcePicture1 = self.internalSourcePicture1;
//            self.sourcePicture2 = self.internalSourcePicture2;
//            self.sourcePicture3 = self.internalSourcePicture3;
//            self.sourcePicture4 = self.internalSourcePicture4;
//            self.sourcePicture5 = self.internalSourcePicture5;
//
//            [self.sourcePicture1 processImage];
//            [self.sourcePicture2 processImage];
//            [self.sourcePicture3 processImage];
//            [self.sourcePicture4 processImage];
//            [self.sourcePicture5 processImage];
//            break;
//        }
            
        case IF_INKWELL_FILTER: {
            
            self.sourcePicture1 = self.internalSourcePicture1;
            
            [self.sourcePicture1 processImage];
            break;
        }
            
        case IF_WALDEN_FILTER: {
            self.sourcePicture1 = self.internalSourcePicture1;
            self.sourcePicture2 = self.internalSourcePicture2;
            
            [self.sourcePicture1 processImage];
            [self.sourcePicture2 processImage];
            break;
        }
            
//        case IF_HEFE_FILTER: {
//            self.sourcePicture1 = self.internalSourcePicture1;
//            self.sourcePicture2 = self.internalSourcePicture2;
//            self.sourcePicture3 = self.internalSourcePicture3;
//            self.sourcePicture4 = self.internalSourcePicture4;
//            self.sourcePicture5 = self.internalSourcePicture5;
//            
//            [self.sourcePicture1 processImage];
//            [self.sourcePicture2 processImage];
//            [self.sourcePicture3 processImage];
//            [self.sourcePicture4 processImage];
//            [self.sourcePicture5 processImage];
//            break;
//        }
            
        case IF_VALENCIA_FILTER: {
            self.sourcePicture1 = self.internalSourcePicture1;
            self.sourcePicture2 = self.internalSourcePicture2;

            [self.sourcePicture1 processImage];
            [self.sourcePicture2 processImage];
            break;
        }
            
        case IF_NASHVILLE_FILTER: {
            self.sourcePicture1 = self.internalSourcePicture1;

            [self.sourcePicture1 processImage];
            break;
        }
            
        case IF_1977_FILTER: {
            self.sourcePicture1 = self.internalSourcePicture1;
            self.sourcePicture2 = self.internalSourcePicture2;

            [self.sourcePicture1 processImage];
            [self.sourcePicture2 processImage];
            break;
        }
            
        case IF_LORDKELVIN_FILTER: {
            self.sourcePicture1 = self.internalSourcePicture1;

            [self.sourcePicture1 processImage];
            break;
        }
            
        case IF_NORMAL_FILTER: {
            break;
        }
            
        default: {
            break;
        }
    }
    
    self.gpuCameraView_HD.hidden = NO;
    [self.currentFilter addTarget:self.gpuCameraView_HD];
    [self.stillImageSource processImage];
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    
    [self dismissViewControllerAnimated:YES completion:^(){
        if (self.photoButton.selected && self.recordPhotoButton.tag == 0)
            [self.photoCamera startCameraCapture];
        else if (self.videoButton.selected && self.recordVideoButton.tag == 0)
            [self.videoCamera startCameraCapture];
    }];
}

#pragma mark - Filters TableView Delegate & Datasource methods
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 120.0f;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    self.currentType = (IFFilterType)[indexPath row];
    
//    [self.videoCamera switchFilter:(IFFilterType)[indexPath row]];
    [self forceSwitchToNewFilter:self.currentType];
    CGRect cellRect = [tableView rectForRowAtIndexPath:indexPath];
    CGRect tempRect = self.filterBottomLine.frame;
    tempRect.origin.y = cellRect.origin.y;
    
    [UIView animateWithDuration:0.3f animations:^() {
        self.filterBottomLine.frame = tempRect;
    }completion:^(BOOL finished){
        // do nothing
    }];
    
    if (([indexPath row] != [[[tableView indexPathsForVisibleRows] objectAtIndex:0] row]) && ([indexPath row] != [[[tableView indexPathsForVisibleRows] lastObject] row])) {
        
        return;
    }
    
    if ([indexPath row] == [[[tableView indexPathsForVisibleRows] objectAtIndex:0] row]) {
        [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    } else {
        [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *filtersTableViewCellIdentifier = @"filtersTableViewCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: filtersTableViewCellIdentifier];
    UIImageView *filterImageView;
    UIView *filterImageViewContainerView;
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:filtersTableViewCellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor colorWithRed:0.f green:(float)0x7A/0xff blue:1 alpha:1.0];
        filterImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, -15, 90, 120)];
        filterImageView.transform = CGAffineTransformMakeRotation(M_PI/2);
        filterImageView.tag = kFilterImageViewTag;
        
        filterImageViewContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 15, 90, 120)];
        filterImageViewContainerView.tag = kFilterImageViewContainerViewTag;
        [filterImageViewContainerView addSubview:filterImageView];
        
        [cell.contentView addSubview:filterImageViewContainerView];
        
//        bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 2, 120)];
//        bottomLine.backgroundColor = [UIColor whiteColor];
//        [cell.contentView addSubview:bottomLine];
    } else {
        filterImageView = (UIImageView *)[cell.contentView viewWithTag:kFilterImageViewTag];
    }
    
    self.currentType = (IFFilterType)[indexPath row];
    
    switch (self.currentType) {
        case IF_NORMAL_FILTER: {
            filterImageView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"DSFilterTileNormal" ofType:@"png"]];
            
            break;
        }
//        case IF_AMARO_FILTER: {
//            filterImageView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"DSFilterTileAmaro" ofType:@"png"]];
//            
//            break;
//        }
//        case IF_RISE_FILTER: {
//            filterImageView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"DSFilterTileRise" ofType:@"png"]];
//            
//            break;
//        }
//        case IF_HUDSON_FILTER: {
//            filterImageView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"DSFilterTileHudson" ofType:@"png"]];
//            
//            break;
//        }
        case IF_XPROII_FILTER: {
            filterImageView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"DSFilterTileXpro2" ofType:@"png"]];
            
            break;
        }
//        case IF_SIERRA_FILTER: {
//            filterImageView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"DSFilterTileSierra" ofType:@"png"]];
//            
//            break;
//        }
        case IF_LOMOFI_FILTER: {
            filterImageView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"DSFilterTileLomoFi" ofType:@"png"]];
            
            break;
        }
//        case IF_EARLYBIRD_FILTER: {
//            filterImageView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"DSFilterTileEarlybird" ofType:@"png"]];
//            
//            break;
//        }
//        case IF_SUTRO_FILTER: {
//            filterImageView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"DSFilterTileSutro" ofType:@"png"]];
//            
//            break;
//        }
//        case IF_TOASTER_FILTER: {
//            filterImageView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"DSFilterTileToaster" ofType:@"png"]];
//            
//            break;
//        }
//        case IF_BRANNAN_FILTER: {
//            filterImageView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"DSFilterTileBrannan" ofType:@"png"]];
//            
//            break;
//        }
        case IF_INKWELL_FILTER: {
            filterImageView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"DSFilterTileInkwell" ofType:@"png"]];
            
            break;
        }
        case IF_WALDEN_FILTER: {
            filterImageView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"DSFilterTileWalden" ofType:@"png"]];
            
            break;
        }
//        case IF_HEFE_FILTER: {
//            filterImageView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"DSFilterTileHefe" ofType:@"png"]];
//            
//            break;
//        }
        case IF_VALENCIA_FILTER: {
            filterImageView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"DSFilterTileValencia" ofType:@"png"]];
            
            break;
        }
        case IF_NASHVILLE_FILTER: {
            filterImageView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"DSFilterTileNashville" ofType:@"png"]];
            
            break;
        }
        case IF_1977_FILTER: {
            filterImageView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"DSFilterTile1977" ofType:@"png"]];
            
            break;
        }
        case IF_LORDKELVIN_FILTER: {
            filterImageView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"DSFilterTileLordKelvin" ofType:@"png"]];
            break;
        }
            
        default: {
            filterImageView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"DSFilterTileNormal" ofType:@"png"]];
            
            break;
        }
    }
    
    
    return cell;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return IF_FILTER_TOTAL_NUMBER;
//    return 18;
}

#pragma mark - Bottom Buttons Process
- (IBAction)bottomButtonClicked:(UIButton*)sender {
    [self buttonProcess:sender];
    if(sender.tag == 1) //text button clicked
    {
        [self.mainScrollView scrollRectToVisible:CGRectMake(0, 0, self.mainScrollView.frame.size.width, self.mainScrollView.frame.size.height) animated:YES];
        [self.cameraScrollView scrollRectToVisible:CGRectMake(0, 0, self.cameraScrollView.frame.size.width, self.cameraScrollView.frame.size.height) animated:NO];
    }else if (sender.tag == 2) //photo button clicked
    {
        [self.mainScrollView scrollRectToVisible:CGRectMake(self.mainScrollView.frame.size.width, 0, self.mainScrollView.frame.size.width, self.mainScrollView.frame.size.height) animated:YES];
        [self.cameraScrollView scrollRectToVisible:CGRectMake(0, 0, self.cameraScrollView.frame.size.width, self.cameraScrollView.frame.size.height) animated:YES];
    }else //video button clicked
    {
        [self.mainScrollView scrollRectToVisible:CGRectMake(self.mainScrollView.frame.size.width, 0, self.mainScrollView.frame.size.width, self.mainScrollView.frame.size.height) animated:YES];
        [self.cameraScrollView scrollRectToVisible:CGRectMake(self.cameraScrollView.frame.size.width, 0, self.cameraScrollView.frame.size.width, self.cameraScrollView.frame.size.height) animated:YES];
    }
}

- (void) buttonProcess:(UIButton*)sender
{
    sender.selected = YES;
    if(sender.tag == 1) //text button clicked
    {
        self.photoButton.selected = NO;
        self.photoBottomLine.hidden = YES;
        self.videoButton.selected = NO;
        self.videoBottomLine.hidden = YES;
        self.textBottomLine.hidden = NO;
        self.postButton.enabled = (self.postTextView.text.length != 0);
        self.navigationItem.rightBarButtonItem = self.postButton;
        self.navigationItem.titleView = nil;
        self.switchCameraButton.hidden = YES;
    }else if (sender.tag == 2) //photo button clicked
    {
        self.textButton.selected = NO;
        self.textBottomLine.hidden = YES;
        self.videoButton.selected = NO;
        self.videoBottomLine.hidden = YES;
        self.photoBottomLine.hidden = NO;
        self.navigationItem.rightBarButtonItem = self.nextButton;
        self.navigationItem.titleView = self.cameraRollButton;
        if (self.recordPhotoButton.tag == 0)
        {
            [self.videoCamera stopCameraCapture];
            [self.videoCamera removeAllTargets];
            
            self.currentFilter = [[GPUImageFilter alloc] init];
            [self.photoCamera addTarget:self.currentFilter];
            [self.currentFilter addTarget:self.gpuCameraView];
            
            [self.photoCamera startCameraCapture];
        }
//        self.switchCameraButton.hidden = NO;
        self.switchCameraButton.hidden = YES;
    }else //video button clicked
    {
        self.textButton.selected = NO;
        self.textBottomLine.hidden = YES;
        self.photoButton.selected = NO;
        self.photoBottomLine.hidden = YES;
        self.videoBottomLine.hidden = NO;
        self.navigationItem.rightBarButtonItem = self.nextButton;
        self.navigationItem.titleView = self.cameraRollButton;
        if (self.recordVideoButton.tag == 0)
        {
            [self.photoCamera stopCameraCapture];
            [self.photoCamera removeAllTargets];
            
            self.currentFilter = [[GPUImageFilter alloc] init];
            [self.videoCamera addTarget:self.currentFilter];
            [self.currentFilter addTarget:self.gpuCameraView];
            
            [self.videoCamera startCameraCapture];
        }
//        self.switchCameraButton.hidden = NO;
        self.switchCameraButton.hidden = YES;
    }
}
@end
