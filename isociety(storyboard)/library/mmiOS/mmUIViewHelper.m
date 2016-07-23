//
//  mmUIViewHelper.m
//  mmiOS
//
//  Created by Kevin McNeish
//  Copyright 2013 Oak Leaf Enterprises, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "mmUIViewHelper.h"
#import "mmDevice.h"
#import "UIView+Toast.h"

@implementation mmUIViewHelper

// Ends editing in the specified view which hides the keyboard
+ (void) backgroundTouched:(UIView *)parentView{
	
	[parentView endEditing:YES];
}

// Gets the first responder for the specified view
+ (UIView *) getFirstResponder:(UIView *)view {
	
	if (view.isFirstResponder) {
		return view;
	}
	
	for (UIView *subView in view.subviews) {
		
		UIView *firstResponder = [self getFirstResponder:subView];
		if (firstResponder != nil) {
			return firstResponder;
		}
	}
	return nil;
}

// Gets the height of the keyboard taking into account device orientation
+ (CGFloat) getKeyBoardHeight:(NSNotification *)notification {
	
	CGFloat keyBoardHeight;
	CGRect keyBoardEndFrame;
	
	[[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyBoardEndFrame];
	
	UIInterfaceOrientation orientation = mmDevice.deviceOrientation;
	if (UIInterfaceOrientationIsPortrait(orientation)) {
		keyBoardHeight = keyBoardEndFrame.size.height;
	}
	else {
		keyBoardHeight = keyBoardEndFrame.size.width;
	}
	return keyBoardHeight;
}

// Centers the controls listed in the array horizontally
+ (void) centerControlsHorizontal:(UIView *)parentView :(NSArray *)controls :(NSUInteger) spacing {
	
	int controlsWidth = 0;
	int left;

	// calculate the width of all controls
	for (UIView *control in controls) {
		controlsWidth += control.frame.size.width;
	}
	// Add spacing to determine the total width
	controlsWidth += spacing * (controls.count - 1);
	
	// Calculate the left position of the first control
	left = (parentView.frame.size.width - controlsWidth) / 2;
	
	// position the controls
	for (UIView *control in controls) {
		[mmUIViewHelper setControlLeft :control: left];
		left += control.frame.size.width + spacing;
	}
}	

// Centers the control horizontally
+ (void) centerControlHorizontal:(UIView *)parentView :(UIView *)control{
	
	NSInteger viewWidth;
		
	if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationPortrait || [[UIDevice currentDevice] orientation] == UIDeviceOrientationPortraitUpsideDown) {
		viewWidth = parentView.frame.size.width;
	}
	else {
		viewWidth = parentView.frame.size.height;
	}
	
	// Calculate the left position of the first control
	NSInteger left = (viewWidth - control.frame.size.width) / 2;
	
	[mmUIViewHelper setControlLeft:control :left];
}

+ (void) setControlLeft:(UIView *)control :(NSInteger)left
{
	CGRect frame = control.frame;
	frame.origin.x = left;
	control.frame = frame;
}

+ (void)displayBrokenRuleMessage:(NSString *)message forView:(UIView *)view
{
    [view makeToast:message];
}


@end
