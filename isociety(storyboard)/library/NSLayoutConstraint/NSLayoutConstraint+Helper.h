//
//  NSLayoutConstraint+Helper.h
//  SportsApp
//
//  Created by sergeyZ on 17.06.15.
//
//

#import <UIKit/UIKit.h>

@interface NSLayoutConstraint (Helper)

+ (NSLayoutConstraint*) setWidht:(CGFloat)w forView:(UIView*)view;
+ (NSLayoutConstraint*) setHeight:(CGFloat)w forView:(UIView*)view;
+ (void) setWidht:(CGFloat)w height:(CGFloat)h forView:(UIView*)view;
+ (NSLayoutConstraint *) centerHorizontal:(UIView*)view withView:(UIView*)anchorView inContainer:(UIView*)container;
+ (NSLayoutConstraint *) centerVertical:(UIView*)view withView:(UIView*)anchorView inContainer:(UIView*)container;

+ (void) stretch:(UIView*)view inContainer:(UIView*)container withPadding:(CGFloat)padding;
+ (void) stretchHorizontal:(UIView*)view inContainer:(UIView*)container withPadding:(CGFloat)padding;
+ (void) stretchVertical:(UIView*)view inContainer:(UIView*)container withPadding:(CGFloat)padding;

+ (NSLayoutConstraint *) setTopPadding:(CGFloat)padding forView:(UIView*)view inContainer:(UIView*)container;
+ (NSLayoutConstraint *) setBottomPadding:(CGFloat)padding forView:(UIView*)view inContainer:(UIView*)container;
+ (NSLayoutConstraint *) setLeftPadding:(CGFloat)padding forView:(UIView*)view inContainer:(UIView*)container;
+ (NSLayoutConstraint *) setRightPadding:(CGFloat)padding forView:(UIView*)view inContainer:(UIView*)container;

@end
