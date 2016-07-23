//
//  PhotoPickerViewController.h
//  Seik
//
//  Created by Gavin on 10/26/14.
//  Copyright (c) 2014 Seik, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoPickerViewController : UIViewController

@property (nonatomic) UIImagePickerControllerSourceType imagePickerSourceType;
@property (nonatomic, strong) UIImagePickerController* manualImagePickerController;
@property (nonatomic, strong) UIImage *capturedImage;

@end
