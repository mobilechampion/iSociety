//
//  Localization.h
//  Seik
//
//  Created by Gavin on 10/26/14.
//  Copyright (c) 2014 Seik, Inc. All rights reserved.
//


#import <Foundation/Foundation.h>

@interface Localization : NSObject

// Return the shared instance of the framework that could be used anywhere in the app. setLanguage must be called
// the first time the shared instance is used to initialize it.
+ (id)sharedInstance;

// Initialize the framework with a certain language. Could also be used for changing language while the app is
// already running. languageName is the name of a text file in the app bundle.
- (void)setLanguage:(NSString *)languageName;

// Get the localized string for a key
- (NSString *)localizedStringForKey:(NSString *)key;


@property (nonatomic, strong) NSDictionary *localizedStrings;
@property (nonatomic, strong) NSString *activeLanguage;
@end
