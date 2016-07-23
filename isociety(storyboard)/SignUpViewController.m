//
//  SignUpViewController.m
//  Seik
//
//  Created by Gavin on 10/26/14.
//  Copyright (c) 2014 Seik, Inc. All rights reserved.
//

#import "SignUpViewController.h"
#import "TermsViewController.h"
#import "AppDelegate.h"
#import "HomeController.h"
#import "Localization.h"
#import "Gradient.h"

@interface SignUpViewController ()<UITextFieldDelegate>
{
    IBOutlet UITextField *username,*email,*password;
    IBOutlet UIButton *signUpButton;
    IBOutlet UIButton *loginButton;
    IBOutlet NSLayoutConstraint *centerConstarint;
}
@end

@implementation SignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self customiseValues];
    
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)]];
    
    [self setupGradients];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
}

-(void)customiseValues
{
    self.title = [[Localization sharedInstance] localizedStringForKey:@"Sign Up"];
    
    username.placeholder =[[Localization sharedInstance] localizedStringForKey:@"Enter a Username"];
    email.placeholder =[[Localization sharedInstance] localizedStringForKey:@"Enter an Email Address"];
    password.placeholder =[[Localization sharedInstance] localizedStringForKey:@"Enter a Password"];
    
    
    NSMutableAttributedString *logInAttString = [[NSMutableAttributedString alloc] initWithString:[[Localization sharedInstance] localizedStringForKey:@"Login"]];
    [logInAttString addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:NSMakeRange(0, [logInAttString length])];
    [loginButton setAttributedTitle:logInAttString forState:UIControlStateNormal];
}

-(IBAction)signUp:(UIButton *)sender
{
    NSString *nameStr		= username.text;
    NSString *passwordStr	= password.text;
    NSString *emailStr		= email.text;
    
    if ((nameStr.length != 0) && (passwordStr.length != 0) && (emailStr.length != 0))
    {
        [ProgressHUD show:[NSString stringWithFormat:@"%@...",[[Localization sharedInstance] localizedStringForKey:@"Verifying"]] Interaction:NO];
        
        PFUser *user = [PFUser user];
        user.username = nameStr;
        user.password = passwordStr;
        user.email = emailStr;
        user[PF_USER_EMAILCOPY] = emailStr;
        user[PF_USER_FULLNAME] = nameStr;
        user[PF_USER_FULLNAME_LOWER] = [nameStr lowercaseString];
        user[PF_USER_AVIALABLITY] = [NSString stringWithFormat:@"%d",kStatusAvailable];
        user[PF_USER_STATUS] = @" ";
        
        CGFloat hue = ( arc4random() % 256 / 256.0 );  //  0.0 to 1.0
        CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
        CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
        NSLog(@"%f - %f - %f", hue, saturation, brightness);
        
        user[PF_USER_COLOR_HUE] = [NSString stringWithFormat:@"%f", hue];
        user[PF_USER_COLOR_SAT] = [NSString stringWithFormat:@"%f", saturation];
        user[PF_USER_COLOR_BRG] = [NSString stringWithFormat:@"%f", brightness];

        [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
         {
             if (error == nil)
             {
                 [ProgressHUD showSuccess:[[Localization sharedInstance] localizedStringForKey:@"Welcome!"]];
//                 [AppDelegate sharedAppDelegate].isLoggedIn = YES;

//                 UITabBarController *homeController = [self.storyboard instantiateViewControllerWithIdentifier:@"mainTab"];
//                 [self presentViewController:homeController animated:NO completion:nil];
                 
                 NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
                 
                 [userDefault setObject:@"yes" forKey:@"isAlreadyLogin"];
                 [userDefault synchronize];
                 
                 TermsViewController *terms = [self.storyboard instantiateViewControllerWithIdentifier:@"TermsViewController"];
                 [self.navigationController pushViewController:terms animated:YES];

             }
             else{
                 [ProgressHUD showError:[error.userInfo valueForKey:@"Error"]];
             }
         }];
    }
    else{
        [ProgressHUD showError:[[Localization sharedInstance] localizedStringForKey:@"Please fill in all the blanks!"]];
    }
}

-(IBAction)login:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)setupGradients
{
    [self.view.layer insertSublayer:[Gradient setupGradient:self.view.frame] atIndex:0];
}


#pragma mark - UITextField delegate & keyboard methods
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    if ( UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad )
        centerConstarint.constant = 110.0;

    [self keyboardWillShow];
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    [self keyboardWillHide];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if ([string isEqualToString:@"\n"]) {
        [textField resignFirstResponder];
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    if (theTextField == username) {
        [theTextField resignFirstResponder];
        [email becomeFirstResponder];
    }
    else if (theTextField == email){
        [theTextField resignFirstResponder];
        [password becomeFirstResponder];
    }
    else if (theTextField == password) {
        [theTextField resignFirstResponder];
        [username becomeFirstResponder];
    }
    return YES;
}

- (void)dismissKeyboard{
    [self.view endEditing:YES];
    if ( UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad )
        centerConstarint.constant = 0.0;
}

- (void)keyboardWillBeHiddenSignUp:(NSNotification *)notification {
    
}

-(void)keyboardWillShow {
    // Animate the current view out of the way
    if (self.view.frame.origin.y >= 0){
        [self setViewMovedUp:YES];
    }
    else if (self.view.frame.origin.y < 0){
        //        [self setViewMovedUp:NO];
    }
}

-(void)keyboardWillHide {
    if (self.view.frame.origin.y >= 0){
        //        [self setViewMovedUp:YES];
    }
    else if (self.view.frame.origin.y < 0){
        [self setViewMovedUp:NO];
    }
}

//method to move the view up/down whenever the keyboard is shown/dismissed
-(void)setViewMovedUp:(BOOL)movedUp{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3]; // if you want to slide up the view
    
    CGRect rect = self.view.frame;
    if (movedUp){
        // 1. move the view's origin up so that the text field that will be hidden come above the keyboard
        // 2. increase the size of the view so that the area behind the keyboard is covered up.
        rect.origin.y -= 150;
    }
    else{
        // revert back to the normal state.
        rect.origin.y += 150;
        //        rect.size.height -= kOFFSET_FOR_KEYBOARD;
    }
    self.view.frame = rect;
    
    [UIView commitAnimations];
}

@end