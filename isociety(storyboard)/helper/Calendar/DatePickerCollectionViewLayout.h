//
//  DatePickerCollectionViewLayout.h
//  Seik
//
//  Created by Gavin on 10/26/14.
//  Copyright (c) 2014 Seik, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DatePickerCollectionViewLayout : UICollectionViewFlowLayout

- (CGSize)selfHeaderReferenceSize;
- (CGSize)selfItemSize;
- (CGFloat)selfMinimumLineSpacing;
- (CGFloat)selfMinimumInteritemSpacing;

@end
