//
//  PostCell.m
//  Seik
//
//  Created by Gavin on 10/26/14.
//  Copyright (c) 2014 Seik, Inc. All rights reserved.
//

#import "CommentCell.h"
#import "Constant.h"
#import "PostCommentObject.h"



@implementation CommentCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    for (UIView *subview in self.contentView.superview.subviews) {
        if ([NSStringFromClass(subview.class) hasSuffix:@"SeparatorView"]) {
            subview.hidden = NO;
        }
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (IBAction) actionDeleteCommentButton:(UIButton*)sender
{
    [PostCommentObject deleteCommentWithCommentObject:self.currentCommentParseObject];
    
}

// any user can flag a comment
- (IBAction) actionFlagCommentButton:(UIButton*)sender
{
    [PostCommentObject flagCommentWithCommentObject:self.currentCommentParseObject];
    
}

@end