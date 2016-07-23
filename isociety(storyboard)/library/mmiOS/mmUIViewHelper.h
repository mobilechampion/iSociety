//
//  mmUIViewHelper.h
//  mmiOS
//
//  Created by Kevin McNeish
//  Copyright 2013 Oak Leaf Enterprises, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface mmUIViewHelper : NSObject {

}

// Ends editing in the specified view which hides the keyboard
+ (void) backgroundTouched:(UIView *)parentView;

// Centers the control horizontally
+ (void) centerControlHorizontal:(UIView *)parentView :(UIView *)control;

// Centers the controls listed in the array horizontally
+ (void) centerControlsHorizontal :(UIView *)parentView :(NSArray *)controlsArray :(NSUInteger) spacing;

// Gets the first responder for the specified view
+ (UIView *) getFirstResponder:(UIView *)view;

// Gets the height of the keyboard taking into account device orientation
+ (CGFloat) getKeyBoardHeight:(NSNotification *)notification;

// Centers the control horizontally
+ (void) setControlLeft:(UIView *)control :(NSInteger)left;

// Display a broken rule message
+ (void)displayBrokenRuleMessage:(NSString *)message forView:(UIView *)view;


@end
