//
//  NSLayoutConstraint+Helper.m
//  SportsApp
//
//  Created by sergeyZ on 17.06.15.
//
//

#import "NSLayoutConstraint+Helper.h"

@implementation NSLayoutConstraint (Helper)

+ (NSLayoutConstraint*) setWidht:(CGFloat)w forView:(UIView*)view {
    NSLayoutConstraint* constraint = [NSLayoutConstraint constraintWithItem:view
                                                                  attribute:NSLayoutAttributeWidth
                                                                  relatedBy:0
                                                                     toItem:nil
                                                                  attribute:0
                                                                 multiplier:1
                                                                   constant:w];
    [view addConstraint: constraint];
    return constraint;
}

+ (NSLayoutConstraint*) setHeight:(CGFloat)h forView:(UIView*)view {
    NSLayoutConstraint* constraint = [NSLayoutConstraint constraintWithItem:view
                                                                  attribute:NSLayoutAttributeHeight
                                                                  relatedBy:0
                                                                     toItem:nil
                                                                  attribute:0
                                                                 multiplier:1
                                                                   constant:h];
    
    [view addConstraint: constraint];
    return constraint;
}

+ (void) setWidht:(CGFloat)w height:(CGFloat)h forView:(UIView*)view {
    [view addConstraint: [NSLayoutConstraint constraintWithItem:view
                                                      attribute:NSLayoutAttributeWidth
                                                      relatedBy:0
                                                         toItem:nil
                                                      attribute:0
                                                     multiplier:1
                                                       constant:w]];
    
    [view addConstraint: [NSLayoutConstraint constraintWithItem:view
                                                      attribute:NSLayoutAttributeHeight
                                                      relatedBy:0
                                                         toItem:nil
                                                      attribute:0
                                                     multiplier:1
                                                       constant:h]];
}

#pragma mark -
#pragma mark align
+ (NSLayoutConstraint *) centerHorizontal:(UIView*)view withView:(UIView*)anchorView inContainer:(UIView*)container {
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:view
                                                                  attribute:NSLayoutAttributeCenterX
                                                                  relatedBy:0
                                                                     toItem:anchorView
                                                                  attribute:NSLayoutAttributeCenterX
                                                                 multiplier:1
                                                                   constant:0];
    [container addConstraint: constraint];
    return constraint;
}

+ (NSLayoutConstraint *) centerVertical:(UIView*)view withView:(UIView*)anchorView inContainer:(UIView*)container {
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:view
                                                                  attribute:NSLayoutAttributeCenterY
                                                                  relatedBy:0
                                                                     toItem:anchorView
                                                                  attribute:NSLayoutAttributeCenterY
                                                                 multiplier:1
                                                                   constant:0];
    [container addConstraint: constraint];
    return constraint;
}

#pragma mark -
#pragma mark stretch
+ (void) stretch:(UIView*)view inContainer:(UIView*)container withPadding:(CGFloat)padding {
    [NSLayoutConstraint stretchHorizontal:view inContainer:container withPadding:padding];
    [NSLayoutConstraint stretchVertical:view inContainer:container withPadding:padding];
}

+ (void) stretchHorizontal:(UIView*)view inContainer:(UIView*)container withPadding:(CGFloat)padding {
    [NSLayoutConstraint setLeftPadding:padding forView:view inContainer:container];
    [NSLayoutConstraint setRightPadding:padding forView:view inContainer:container];
}

+ (void) stretchVertical:(UIView*)view inContainer:(UIView*)container withPadding:(CGFloat)padding {
    [NSLayoutConstraint setTopPadding:padding forView:view inContainer:container];
    [NSLayoutConstraint setBottomPadding:padding forView:view inContainer:container];
}

#pragma mark -
#pragma mark Padding
+ (NSLayoutConstraint *) setTopPadding:(CGFloat)padding forView:(UIView*)view inContainer:(UIView*)container {
    NSLayoutConstraint* constraint = [NSLayoutConstraint constraintWithItem:view
                                                                  attribute:NSLayoutAttributeTop
                                                                  relatedBy:0
                                                                     toItem:container
                                                                  attribute:NSLayoutAttributeTop
                                                                 multiplier:1
                                                                   constant:padding];
    [container addConstraint: constraint];
    return constraint;
}

+ (NSLayoutConstraint *) setBottomPadding:(CGFloat)padding forView:(UIView*)view inContainer:(UIView*)container {
    NSLayoutConstraint* constraint = [NSLayoutConstraint constraintWithItem:view
                                                                  attribute:NSLayoutAttributeBottom
                                                                  relatedBy:0
                                                                     toItem:container
                                                                  attribute:NSLayoutAttributeBottom
                                                                 multiplier:1
                                                                   constant:-padding];
    [container addConstraint: constraint];
    return constraint;
}

+ (NSLayoutConstraint *) setLeftPadding:(CGFloat)padding forView:(UIView*)view inContainer:(UIView*)container {
    NSLayoutConstraint* constraint = [NSLayoutConstraint constraintWithItem:view
                                                                  attribute:NSLayoutAttributeLeft
                                                                  relatedBy:0
                                                                     toItem:container
                                                                  attribute:NSLayoutAttributeLeft
                                                                 multiplier:1
                                                                   constant:padding];
    [container addConstraint: constraint];
    return constraint;
}

+ (NSLayoutConstraint *) setRightPadding:(CGFloat)padding forView:(UIView*)view inContainer:(UIView*)container {
    NSLayoutConstraint* constraint = [NSLayoutConstraint constraintWithItem:view
                                                                  attribute:NSLayoutAttributeRight
                                                                  relatedBy:0
                                                                     toItem:container
                                                                  attribute:NSLayoutAttributeRight
                                                                 multiplier:1
                                                                   constant:-padding];
    [container addConstraint: constraint];
    return constraint;
}

@end
