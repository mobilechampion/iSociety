//
//  mmDevice.m
//  MMiOS
//
//  Created by Kevin McNeish 
//  Copyright (c) 2013 Oak Leaf Enterprises, Inc. All rights reserved.
//

#import "mmDevice.h"
#import <UIKit/UIKit.h>

@implementation mmDevice

static UIImageView *splashView;

// Returns the current device orientation
+ (UIInterfaceOrientation)deviceOrientation
{
    return [[UIApplication sharedApplication] statusBarOrientation];
}

+ (void)animateLaunchImageInWindow:(UIWindow *)window forDuration:(NSTimeInterval)duration
{

	// Create the 
    if([mmDevice isOrientationLandscape]) {
        splashView = [[UIImageView alloc]
                           initWithFrame:CGRectMake(0,0,
						window.frame.size.height,
						window.frame.size.width)];
    }
    else {
        splashView = [[UIImageView alloc]
                           initWithFrame:CGRectMake(0,0,
							window.frame.size.width,
							window.frame.size.height)];
	}
	splashView.image = [UIImage imageNamed:[self launchImageNameForCurrentOrientation]];

	// Add the image to the view
	UIViewController *navController = window.rootViewController;
    [navController.view addSubview:splashView];
    [navController.view bringSubviewToFront:splashView];

	// Perform the animation
	[UIView animateWithDuration:duration
					 animations:
	 ^{
		 splashView.alpha = 0.0;
		 splashView.frame =
		 CGRectMake(-60, -60, splashView.frame.size.width + 120,
					splashView.frame.size.height + 120);
	 }
					 completion:
	 ^(BOOL finished)
	 {
		 [splashView removeFromSuperview];
	 }
	 ];
}

+ (NSString *)launchImageNameForCurrentOrientation
{
	NSString *launchImage;
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
	{
		if (UIDeviceOrientationIsPortrait([self deviceOrientation])) {
			if ([self isRetinaDisplay]) {
				// iPad Retina - portrait
				launchImage = @"Default-Portrait@2x.png";
			}
			else {
				// iPad - portrait
				launchImage = @"Default-Portrait.png";
			}
		}
		else {
			if ([self isRetinaDisplay]) {
				// iPad Retina - landscape
				launchImage = @"Default-Landscape@2x.png";
			}
			else {
				// iPad - landscape
				launchImage = @"Default-Landscape.png";
			}
		}
	}
	else
	{
		// iPhone / iPod only support portrait orientation at startup
		if ([self isRetinaDisplay]) {

			if ([self is4InchDisplay]) {
				// iPhone / iPod 4-inch Retina - portrait
				launchImage = @"Default-568h@2x.png";
			}
			else
			{
				// iPhone / iPod 3.5 inch Retina - portrait
				launchImage = @"Default@2x.png";
			}
			
		}
		else {
			// iPhone / iPod 3.5 inch - portrait
			launchImage = @"Default.png";
		}
	}

	return launchImage;
}

+ (BOOL)isOrientationLandscape
{
	return UIDeviceOrientationIsLandscape([self deviceOrientation]);
}

// Returns the correct image for the current device orientation
// based on the image names passed to the method
+ (NSString *)getImageNameByOrientationForiPhonePortrait:(NSString *)iPhonePortrait
										 iPhoneLandscape:(NSString *)iPhoneLandscape
									iPhoneRetinaPortrait:(NSString *)iPhoneRetinaPortrait
								   iPhoneRetinaLandscape:(NSString *)iPhoneRetinaLandscape
											iPadPortrait:(NSString *)iPadPortrait
										   iPadLandscape:(NSString *)iPadLandscape
{
	NSString *imageName;

	UIInterfaceOrientation orientation = [mmDevice deviceOrientation];

    if(UIDeviceOrientationIsLandscape(orientation)) {
		if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
		{
			imageName = iPadLandscape;
		}
		else
		{
			if([[UIScreen mainScreen] respondsToSelector:@selector(scale)] &&
               [[UIScreen mainScreen] scale] == 2.0)
			{
				imageName = iPhoneRetinaLandscape;
			}
			else
			{
				imageName = iPhoneLandscape;
			}
		}
    }
    else {
        if([self isiPad])
        {
            imageName = iPadPortrait;
        }
        else {
            if([[UIScreen mainScreen] respondsToSelector:@selector(scale)] &&
               [[UIScreen mainScreen] scale] == 2.0)
			{
                imageName = iPhoneRetinaPortrait;
            }
            else {
                imageName = iPhonePortrait;
            }
        }
    }
	return imageName;
}

+ (BOOL)isiPad
{
	return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
}

+ (BOOL)isiPhone
{
	return [[[UIDevice currentDevice] model] isEqualToString:@"iPhone"];
}

+ (BOOL)isiPod
{
	return [[[UIDevice currentDevice] model] isEqualToString:@"iPod touch"];
}

+ (BOOL)isRetinaDisplay
{
	return ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] &&
			  [[UIScreen mainScreen] scale] == 2.0);
}

+ (BOOL)is4InchDisplay
{
	return [UIScreen mainScreen].bounds.size.height == 568;
}

@end
