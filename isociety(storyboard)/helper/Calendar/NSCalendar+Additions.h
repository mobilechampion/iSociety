//
//  NSCalendar+Additions.h
//  Seik
//
//  Created by Gavin on 10/26/14.
//  Copyright (c) 2014 Seik, Inc. All rights reserved.
//


#import <Foundation/Foundation.h>

@interface NSCalendar (Additions)

- (NSDateFormatter *)df_dateFormatterNamed:(NSString *)name withConstructor:(NSDateFormatter *(^)(void))block;

@end
