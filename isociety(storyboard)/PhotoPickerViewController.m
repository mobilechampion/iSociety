//
//  PhotoPickerViewController.m
//  Seik
//
//  Created by Gavin on 10/26/14.
//  Copyright (c) 2014 Seik, Inc. All rights reserved.
//

#import "PhotoPickerViewController.h"

@interface PhotoPickerViewController ()

@end

@implementation PhotoPickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
        if (isCameraAvailable) {
            self.imagePickerSourceType = UIImagePickerControllerSourceTypeCamera;
        } else {
            self.imagePickerSourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        }
        [self showImagePicker];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)showImagePicker{
    if (!self.manualImagePickerController) {
        self.manualImagePickerController = [[UIImagePickerController alloc] init];
        [self.manualImagePickerController setDelegate:self];
    }
    
    [self.manualImagePickerController setSourceType:self.imagePickerSourceType];
    [self presentViewController:self.manualImagePickerController animated:YES completion:nil];
}

@end
