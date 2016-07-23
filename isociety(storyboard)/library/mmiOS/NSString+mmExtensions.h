//
//  NSString+mmExtensions.h
//  TheDime
//
//  Created by Kevin McNeish on 5/30/14.
//  Copyright (c) 2014 Anonoymous - ICN. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (mmExtensions)

// Trims all whitespace characters from the string
- (NSString *)trimWhitespaceCharactersInString;

// Returns a currency string representation of the specified decimal number
+ (NSString *)currencyStringFromDecimalNumber:(NSNumber *)decimalNumber;

// URL-encodes the specified string
- (NSString *)urlEncodeString;

@end
