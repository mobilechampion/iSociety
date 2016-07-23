//
//  PostCell.h
//  Seik
//
//  Created by Gavin on 10/26/14.
//  Copyright (c) 2014 Seik, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface CommentCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UILabel *descLabel, *colorLabel;
@property (nonatomic, retain) IBOutlet UIButton *buttonDeleteComment;
@property (nonatomic, retain) IBOutlet UIButton *buttonFlagComment;
@property (nonatomic, retain) IBOutlet UILabel *flagCountLabel;
@property (nonatomic, retain) PFObject *currentCommentParseObject;





@end
