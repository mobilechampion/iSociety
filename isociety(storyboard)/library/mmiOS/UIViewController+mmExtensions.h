//
//  UIViewController+mmExtensions.h
//  iAppsReview
//
//  Created by Kevin McNeish on 5/29/13.
//  Copyright (c) 2013 Oak Leaf Enterprises, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (mmExtensions)

// An Action method that ends editing in the specified view which hides the keyboard
// You can link a control's "Touch Down" event to this method
- (IBAction) backgroundTouched:(id)sender;

// An Action method that hides the keyboard when the user touches the keyboard Return
// You can link a UITextField's "Did End on Exit" event to this method
- (IBAction) textFieldReturn:(id)sender;

// Displays the broken rule message
- (void)displayBrokenRuleMessage:(NSString *)message;

@end
