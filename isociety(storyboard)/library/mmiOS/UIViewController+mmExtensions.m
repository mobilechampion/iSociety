//
//  UIViewController+mmExtensions.m
//  iAppsReview
//
//  Created by Kevin McNeish on 5/29/13.
//  Copyright (c) 2013 Oak Leaf Enterprises, Inc. All rights reserved.
//

#import "UIViewController+mmExtensions.h"
#import "UIView+Toast.h"

@implementation UIViewController (mmExtensions)

- (IBAction)backgroundTouched:(id)sender
{
	[self.view endEditing:YES];
}

// An Action method that hides the keyboard when the user touches the keyboard Return
// You can link a UITextField's "Did End on Exit" event to this method
-(IBAction)textFieldReturn:(id)sender
{
	[sender resignFirstResponder];
}

#pragma mark -
#pragma mark Business Rules
- (void)displayBrokenRuleMessage:(NSString *)message
{
    [self.view makeToast:message];
}

@end
