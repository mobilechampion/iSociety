//
//  mmDevice.h
//  MMiOS
//
//  Created by Kevin McNeish 
//  Copyright (c) 2013 Oak Leaf Enterprises, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface mmDevice : NSObject{
	
}

// Returns the device orientation
+ (UIInterfaceOrientation)deviceOrientation;

// Animates the launch image.
// Assumes the standard launch image names and sizes:
// iPhone Portrait - Default.png (320 x 480)
// iPhone Retina Portrait - Default@2x.png (640 x 960)
// iPhone 4-inch - Default-568h@2x.png (640 x 1136)
// iPad Portrait - Default-Portrait.png (768 x 1004)
// iPad Retina Portrait - Default-Portrait@2x.png (1536 x 2008)
// iPad Landscape - Default-Landscape.png (1024 x 748)
// iPad Retina Landscape - Default-Landscape@2x.png (2048 x 1496)
+ (void)animateLaunchImageInWindow:(UIWindow *)window forDuration:(NSTimeInterval)duration;

// Returns the splash image name for the current device orientation
+ (NSString *)launchImageNameForCurrentOrientation;

// Returns true if the current device orientation is landscape, otherwise false
+ (BOOL)isOrientationLandscape;

// Returns true if the device is an iPhone, otherwise false
+ (BOOL)isiPhone;

// Returns true if the device is an iPad, otherwise false
+ (BOOL)isiPad;

// Returns true if the device is an iPod, otherwise false
+ (BOOL)isiPod;

// Returns true if the device has a retina display, otherwise false
+ (BOOL)isRetinaDisplay;

// Returns true if the device has a retina display, otherwise false
+ (BOOL)is4InchDisplay;

@end
