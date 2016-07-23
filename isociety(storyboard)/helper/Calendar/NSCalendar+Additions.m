//
//  NSCalendar+Additions.m
//  Seik
//
//  Created by Gavin on 10/26/14.
//  Copyright (c) 2014 Seik, Inc. All rights reserved.
//


#import "NSCalendar+Additions.h"

@implementation NSCalendar (Additions)
- (NSDateFormatter *)df_dateFormatterNamed:(NSString *)name withConstructor:(NSDateFormatter *(^)(void))block
{
    NSMutableDictionary *threadDictionary = [[NSThread currentThread] threadDictionary];
    NSDateFormatter *dateFormatter = threadDictionary[name];
    
    if (!dateFormatter) {
        dateFormatter = block();
        threadDictionary[name] = dateFormatter;
    }
    
    return dateFormatter;
}
@end
