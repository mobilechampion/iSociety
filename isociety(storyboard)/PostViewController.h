//
//  PostViewController.h
//  Seik
//
//  Created by Gavin on 10/26/14.
//  Copyright (c) 2014 Seik, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DraggableView.h"
#import "PBJVideoPlayerController.h"
#import <Parse/Parse.h>


@interface PostViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UITextViewDelegate, PBJVideoPlayerControllerDelegate, UIGestureRecognizerDelegate,UIScrollViewDelegate>{
    long sec, min, hour, day;
    
    IBOutlet UITableView *feedsTableView;
    IBOutlet UISwitch *blockSwitch;
    IBOutlet UIView *flagView;
    IBOutlet UIView *emptyCellView;
    
    
    
    
    NSInteger flagIndex;
    UIView *enlargedView;
    UIImageView *contentImgView;
    NSMutableArray *tableContentsList, *randomList;
    UISegmentedControl *postTypeSegment;
    
    CGRect oldertablefrm;
    int moveDirection;
    BOOL _isShowOwnerPost;
}

@property(nonatomic) BOOL IsStayAtPersonPost;

//@property (strong, nonatomic) UIView *flagView;
- (IBAction)Flag:(id)sender;
- (void) redirectToComment :(PFObject*)postObject;

@end
