//
//  CustomDatePickerCollectionViewLayout.m
//  Seik
//
//  Created by Gavin on 10/26/14.
//  Copyright (c) 2014 Seik, Inc. All rights reserved.
//

#import "CustomDatePickerCollectionViewLayout.h"

@implementation CustomDatePickerCollectionViewLayout
#pragma mark - Layout Atrributes

- (CGSize)selfHeaderReferenceSize
{
    return (CGSize){ [super selfHeaderReferenceSize].width, 54 };
}

- (CGSize)selfItemSize
{
    return (CGSize){ [super selfItemSize].width, 60 };
}

@end
