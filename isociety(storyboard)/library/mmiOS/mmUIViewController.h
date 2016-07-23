//
//  mmUIViewController.h
//  mmiOS
//
//  Created by Kevin McNeish
//  Copyright 2011 Oak Leaf Enterprises, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "mmUIViewHelper.h"

@interface mmUIViewController : UIViewController {
	
}

// Optional Scrollview - used when need to scroll content when keyboard appears
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;

@property (assign, nonatomic) BOOL switchPortraitLandscapeControllers;

// An Action method that ends editing in the specified view which hides the keyboard
// You can link a control's "Touch Down" event to this method
- (IBAction) backgroundTouched:(id)sender;

// An Action method that hides the keyboard when the user touches the keyboard Return 
// You can link a UITextField's "Did End on Exit" event to this method
- (IBAction) textFieldReturn:(id)sender;

// Centers the control horizontally
- (void) centerControlHorizontalInParentView:(UIView *)parentView control:(UIView *)control;

// Centers the controls listed in the array horizontally
- (void) centerControlsHorizontalInParentView:(UIView *)parentView controls:(NSArray *)controlArray withSpacing:(NSUInteger)spacing;

// Gets the first responder for the view
- (UIView *) getFirstResponder;

// Gets the height of the keyboard taking into account device orientation
- (CGFloat) getKeyBoardHeight:(NSNotification *)notification;

// A hook method into which you can place code that positions your UI controls 
// This method is called automatically from viewWillAppear and also from
// shouldAutorotateToInterfaceOrientation when the device orientation changes
- (void) hookPositionControls;

@end
