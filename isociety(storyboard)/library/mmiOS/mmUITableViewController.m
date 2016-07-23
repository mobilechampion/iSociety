//
//  mmUITableViewController.m
//  mmiOS
//
//  Created by Kevin McNeish 
//  Copyright 2013 Oak Leaf Enterprises, Inc. All rights reserved.
//

#import "mmUITableViewController.h"

// NOTES:
// This enhanced subclass of UITableViewController includes the following functionality:
// 1. Autorotation and resizing to handle reorientation in both the iPhone and iPad

@implementation mmUITableViewController


#pragma mark -
#pragma mark Initialization


#pragma mark -
#pragma mark View lifecycle


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	
	if ([self.tableView respondsToSelector:@selector(backgroundView)]) 
		self.tableView.backgroundView = nil;
    
    // Used for positioning table view to checkmarked cell
    self.pendingScroll = YES;

	[self hookPositionControls];
}

// An Action method that hides the keyboard when the user touches the keyboard Return 
// You can link a UITextField's "Did End on Exit" event to this method
-(IBAction)textFieldReturn:(id)sender
{
	[sender resignFirstResponder];
} 

// An Action method that ends editing in the specified view which hides the keyboard
// You can link a control's "Touch Down" event to this method
- (IBAction)backgroundTouched:(id)sender
{
	[mmUIViewHelper backgroundTouched:self.view];
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
- (UIView *) getFirstResponder {
	return [mmUIViewHelper getFirstResponder:self.view];
}

// Gets the height of the keyboard taking into account device orientation
- (CGFloat) getKeyBoardHeight:(NSNotification *)notification {
	return [mmUIViewHelper getKeyBoardHeight:notification];
}

// A hook method into which you can place code that positions your UI controls 
// This method is called automatically from viewWillAppear and also from
// shouldAutorotateToInterfaceOrientation when the device orientation changes
- (void) hookPositionControls {
	// Implemented in subclass
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

-(void) willAnimateSecondHalfOfRotationFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation duration:(NSTimeInterval)duration {
	[self hookPositionControls];
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	/*
	 <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
	 [self.navigationController pushViewController:detailViewController animated:YES];
	 [detailViewController release];
	 */
	NSInteger test = 11;
	test++;
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}

- (void)setCellAtIndexPath:(NSIndexPath *)indexPath enabled:(BOOL)enabled
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    cell.userInteractionEnabled = enabled;
    cell.textLabel.enabled = enabled;
}

#pragma mark -
#pragma mark Business Rules
- (void)displayBrokenRuleMessage:(NSString *)message
{
    [mmUIViewHelper displayBrokenRuleMessage:message forView:self.view];
}


@end

