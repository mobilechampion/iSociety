//
//  BATUtil.m
//  Seik
//
//  Created by Gavin on 10/26/14.
//  Copyright (c) 2014 Seik, Inc. All rights reserved.
//


#import "BATUtil.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "AppDelegate.h"

@implementation BATUtil
//-------------------------------------------------------------------------------------------------------------------------------------------------
BOOL ShouldStartPhotoLibrary(id object, BOOL canEdit)
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    if (([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary] == NO
         && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum] == NO)) return NO;
    //---------------------------------------------------------------------------------------------------------------------------------------------
    UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]
        && [[UIImagePickerController availableMediaTypesForSourceType:
             UIImagePickerControllerSourceTypePhotoLibrary] containsObject:(NSString *)kUTTypeImage])
    {
        cameraUI.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        cameraUI.mediaTypes = [NSArray arrayWithObject:(NSString *) kUTTypeImage];
    }
    else if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]
             && [[UIImagePickerController availableMediaTypesForSourceType:
                  UIImagePickerControllerSourceTypeSavedPhotosAlbum] containsObject:(NSString *)kUTTypeImage])
    {
        cameraUI.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        cameraUI.mediaTypes = [NSArray arrayWithObject:(NSString *) kUTTypeImage];
    }
    else return NO;
    
    cameraUI.allowsEditing = canEdit;
    cameraUI.delegate = object;
    
    [object presentViewController:cameraUI animated:YES completion:nil];
    
    return YES;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
void LoginUser(id target)
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
//    NavigationController *navigationController = [[NavigationController alloc] initWithRootViewController:[[WelcomeView alloc] init]];
//    [target presentViewController:navigationController animated:YES completion:nil];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
UIImage* ResizeImage(UIImage *image, CGFloat width, CGFloat height)
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    CGSize size = CGSizeMake(width, height);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
void PostNotification(NSString *notification)
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    [[NSNotificationCenter defaultCenter] postNotificationName:notification object:nil];
}



+ (UIColor *) colorFromHexString:(NSString *)hexString {
    
    NSString *colorString = [[hexString uppercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] ;
    if ([colorString hasPrefix:@"0X"])
    {
        if ([colorString length] < 6)
            return [UIColor grayColor];
        
        if ([colorString hasPrefix:@"0X"])
            colorString = [colorString substringFromIndex:2];
        else if ([colorString hasPrefix:@"#"])
            colorString = [colorString substringFromIndex:1];
        else if ([colorString length] != 6)
            return  [UIColor grayColor];
        
        NSRange range;
        range.location = 2;
        range.length = 2;
        NSString *rString = [colorString substringWithRange:range];
        range.location += 2;
        NSString *gString = [colorString substringWithRange:range];
        range.location += 2;
        NSString *bString = [colorString substringWithRange:range];
        
        unsigned int red, green, blue;
        [[NSScanner scannerWithString:rString] scanHexInt:&red];
        [[NSScanner scannerWithString:gString] scanHexInt:&green];
        [[NSScanner scannerWithString:bString] scanHexInt:&blue];
        
        return [UIColor colorWithRed:((float) red / 255.0f)
                               green:((float) green / 255.0f)
                                blue:((float) blue / 255.0f)
                               alpha:1.0f];
    }
    else{
        hexString = [hexString stringByReplacingOccurrencesOfString:@"#" withString:@""];
        if([hexString length] == 3) {
            hexString = [NSString stringWithFormat:@"%@%@%@%@%@%@",
                         [hexString substringWithRange:NSMakeRange(0, 1)],[hexString substringWithRange:NSMakeRange(0, 1)],
                         [hexString substringWithRange:NSMakeRange(1, 1)],[hexString substringWithRange:NSMakeRange(1, 1)],
                         [hexString substringWithRange:NSMakeRange(2, 1)],[hexString substringWithRange:NSMakeRange(2, 1)]];
        }
        if([hexString length] == 6) {
            hexString = [hexString stringByAppendingString:@"ff"];
        }
        
        unsigned int baseValue;
        [[NSScanner scannerWithString:hexString] scanHexInt:&baseValue];
        
        float red = ((baseValue >> 24) & 0xFF)/255.0f;
        float green = ((baseValue >> 16) & 0xFF)/255.0f;
        float blue = ((baseValue >> 8) & 0xFF)/255.0f;
        float alpha = ((baseValue >> 0) & 0xFF)/255.0f;
        
        return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
    }
}

+ (UIColor *) colorFromRGBString:(NSString *)rgbString {
    unsigned dec;
    
    NSString *redHex = [rgbString substringWithRange:NSMakeRange(0,3)];
    NSScanner *scan = [NSScanner scannerWithString:redHex];
    [scan scanHexInt:&dec];
    
    float red = ((float) dec)/255.0;
    
    NSString *greenHex = [rgbString substringWithRange:NSMakeRange(3,3)];
    scan = [NSScanner scannerWithString:greenHex];
    [scan scanHexInt:&dec];
    float green = ((float) dec)/255.0;
    
    NSString *blueHex = [rgbString substringWithRange:NSMakeRange(6,3)];
    scan = [NSScanner scannerWithString:blueHex];
    [scan scanHexInt:&dec];
    float blue = ((float) dec)/255.0;
    
    return [UIColor colorWithRed:red green:green blue:blue alpha:1.0];

}

+(void)showAlertWithMessage:(NSString *)strMessage title:(NSString *)title delegate:(id)delegate
{
    UIAlertController *alertView = [UIAlertController alertControllerWithTitle:title message:strMessage preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        // Do Nothing
    }];
    [alertView addAction:okAction];
    [delegate presentViewController:alertView animated:YES completion:nil];
}

+(void)showAlertWithMessage:(NSString *)strMessage title:(NSString *)title
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:strMessage
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}



+ (BOOL)validateEmailWithString:(NSString*)email
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

+(UILabel *)initLabelWithFrame:(CGRect)frame text:(NSString *)textStr textAlignment:(NSTextAlignment)textAlignment textColor:(UIColor *)textColor font:(UIFont *)font
{
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.text = textStr;
    // Customise Font , Text Color based on User
    label.textAlignment = textAlignment;
    label.textColor = textColor;
    label.font = font;
    label.backgroundColor = [UIColor clearColor];
    
    return label;
}

+(UIButton *)buttonWithFrame:(CGRect)frame backgroundColor:(NSString *)bgColor title:(NSString *)title delegate:(id)delegate selector:(SEL)selector
{
    UIButton *button =  [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = frame;
    button.backgroundColor = [BATUtil colorFromHexString:bgColor];
    [button setTitle:title forState:UIControlStateNormal];
    [button addTarget:delegate action:selector forControlEvents:UIControlEventTouchUpInside];

    return button;
}


@end
