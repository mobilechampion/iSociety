//
//  CommentsViewController.h
//  Seik
//
//  Created by Gavin on 10/26/14.
//  Copyright (c) 2014 Seik, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "Localization.h"

@interface CommentsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>{
    IBOutlet UITableView *commentsTblView;
    IBOutlet UITextField *txtField;
    IBOutlet UIButton *sendButton;
}

@property (nonatomic, retain) NSMutableArray *commentsList;
@property (nonatomic, retain) PFObject *postObject;

@end
