//
//  mmUtils.m
//  MMiOS
//
//  Created by Kevin McNeish on 5/23/14.
//  Copyright (c) 2014 Oak Leaf Enterprises, Inc. All rights reserved.
//

#import "mmUtils.h"

@implementation mmUtils

+ (BOOL)isEmailValid:(NSString *)emailAddress;
{
    BOOL stricterFilter = YES; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:emailAddress];
}

@end
