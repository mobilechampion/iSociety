//
//  mmUIViewController.m
//  mmiOS
//
//  Created by Kevin McNeish
//  Copyright 2013 Oak Leaf Enterprises, Inc. All rights reserved.
//

#import "mmUIViewController.h"
#import "mmDevice.h"

@implementation mmUIViewController
{
	UIViewController *landscapeViewController;
}

- (void)awakeFromNib
{

}

- (void)setSwitchPortraitLandscapeControllers:(BOOL)value
{
	if (value) {
		[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
		[[NSNotificationCenter defaultCenter]
		 addObserver:self
		 selector:@selector(orientationChanged:)
		 name:UIDeviceOrientationDidChangeNotification
		 object:nil];
	}
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	// Register for keyboard notifications
	[[NSNotificationCenter defaultCenter] addObserver:self 
				selector:@selector(keyboardWasShown:) 
					name:UIKeyboardDidShowNotification 
					object:self.view.window];
	
	// Register for keyboard notifications
	[[NSNotificationCenter defaultCenter] addObserver:self 
				selector:@selector(keyboardWillBeHidden:) 
					name:UIKeyboardWillHideNotification 
					object:self.view.window];
	
	// Make contentSize bigger than your scrollSize
	self.scrollView.contentSize =
		CGSizeMake(self.view.frame.size.width,
				   self.view.frame.size.height + 10);
}

- (void)viewDidUnload {
	
    [self setScrollView:nil];
    // Unregister for keyboard notifications while not visible
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:UIKeyboardWillShowNotification 
                                                  object:nil]; 
    // Unregister for keyboard notifications while not visible
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:UIKeyboardWillHideNotification 
                                                  object:nil]; 
    [super viewDidUnload];

}

- (void)keyboardWasShown:(NSNotification *)notification
{
    // get the height of the keyboard
    CGFloat keyBoardHeight = [self getKeyBoardHeight:notification];
	
	UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyBoardHeight, 0.0);
	self.scrollView.contentInset = contentInsets;
	self.scrollView.scrollIndicatorInsets = contentInsets;
	
	// If active text field is hidden by keyboard,
	// scroll so it's visible
	CGRect viewRect = self.view.frame;
	
	UIView* activeControl = [self getFirstResponder];
	
    viewRect.size.height -= keyBoardHeight;
	
    if (!CGRectContainsPoint(viewRect, activeControl.frame.origin) ) {
		CGFloat offset;
		UIInterfaceOrientation orientation = mmDevice.deviceOrientation;
		if (UIInterfaceOrientationIsPortrait(orientation)) {
			offset = 49;
		}
		else {
			offset = 49+49;
		}
        CGPoint scrollPoint =
			CGPointMake(0.0, activeControl.frame.origin.y -
						keyBoardHeight + offset);
        [self.scrollView setContentOffset:scrollPoint animated:YES];
	}
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
	UIEdgeInsets contentInsets = UIEdgeInsetsZero;
	self.scrollView.contentInset = contentInsets;
	self.scrollView.scrollIndicatorInsets = contentInsets;
}

- (void)viewWillAppear:(BOOL)animated {
	
	[self hookPositionControls];
	
    [super viewWillAppear:animated];
}

- (IBAction)backgroundTouched:(id)sender
{
	[mmUIViewHelper backgroundTouched:self.view];
}

// An Action method that hides the keyboard when the user touches the keyboard Return 
// You can link a UITextField's "Did End on Exit" event to this method
-(IBAction)textFieldReturn:(id)sender
{
	[sender resignFirstResponder];
} 

// Centers the control horizontally
- (void) centerControlHorizontalInParentView:(UIView *)parentView control:(UIView *)control {
	[mmUIViewHelper centerControlHorizontal:parentView :control];
}

// Centers the controls listed in the array horizontally
- (void) centerControlsHorizontalInParentView:(UIView *)parentView controls:(NSArray *)controlArray withSpacing:(NSUInteger)spacing {
	[mmUIViewHelper centerControlsHorizontal:self.view :controlArray :spacing];
}

// Gets the first responder for the view
- (UIView *) getFirstResponder{
	return [mmUIViewHelper getFirstResponder:self.view];
}

// A hook method into which you can place code that positions your UI controls 
// This method is called automatically from viewWillAppear and also from
// shouldAutorotateToInterfaceOrientation when the device orientation changes
- (void) hookPositionControls {
	// Implemented in subclass
	NSInteger test = 1;
	test++;
}

// Gets the height of the keyboard taking into account device orientation
- (CGFloat) getKeyBoardHeight:(NSNotification *)notification {
	return [mmUIViewHelper getKeyBoardHeight:notification];
}

//iPhone should not be flipped upside down. iPad can have any orientation
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)dealloc {
	
}

- (void)orientationChanged:(NSNotification *) notification
{
	[self switchViewControllers];
}

- (void)navigationController:(UINavigationController *)navigationController
	   didShowViewController:(UIViewController *)viewController
					animated:(BOOL)animated
{
	// Coming back from another scene.Make sure the correct
	// view controller is displayed
	[self switchViewControllers];
}

- (void) switchViewControllers
{
	UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;

	// Check if the correct controller is displayed for the current orientation
	if (UIDeviceOrientationIsLandscape(deviceOrientation) &&
		self.navigationController.visibleViewController == self)
    {
		// The device orientation is landscape and the portrait controller
		// is currently displayed, so display the landscape controller
		if (!landscapeViewController) {
			landscapeViewController = [self.storyboard
			 instantiateViewControllerWithIdentifier: @"LandscapeViewController"];
			landscapeViewController.navigationItem.hidesBackButton = YES;
		}
     	[self.navigationController pushViewController:
				landscapeViewController
				animated:NO];
    }
    else if (UIDeviceOrientationIsPortrait(deviceOrientation) &&
			 self.navigationController.visibleViewController ==
			 landscapeViewController)
    {
		// The device orientation is portrait the landscape controller is
		// currently displayed, so display the portrait view controller
        [self.navigationController popViewControllerAnimated:NO];
    }
}

@end
