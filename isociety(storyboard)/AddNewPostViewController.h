//
//  AddNewPostViewController.h
//  Seik
//
//  Created by Gavin on 10/26/14.
//  Copyright (c) 2014 Seik, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "PBJVideoPlayerController.h"

@protocol GetVideoPath <NSObject>

- (void)setVideoPath:(NSString*)videoPathString;

@end

@interface AddNewPostViewController : UIViewController<UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate, GetVideoPath, UITextViewDelegate, UITextFieldDelegate, PBJVideoPlayerControllerDelegate>{
    IBOutlet UIView *typeView;
    IBOutlet UILabel *headlineLabel, *descLabel, *typeLabel;
    IBOutlet UIImageView *imgView, *enlargedView;
    IBOutlet UIButton *playButton, *postButton, *addMediaButton;
    IBOutlet UITextView *descTxtView;
    IBOutlet UITextField *titleTxtField;
    UISegmentedControl *mediaType;
}

@property (nonatomic, retain) PFObject *infoDict;
@property (nonatomic, readwrite) BOOL bNew;
@property (nonatomic) UIImagePickerControllerSourceType imagePickerSourceType;

@property (strong, nonatomic) MPMoviePlayerController *moviePlayer;
@property (nonatomic, strong) UIImagePickerController* manualImagePickerController;
@property (nonatomic, strong) UIImage *capturedImage;
@property (nonatomic, retain) NSString *videoPathString;

@end
