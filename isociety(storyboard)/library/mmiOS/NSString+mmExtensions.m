//
//  NSString+mmExtensions.m
//  TheDime
//
//  Created by Kevin McNeish on 5/30/14.
//  Copyright (c) 2014 Anonoymous - ICN. All rights reserved.
//

#import "NSString+mmExtensions.h"

@implementation NSString (mmExtensions)

- (NSString *)trimWhitespaceCharactersInString
{
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

+ (NSString *)currencyStringFromDecimalNumber:(NSNumber *)decimalNumber
{
    NSString *currency;
    
    if ([decimalNumber isEqualToNumber: [NSDecimalNumber notANumber]]) {
        currency = @"$.00";
    }
    else
    {
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setNumberStyle: NSNumberFormatterCurrencyStyle];
        currency = [numberFormatter stringFromNumber:decimalNumber];
    }
    
    return currency;
}

- (NSString *)urlEncodeString
{
    return [self stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
}

@end
