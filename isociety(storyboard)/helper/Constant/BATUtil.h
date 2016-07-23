//
//  BATUtil.h
//  Seik
//
//  Created by Gavin on 10/26/14.
//  Copyright (c) 2014 Seik, Inc. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef enum NSInteger {
    kStatusOffline = 0,
    kStatusAvailable = 1,
    kStatusIdle = 2,
    kStatusBusy = 3
} PersonStatus;


@interface BATUtil : NSObject

BOOL		ShouldStartPhotoLibrary		(id object, BOOL canEdit);

void		LoginUser					(id target);

UIImage*	ResizeImage					(UIImage *image, CGFloat width, CGFloat height);

void		PostNotification			(NSString *notification);

+ (BOOL)validateEmailWithString:(NSString*)email;
+ (UIColor *) colorFromHexString:(NSString *)hexString;
+ (UIColor *) colorFromRGBString:(NSString *)rgbString;
+(void)showAlertWithMessage:(NSString *)strMessage title:(NSString *)title delegate:(id)delegate;
+(void)showAlertWithMessage:(NSString *)strMessage title:(NSString *)title;




+(UILabel *)initLabelWithFrame:(CGRect)frame text:(NSString *)textStr textAlignment:(NSTextAlignment)textAlignment textColor:(UIColor *)textColor font:(UIFont *)font;
+(UIButton *)buttonWithFrame:(CGRect)frame backgroundColor:(NSString *)bgColor title:(NSString *)title delegate:(id)delegate selector:(SEL)selector;


@end
