//
//  RecordAdViewController.m
//  TheDime
//
//  Created by Kevin McNeish on 6/20/14.
//  Copyright (c) 2014 Anonoymous - ICN. All rights reserved.
//

#import "RecordAdViewController.h"
#import "mmUIViewController.h"
#import "PBJStrobeView.h"
#import "PBJFocusView.h"
#import "PBJVision.h"
#import "PBJVisionUtilities.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <GLKit/GLKit.h>
#import "UIView+Toast.h"

@interface ExtendedHitButton : UIButton

+ (instancetype)extendedHitButton;

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event;

@end

@implementation ExtendedHitButton

+ (instancetype)extendedHitButton{
    return (ExtendedHitButton *)[ExtendedHitButton buttonWithType:UIButtonTypeCustom];
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event{
    CGRect relativeFrame = self.bounds;
    UIEdgeInsets hitTestEdgeInsets = UIEdgeInsetsMake(-35, -35, -35, -35);
    CGRect hitFrame = UIEdgeInsetsInsetRect(relativeFrame, hitTestEdgeInsets);
    return CGRectContainsPoint(hitFrame, point);
}

@end

@interface RecordAdViewController () <
UIGestureRecognizerDelegate,
PBJVisionDelegate,
UIAlertViewDelegate>{
    __weak IBOutlet UILabel *lblTime;
    __weak IBOutlet UIProgressView *progressView;
    
    GLKViewController *effectsViewController;
    PBJStrobeView *strobeView;
    PBJFocusView *focusView;
    UIView *previewView;
    UIView *captureDock;
    AVCaptureVideoPreviewLayer *previewLayer;

    UIButton *doneButton;
    UIButton *flipButton;
    UIButton *recordButton;
    UIButton *nextButton;
    
    UILongPressGestureRecognizer *longPressGestureRecognizer;
    UITapGestureRecognizer *tapGestureRecognizer;
    ALAssetsLibrary *assetLibrary;

    CFTimeInterval startTime;
    int elapsedSeconds;
    BOOL recording;
    BOOL nextButtonTapped;
    BOOL startedRecording;
    __block NSDictionary *currentVideo;
}
@end

@implementation RecordAdViewController

#pragma mark - UIViewController

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark - init

- (void)dealloc
{
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    longPressGestureRecognizer.delegate = nil;
}

#pragma mark - view lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    self.view.backgroundColor = [UIColor colorWithRed:0/255.0 green:208/255.0 blue:255/255.0 alpha:1.0];//[UIColor blackColor];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    assetLibrary = [[ALAssetsLibrary alloc] init];
    
    // preview and AV layer
    previewView = [[UIView alloc] initWithFrame:CGRectZero];
    previewView.backgroundColor = [UIColor blackColor];
    CGRect previewFrame = CGRectMake(0, 60.0f, CGRectGetWidth(self.view.frame), CGRectGetWidth(self.view.frame));
    previewView.frame = previewFrame;
    previewLayer = [[PBJVision sharedInstance] previewLayer];
    previewLayer.frame = previewView.bounds;
    previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [previewView.layer addSublayer:previewLayer];

    effectsViewController = [[GLKViewController alloc] init];
    effectsViewController.preferredFramesPerSecond = 35; //**update from 60 to 35 for testing**
    
    GLKView *view = (GLKView *)effectsViewController.view;
    CGRect viewFrame = previewView.bounds;
    view.frame = viewFrame;
    view.context = [[PBJVision sharedInstance] context];
    view.contentScaleFactor = [[UIScreen mainScreen] scale];
    view.alpha = 0.5f;
    view.hidden = YES;
    [[PBJVision sharedInstance] setPresentationFrame:previewView.frame];
    [previewView addSubview:effectsViewController.view];
    
    // focus view
    focusView = [[PBJFocusView alloc] initWithFrame:CGRectZero];
    
    // touch button to record
    longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGestureRecognizer:)];
    longPressGestureRecognizer.delegate = self;
    longPressGestureRecognizer.minimumPressDuration = 0.05f;
    longPressGestureRecognizer.allowableMovement = 10.0f;
    
    // tap to focus
    tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleFocusTapGesterRecognizer:)];
    tapGestureRecognizer.delegate = self;
    tapGestureRecognizer.numberOfTapsRequired = 1;
    tapGestureRecognizer.enabled = YES;
    [previewView addGestureRecognizer:tapGestureRecognizer];
    
    // bottom dock
    captureDock = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.bounds) - 150.0f, CGRectGetWidth(self.view.bounds), 100.0f)];
    captureDock.backgroundColor = [UIColor clearColor];
    captureDock.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview:captureDock];
    
    // Record Button
    float buttonWidth = 70.0;
    recordButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *recordImage = [UIImage imageNamed:@"13-BUTTON-Record.png"];
    [recordButton setImage:recordImage forState:UIControlStateNormal];
    recordButton.frame = CGRectMake(135.0, 180.0, buttonWidth, buttonWidth);//width and height should be same value
    recordButton.clipsToBounds = YES;
    recordButton.layer.cornerRadius = buttonWidth / 2;//half of the width
    recordButton.layer.borderColor=[UIColor whiteColor].CGColor;
    recordButton.layer.borderWidth=2.0f;
    CGRect buttonFrame = recordButton.frame;
    buttonFrame.origin = CGPointMake((CGRectGetWidth(self.view.bounds) * 0.5f) - (buttonWidth * 0.5f), (captureDock.frame.size.height - buttonWidth) / 2);
    recordButton.frame = buttonFrame;
    [recordButton addGestureRecognizer:longPressGestureRecognizer];
    [captureDock addSubview:recordButton];
    
    // Flip button
    flipButton = [ExtendedHitButton extendedHitButton];
    UIImage *flipImage = [UIImage imageNamed:@"capture_flip"];
    [flipButton setImage:flipImage forState:UIControlStateNormal];
    CGRect flipFrame = flipButton.frame;
    flipFrame.origin = CGPointMake(20.0f, (captureDock.frame.size.height -
                                           flipImage.size.height) / 2);
    flipFrame.size = flipImage.size;
    flipButton.frame = flipFrame;
    [flipButton addTarget:self action:@selector(handleFlipButton:) forControlEvents:UIControlEventTouchUpInside];
    [captureDock addSubview:flipButton];
    
    // Next button
    nextButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [nextButton setTitle:@"Save" forState:UIControlStateNormal];
    [nextButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    nextButton.titleLabel.font = [UIFont systemFontOfSize:20];
    [nextButton sizeToFit];
    CGRect nextFrame = nextButton.frame;
    nextFrame.origin = CGPointMake(captureDock.frame.size.width - 20.0f - nextButton.frame.size.width, (captureDock.frame.size.height - nextButton.frame.size.height) / 2);
    nextButton.frame = nextFrame;
    [nextButton addTarget:self action:@selector(handleNextButton:) forControlEvents:UIControlEventTouchUpInside];
    [self setNextButtonEnabled:NO];
    [captureDock addSubview:nextButton];
    
    // Change the height of the progress bar
    [progressView setTransform:CGAffineTransformMakeScale(1.0, 14.0)];
    
    // Set the maximum recorded video length
    [PBJVision sharedInstance].maximumCaptureDuration = CMTimeMake(6, 1);
    
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self resetCapture];
    [[PBJVision sharedInstance] startPreview];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];    
    [[PBJVision sharedInstance] stopPreview];
}

//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
//{
//    if ([segue.identifier isEqualToString:@"RecordToReview"]) {
//        ReviewVideoViewController *rvc = segue.destinationViewController;
//        rvc.videoPath = self.videoPath;
//        rvc.delegate = self;
//    }
//}

- (void)retakeVideo
{
    // Delete the temporary video file and clear the reference to it
    [[NSFileManager defaultManager] removeItemAtPath:self.videoPath error:NULL];
    self.videoPath = nil;
}

- (IBAction)close:(id)sender {
    
    if (recording) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Discard Video"
                                                        message: @"If you close the camera your video will be discarded. Are you sure?"
                                                       delegate:self
                                              cancelButtonTitle:@"No"
                                              otherButtonTitles:@"Yes", nil];
        [alert show];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        // User has chosen to discard the video
        [self cancelRecording];
    }
}

- (void)cancelRecording
{
    [[PBJVision sharedInstance] cancelVideoCapture];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - private start/stop helper methods

- (void)startCapture
{
    startedRecording = YES;
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    [UIView animateWithDuration:0.2f delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{

    } completion:^(BOOL finished) {
    }];
    [[PBJVision sharedInstance] startVideoCapture];
}

- (void)pauseCapture
{
    [UIView animateWithDuration:0.2f delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{

    } completion:^(BOOL finished) {
    }];
    
    [[PBJVision sharedInstance] pauseVideoCapture];
}

- (void)resumeCapture
{
    [UIView animateWithDuration:0.2f delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{

    } completion:^(BOOL finished) {
    }];
    
    [[PBJVision sharedInstance] resumeVideoCapture];
    effectsViewController.view.hidden = YES;
}

- (void)endCapture
{
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    [[PBJVision sharedInstance] endVideoCapture];
    effectsViewController.view.hidden = YES;
}

- (void)resetCapture
{
    [strobeView stop];
    longPressGestureRecognizer.enabled = YES;
    
    PBJVision *vision = [PBJVision sharedInstance];
    vision.delegate = self;
    
    if ([vision isCameraDeviceAvailable:PBJCameraDeviceBack]) {
        [vision setCameraDevice:PBJCameraDeviceBack];
        flipButton.hidden = NO;
    } else {
        [vision setCameraDevice:PBJCameraDeviceFront];
        flipButton.hidden = YES;
    }
    
    //[vision setCaptureSessionPreset:AVCaptureSessionPreset640x480];
    [vision setCameraMode:PBJCameraModeVideo];
    [vision setCameraOrientation:PBJCameraOrientationPortrait];
    [vision setFocusMode:PBJFocusModeContinuousAutoFocus];
    [vision setOutputFormat:PBJOutputFormatSquare];
    [vision setVideoRenderingEnabled:YES];
    
    // KJM
    recordButton.enabled = YES;
    nextButtonTapped = NO;
    [self setNextButtonEnabled:NO];
    [self resetElapsedTime];
}

- (void)resetElapsedTime
{
    elapsedSeconds = 0;
    lblTime.text = @"00:00";
    progressView.progress = 0;
}

- (void)setNextButtonEnabled:(BOOL)enabled
{
    if (enabled) {
        nextButton.enabled = YES;
        nextButton.alpha = 1;
    }
    else
    {
        nextButton.enabled = NO;
        nextButton.alpha = .5;
    }
}

#pragma mark - UIButton

- (void)handleFlipButton:(UIButton *)button
{
    PBJVision *vision = [PBJVision sharedInstance];
    if (vision.cameraDevice == PBJCameraDeviceBack) {
        [vision setCameraDevice:PBJCameraDeviceFront];
    } else {
        [vision setCameraDevice:PBJCameraDeviceBack];
    }
}

- (void)handleNextButton:(UIButton *)button
{
    nextButtonTapped = YES;
    // resets long press
    longPressGestureRecognizer.enabled = NO;
    longPressGestureRecognizer.enabled = YES;
    if (self.videoPath)
    {
        [self.delegate setVideoPath:self.videoPath];
        // Video already saved go to the review scene
        [self.navigationController popViewControllerAnimated:YES];
//        [self performSegueWithIdentifier:@"RecordToReview" sender:self];
    }
    else
    {
        // Video not saved yet
        [self endCapture];
    }
}

#pragma mark - UIGestureRecognizer

- (void)handleLongPressGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
{
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:
        {
            if (!recording)
                [self startCapture];
            else
                [self resumeCapture];
            break;
        }
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
        {
            [self pauseCapture];
            break;
        }
        default:
            break;
    }
}

- (void)handleFocusTapGesterRecognizer:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint tapPoint = [gestureRecognizer locationInView:previewView];
    
    // auto focus is occuring, display focus view
    CGPoint point = tapPoint;
    
    CGRect focusFrame = focusView.frame;
#if defined(__LP64__) && __LP64__
    focusFrame.origin.x = rint(point.x - (focusFrame.size.width * 0.5));
    focusFrame.origin.y = rint(point.y - (focusFrame.size.height * 0.5));
#else
    focusFrame.origin.x = rintf(point.x - (focusFrame.size.width * 0.5f));
    focusFrame.origin.y = rintf(point.y - (focusFrame.size.height * 0.5f));
#endif
    [focusView setFrame:focusFrame];
    
    [previewView addSubview:focusView];
    [focusView startAnimation];
    
    CGPoint adjustPoint = [PBJVisionUtilities convertToPointOfInterestFromViewCoordinates:tapPoint inFrame:previewView.frame];
    [[PBJVision sharedInstance] focusExposeAndAdjustWhiteBalanceAtAdjustedPoint:adjustPoint];
}

#pragma mark - PBJVisionDelegate

// session

- (void)visionSessionWillStart:(PBJVision *)vision
{
}

- (void)visionSessionDidStart:(PBJVision *)vision
{
    if (![previewView superview]) {
        [self.view addSubview:previewView];
    }
}

- (void)visionSessionDidStop:(PBJVision *)vision
{
    [previewView removeFromSuperview];
}

// preview

- (void)visionSessionDidStartPreview:(PBJVision *)vision
{
    NSLog(@"Camera preview did start");
    
}

- (void)visionSessionDidStopPreview:(PBJVision *)vision
{
    NSLog(@"Camera preview did stop");
}

// device

- (void)visionCameraDeviceWillChange:(PBJVision *)vision
{
    NSLog(@"Camera device will change");
}

- (void)visionCameraDeviceDidChange:(PBJVision *)vision
{
    NSLog(@"Camera device did change");
}

// mode

- (void)visionCameraModeWillChange:(PBJVision *)vision
{
    NSLog(@"Camera mode will change");
}

- (void)visionCameraModeDidChange:(PBJVision *)vision
{
    NSLog(@"Camera mode did change");
}

// format

- (void)visionOutputFormatWillChange:(PBJVision *)vision
{
    NSLog(@"Output format will change");
}

- (void)visionOutputFormatDidChange:(PBJVision *)vision
{
    NSLog(@"Output format did change");
}

- (void)vision:(PBJVision *)vision didChangeCleanAperture:(CGRect)cleanAperture
{
}

// focus / exposure

- (void)visionWillStartFocus:(PBJVision *)vision
{
}

- (void)visionDidStopFocus:(PBJVision *)vision
{
    if (focusView && [focusView superview]) {
        [focusView stopAnimation];
    }
}

- (void)visionWillChangeExposure:(PBJVision *)vision
{
}

- (void)visionDidChangeExposure:(PBJVision *)vision
{
    if (focusView && [focusView superview]) {
        [focusView stopAnimation];
    }
}

// flash

- (void)visionDidChangeFlashMode:(PBJVision *)vision
{
    NSLog(@"Flash mode did change");
}

// photo

- (void)visionWillCapturePhoto:(PBJVision *)vision
{
}

- (void)visionDidCapturePhoto:(PBJVision *)vision
{
}

- (void)vision:(PBJVision *)vision capturedPhoto:(NSDictionary *)photoDict error:(NSError *)error
{
}

// video capture

- (void)visionDidStartVideoCapture:(PBJVision *)vision
{
    [strobeView start];
    recording = YES;
    // KJM
    [self setNextButtonEnabled:YES];
}

- (void)visionDidPauseVideoCapture:(PBJVision *)vision
{
    [strobeView stop];
}

- (void)visionDidResumeVideoCapture:(PBJVision *)vision
{
    [strobeView start];
}

- (void)vision:(PBJVision *)vision capturedVideo:(NSDictionary *)videoDict error:(NSError *)error
{
    recording = NO;
    
    if (error && [error.domain isEqual:PBJVisionErrorDomain] && error.code == PBJVisionErrorCancelled) {
        NSLog(@"recording session cancelled");
        return;
    } else if (error) {
        NSLog(@"encounted an error in video capture (%@)", error);
        return;
    }
    
    currentVideo = videoDict;
    
    self.videoPath = [currentVideo  objectForKey:PBJVisionVideoPathKey];
    [self.delegate setVideoPath:self.videoPath];

    if (nextButtonTapped) {
        [self.navigationController popViewControllerAnimated:YES];
//        [self performSegueWithIdentifier:@"RecordToReview" sender:self];
    }
    else
    {
//        [previewView makeToast:@"Tap Next to continue" duration:2 position:@"bottom"];
        recordButton.enabled = NO;
    }
}

// progress

- (void)visionDidCaptureAudioSample:(PBJVision *)vision
{
    //    NSLog(@"captured audio (%f) seconds", vision.capturedAudioSeconds);
}

- (void)visionDidCaptureVideoSample:(PBJVision *)vision
{
    float captureSeconds = vision.capturedVideoSeconds;
    
    int seconds = floor(captureSeconds);
    if (seconds > elapsedSeconds) {
        lblTime.text = [NSString stringWithFormat:@"00:%02d", seconds];
        elapsedSeconds = seconds;
    }
    
    progressView.progress = vision.capturedVideoSeconds / vision.maximumCaptureDuration.value;
}

@end
