//
//  Localization.m
//  Seik
//
//  Created by Gavin on 10/26/14.
//  Copyright (c) 2014 Seik, Inc. All rights reserved.
//


#import "Localization.h"

#define LocalizedLog(fmt, ...) NSLog((@"Localization: " fmt), ##__VA_ARGS__);


@implementation Localization

@synthesize localizedStrings;
@synthesize activeLanguage;

+ (id)sharedInstance {
    // Create a singleton instance of the class
    static Localization *sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}


- (void)setLanguage:(NSString *)languageName {
    self.activeLanguage = languageName;
    NSString *path = [[NSBundle mainBundle] pathForResource:languageName
                                                     ofType:@"txt"];
    NSString *content = [NSString stringWithContentsOfFile:path
                                                  usedEncoding:NULL
                                                     error:NULL];
    
    NSArray *keysAndValuesArray = [content componentsSeparatedByString:@"\r"];
    NSMutableDictionary *tempLocalizedstrings = [[NSMutableDictionary alloc] init];
    
    for (NSString *keyAndValue in keysAndValuesArray) {
        NSArray * separatedKeyAndValue = [keyAndValue componentsSeparatedByString:@"\""];
        
        @try {
            NSString *key = [separatedKeyAndValue objectAtIndex:1];
            NSString *value = [separatedKeyAndValue objectAtIndex:3];
            
            [tempLocalizedstrings setObject:value forKey:[key uppercaseString]];
        }
        @catch (NSException *exception) {
            LocalizedLog(@"Encountered Incorrect Format While Reading %@ Localization File: %@", languageName, exception.description);
        }
        
    }
    
    self.localizedStrings = [tempLocalizedstrings mutableCopy];
}


- (NSString *)localizedStringForKey:(NSString *)key {
    if (!self.activeLanguage) {
        LocalizedLog(@"No Language Selected");
    }
    
    NSString *valueForKey = [self.localizedStrings objectForKey:[key uppercaseString]];
    
    if (valueForKey)
        return valueForKey;
    else
        return key;
}


- (void)setActiveLanguage:(NSString *)activeLang
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSArray *ll = [NSArray arrayWithObject:activeLang];
    [ll writeToFile:[NSString stringWithFormat:@"%@/ActiveLanguage", documentsDirectory] atomically:YES];
    
    activeLanguage = activeLang;
}

- (NSString *)activeLanguage
{
    if (activeLanguage == nil) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        
        NSArray *ll = [NSArray arrayWithContentsOfFile:[NSString stringWithFormat:@"%@/ActiveLanguage", documentsDirectory]];
        activeLanguage = [ll firstObject];
    }
    
    return activeLanguage;
}




@end
