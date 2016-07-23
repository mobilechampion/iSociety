//
//  LoginViewController.m
//  Seik
//
//  Created by Gavin on 10/26/14.
//  Copyright (c) 2014 Seik, Inc. All rights reserved.
//

#import "LoginViewController.h"
#import "SignUpViewController.h"
#import "AppDelegate.h"
#import "HomeController.h"
#import "Localization.h"
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import <Parse/Parse.h>
#import <FacebookSDK/FacebookSDK.h>
#import "Gradient.h"

@interface LoginViewController ()<UIAlertViewDelegate,UITabBarControllerDelegate>{
    IBOutlet UITextField *userName,*password;
    
    IBOutlet UIButton *forgetPasswordButton,*loginButton,*signUpButton;
    IBOutlet UIButton *changeLanguageButton;
    IBOutlet UIView *myView;
    IBOutlet NSLayoutConstraint *centerYconstaint;
}
@end

@implementation LoginViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    
    
    
    
    

    [self customiseValues];
    [self setupGradients];
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)]];
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

/////////////////////////////////////////////////////////////
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    if ( UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad )
        centerYconstaint.constant = -60.0;
}

///////////////////////////////////////////////////////////////////
-(void)customiseValues{
    self.title = [[Localization sharedInstance] localizedStringForKey:@"Login"];
    userName.placeholder = [[Localization sharedInstance] localizedStringForKey:@"Enter your Username"];
    password.placeholder = [[Localization sharedInstance] localizedStringForKey:@"Enter your Password"];
    
    [loginButton setTitle:[[Localization sharedInstance] localizedStringForKey:@"Login"] forState:UIControlStateNormal];
    [signUpButton setTitle:[[Localization sharedInstance] localizedStringForKey:@"Sign Up"] forState:UIControlStateNormal];
    
    [forgetPasswordButton setTitle:[NSString stringWithFormat:@"%@?",[[Localization sharedInstance] localizedStringForKey:@"Forgot Password"]] forState:UIControlStateNormal];
    NSMutableParagraphStyle *style  = [[NSMutableParagraphStyle alloc] init];
    [style setLineSpacing:4];
    float spacing = 0.4f;
    NSDictionary *attributtes = @{NSParagraphStyleAttributeName : style, NSKernAttributeName : @(spacing) , NSForegroundColorAttributeName: [UIColor blueColor]};
    NSAttributedString* as = [[NSAttributedString alloc] initWithString:[[Localization sharedInstance] localizedStringForKey:@"Forgot Password"] attributes:attributtes];
    [forgetPasswordButton setAttributedTitle:as forState:UIControlStateNormal];
    NSAttributedString* as1 = [[NSAttributedString alloc] initWithString:[[Localization sharedInstance] localizedStringForKey:@"Sign Up"] attributes:attributtes];
    [signUpButton setAttributedTitle:as1 forState:UIControlStateNormal];

    NSLog(@"ch1 = %@", [[Localization sharedInstance] localizedStringForKey:@"Change Language"]);
    NSLog(@"ch2 = %@", changeLanguageButton.titleLabel.text);
    
    //Change language
    NSAttributedString *existAttrStr = changeLanguageButton.titleLabel.attributedText;
    [existAttrStr enumerateAttributesInRange:NSMakeRange(0, 1)
                                     options:0
                                  usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop) {
                                      //NSLog(@"attrs = %@", attrs);
                                      NSAttributedString *finalStr = [[NSAttributedString alloc]
                                                                      initWithString:[[Localization sharedInstance] localizedStringForKey:@"Change Language"]
                                                                      attributes:attrs];
                                      [changeLanguageButton setAttributedTitle:finalStr forState:UIControlStateNormal];
                                  }];
}

- (void)dismissKeyboard{
    [self.view endEditing:YES];
    if ( UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad )
        centerYconstaint.constant = 0.0;
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    if (theTextField == userName) {
        [theTextField resignFirstResponder];
        [password becomeFirstResponder];
    } else if (theTextField == password) {
        [theTextField resignFirstResponder];
        [userName becomeFirstResponder];
    }
    return YES;
}

-(IBAction)login:(UIButton *)sender
{
    NSString *usernameStr = userName.text;
    NSString *passwordStr = password.text;
    if ((usernameStr.length != 0) && (passwordStr.length != 0))
    {
        [ProgressHUD show:[NSString stringWithFormat:@"%@...",[[Localization sharedInstance] localizedStringForKey:@"Signing In"]] Interaction:NO];
        [PFUser logInWithUsernameInBackground:usernameStr password:passwordStr block:^(PFUser *user, NSError *error)
         {
             if (user != nil)
             {
                 [ProgressHUD showSuccess:[NSString stringWithFormat:@"%@ %@!",[[Localization sharedInstance] localizedStringForKey:@"Welcome Back!"], [user objectForKey:PF_USER_USERNAME]]];
                 //Adding another channel for current installation for sending push notifications:
//                 [AppDelegate sharedAppDelegate].isLoggedIn = YES;

                 PFUser *user = [PFUser currentUser];
                 user[PF_USER_AVIALABLITY] = @"1";
                 
                 PFInstallation *currentInstallation = [PFInstallation currentInstallation];
               
                 currentInstallation[@"User"] = user;
                 [currentInstallation saveInBackground];

                 NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
                 
                 [userDefault setObject:@"yes" forKey:@"isAlreadyLogin"];
                 [userDefault setObject:user.objectId forKey:@"userID"]
                 ;
                 [userDefault synchronize];
                 
                 UITabBarController *PostViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"mainTab"];
                 
                 PostViewController.selectedViewController = [PostViewController.viewControllers objectAtIndex:2];
                 
                 [self presentViewController:PostViewController animated:NO completion:nil];
                 AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
                 delegate.MainTabBar = PostViewController;
             }
             else{
                 [ProgressHUD showError:[error.userInfo valueForKey:@"Error"]];
             }
         }];
    }
    else [ProgressHUD showError:[[Localization sharedInstance] localizedStringForKey:@"Please enter both your Username and Password"]];
}



-(IBAction)forgetPassword:(UIButton *)sender{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Don't worry about it!" message:[[Localization sharedInstance] localizedStringForKey:@"Enter your registered email address"] delegate:self cancelButtonTitle:[[Localization sharedInstance] localizedStringForKey:@"Cancel"] otherButtonTitles:[[Localization sharedInstance] localizedStringForKey:@"Send"], nil];
    
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    
    [alertView show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        NSLog(@"update");
        NSString *mailId = ((UITextField *)[alertView textFieldAtIndex:0]).text;
        if ([BATUtil validateEmailWithString:mailId]){
            
            [PFUser requestPasswordResetForEmailInBackground:mailId block:^(BOOL succeeded, NSError *error) {
                if (succeeded && !error) {
                    [ProgressHUD showSuccess:[NSString stringWithFormat:@"%@ : %@",[[Localization sharedInstance] localizedStringForKey:@"A password reset link was sent to your email address provided."],mailId]];
                }else{
                    [ProgressHUD showError:[error.userInfo valueForKey:@"Error"]];
                }
            }];
            
        }
        else{
            [ProgressHUD showError:[[Localization sharedInstance] localizedStringForKey:@"Please enter a valid email address."]];
        }
    }
}

-(IBAction)signUp:(id)sender{
    SignUpViewController *signUp = [self.storyboard instantiateViewControllerWithIdentifier:@"SignUpViewController"];
    [self.navigationController pushViewController:signUp animated:YES];
}

-(IBAction)fbLogin:(id)sender{
    [ProgressHUD show:[NSString stringWithFormat:@"%@...",[[Localization sharedInstance] localizedStringForKey:@"Signing in"]] Interaction:NO];
    
    [PFFacebookUtils logInWithPermissions:@[@"public_profile",@"email",@"user_friends"] block:^(PFUser *user, NSError *error) {
        if (!user) {
            [ProgressHUD showError:[[Localization sharedInstance] localizedStringForKey:@"Network Error"]];
        }else {
            if (user != nil)
            {
                [ProgressHUD showSuccess:[NSString stringWithFormat:@"%@ %@!",[[Localization sharedInstance] localizedStringForKey:@"Welcome Back"], [user objectForKey:PF_USER_USERNAME]]];
//                [AppDelegate sharedAppDelegate].isLoggedIn = YES;
                
                NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
                
                [userDefault setObject:@"yes" forKey:@"isAlreadyLogin"];
                [userDefault synchronize];
                
                UITabBarController *homeController = [self.storyboard instantiateViewControllerWithIdentifier:@"mainTab"];
                
                homeController.selectedViewController = [homeController.viewControllers objectAtIndex:2];
                
                [self presentViewController:homeController animated:NO completion:nil];
            }
            else{
                [ProgressHUD showError:[error.userInfo valueForKey:@"Error"]];
            }
        }
    }];
    
//    [PFFacebookUtils logInWithPermissions:@[@"public_profile", @"email", @"user_friends"] block:^(PFUser *user, NSError *error) {
//        if (!user) {
////            [SVProgressHUD dismiss];
//            NSLog(@"Uh oh. The user cancelled the Facebook login.");
//            
//            NSString *errorMessage = nil;
//            if (!error) {
//                NSLog(@"Uh oh. The user cancelled the Facebook login.");
//                errorMessage = @"Uh oh. The user cancelled the Facebook login.";
//            } else {
//                NSLog(@"Uh oh. An error occurred: %@", error);
//                errorMessage = [error localizedDescription];
//            }
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log In Error"
//                                                            message:errorMessage
//                                                           delegate:nil
//                                                  cancelButtonTitle:nil
//                                                  otherButtonTitles:@"Dismiss", nil];
//            [alert show];
//            return;
//            
//        } else if (user.isNew) {
//            NSLog(@"User signed up and logged in through Facebook!");
//            
//            FBRequest *request = [FBRequest requestForMe];
//            [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
////                [SVProgressHUD dismiss];
//                if (!error) {
//                    // result is a dictionary with the user's Facebook data
//                    PFUser *user = [PFUser user];
//                    
//                    NSDictionary *userData = (NSDictionary *)result;
//                    NSString *facebookID = userData[@"id"];
//                    NSString *firstName = userData[@"first_name"];
//                    NSString *lastName = userData[@"last_name"];
//                    NSString *email = userData[@"email"];
//                    NSString *nameStr = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
//                    
//                    user.username = facebookID;
//                    user.password = @"";
//                    user.email = email;
//                    user[PF_USER_EMAILCOPY] = email;
//                    user[PF_USER_FULLNAME] = nameStr;
//                    user[PF_USER_FULLNAME_LOWER] = [nameStr lowercaseString];
//                    user[PF_USER_AVIALABLITY] = [NSString stringWithFormat:@"%d",kStatusAvailable];
//                    user[PF_USER_STATUS] = @" ";
//                    
//                    CGFloat hue = ( arc4random() % 256 / 256.0 );  //  0.0 to 1.0
//                    CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
//                    CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
//                    NSLog(@"%f - %f - %f", hue, saturation, brightness);
//                    
//                    user[PF_USER_COLOR_HUE] = [NSString stringWithFormat:@"%f", hue];
//                    user[PF_USER_COLOR_SAT] = [NSString stringWithFormat:@"%f", saturation];
//                    user[PF_USER_COLOR_BRG] = [NSString stringWithFormat:@"%f", brightness];
//                    
//                    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
//                     {
//                         if (error == nil)
//                         {
//                             [ProgressHUD showSuccess:[[Localization sharedInstance] localizedStringForKey:@"Success"]];
//                             //[self performSegueWithIdentifier:@"Home" sender:self];
//                             //                 [AppDelegate sharedAppDelegate].isLoggedIn = YES;
//                             HomeController *homeController = [self.storyboard instantiateViewControllerWithIdentifier:@"HomeController"];
//                             [self.navigationController pushViewController:homeController animated:YES];
//                         }
//                         else{
//                             [ProgressHUD showError:[error.userInfo valueForKey:@"Error"]];
//                         }
//                     }];
//                }
//                
//            }];
//        } else {
////            [SVProgressHUD dismiss];
//            [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
//             {
//                 if (error == nil)
//                 {
//                     [ProgressHUD showSuccess:[[Localization sharedInstance] localizedStringForKey:@"Success"]];
//                     //[self performSegueWithIdentifier:@"Home" sender:self];
//                     //                 [AppDelegate sharedAppDelegate].isLoggedIn = YES;
//                     HomeController *homeController = [self.storyboard instantiateViewControllerWithIdentifier:@"HomeController"];
//                     [self.navigationController pushViewController:homeController animated:YES];
//                 }
//                 else{
//                     [ProgressHUD showError:[error.userInfo valueForKey:@"Error"]];
//                 }
//             }];
//            
//            NSLog(@"User logged in through Facebook!");
//            
//        }
//    }];
}

-(IBAction)twLogin:(id)sender{
    [ProgressHUD show:[NSString stringWithFormat:@"%@...",[[Localization sharedInstance] localizedStringForKey:@"Signing In"]] Interaction:NO];
    
    [PFTwitterUtils logInWithBlock:^(PFUser *user, NSError *error) {
        if (!user) {
            [ProgressHUD showError:[[Localization sharedInstance] localizedStringForKey:@"Network Error"]];
        }else {
            if (user != nil)
            {
                [ProgressHUD showSuccess:[NSString stringWithFormat:@"%@ %@!",[[Localization sharedInstance] localizedStringForKey:@"Welcome Back!"], [user objectForKey:PF_USER_USERNAME]]];
                
                //[self performSegueWithIdentifier:@"Home" sender:self];
//                [AppDelegate sharedAppDelegate].isLoggedIn = YES;
                
//                HomeController *homeController = [self.storyboard instantiateViewControllerWithIdentifier:@"HomeController"];
//                [self.navigationController pushViewController:homeController animated:YES];
                
                NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
                
                [userDefault setObject:@"yes" forKey:@"isAlreadyLogin"];
                [userDefault synchronize];
                
                UITabBarController *homeController = [self.storyboard instantiateViewControllerWithIdentifier:@"mainTab"];
                
                homeController.selectedViewController = [homeController.viewControllers objectAtIndex:2];
                
                [self presentViewController:homeController animated:NO completion:nil];

                
                //                 [self dismissViewControllerAnimated:NO completion:nil];
            }
            else{
                [ProgressHUD showError:[error.userInfo valueForKey:@"Error"]];
            }
        }
    }];
}

-(void)setupGradients{
    [self.view.layer insertSublayer:[Gradient setupGradient:self.view.frame] atIndex:0];
}

- (IBAction)changeLanguage:(id)sender{
    [[AppDelegate sharedAppDelegate] initializeArray];
    [[AppDelegate sharedAppDelegate] addPickerView];
}

@end
