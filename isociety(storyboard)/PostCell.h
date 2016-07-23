//
//  PostCell.h
//  Seik
//
//  Created by Gavin on 10/26/14.
//  Copyright (c) 2014 Seik, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PBJVideoPlayerController.h"

#import "DraggableView.h"

@interface PostCell : UITableViewCell<DraggableViewDelegate>

@property (nonatomic, retain) PBJVideoPlayerController *_videoPlayerController;
@property (nonatomic, retain) UIImageView *imgView;
@property (nonatomic, retain) UIImageView *_playButton;

@property (nonatomic, retain) IBOutlet UILabel *timeLabel, *numVotesLabel, *colorLabel, *headlineLabel;
@property (nonatomic, retain) IBOutlet UIButton *playButton, *downVoteButton, *upVoteButton, *commentsButton, *flagButton, *deleteButton;
@property(nonatomic, retain) IBOutlet UIView *viewBottomCell;






@end
