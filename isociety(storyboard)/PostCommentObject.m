//
//  PostCommentObject.m
//  Seik
//
//  Created by Gavin on 10/26/14.
//  Copyright (c) 2014 Seik, Inc. All rights reserved.
//

#import "PostCommentObject.h"
#import "Constant.h"
#import "BATUtil.h"


@implementation PostCommentObject

+ (void) getCommentsForUser:(PFUser*)user onDone: (ResultBlock) finishBlock {
    PFQuery* postComments = [PFQuery queryWithClassName:@"APostCommentTable"];
    [postComments whereKey:@"commentUser" equalTo:user];
    [postComments whereKey:@"StatusCommenr" equalTo:@"1"];
    [postComments findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(objects && objects.count > 0) {
            NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:NO];
            finishBlock([objects sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]], error);
        } else {
            finishBlock(nil, error);
        }
        
    }];
}

+ (void)deleteCommentWithCommentObject:(PFObject*)commentObject{
    
    PFUser *user = [PFUser currentUser];
    
    PFUser *tempUser = commentObject[@"commentUser"];
    
    // just an extra objectID comparison check
    if ([tempUser.objectId isEqualToString:user.objectId]) {
        [commentObject deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded)
            {
                PFQuery *query2 = [PFQuery queryWithClassName:@"AnonymousPost"];
                
                PFObject *post = commentObject[@"postId"];
                //    // Retrieve the object by id
                [query2 getObjectInBackgroundWithId:post.objectId block:^(PFObject *postObject, NSError *error)
                 {
                     
                     postObject[@"commentCount"] = @([postObject[@"commentCount"] intValue]-1);
                     
                     [postObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                         
                         if (succeeded)
                         {
                             NSLog(@"Comment deleted");
                             [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_LOAD_COMMENTS object:nil userInfo:nil];
                         }
                         
                         else
                         {
                             [BATUtil showAlertWithMessage:@"Comment could not be deleted, please try again." title:@"Oops!"];
                         }
                         
                     }];
                     
                 }];
                
                
            }
        }];
    }
}


+ (void)flagCommentWithCommentObject:(PFObject*)commentObject{
    
    PFQuery *query2 = [PFQuery queryWithClassName:@"APostCommentTable"];
    //    // Retrieve the object by id
    [query2 getObjectInBackgroundWithId:commentObject.objectId block:^(PFObject *commentObject, NSError *error) {
        
        
        commentObject[@"flagged"] = @"Y";
        [commentObject incrementKey:@"flagCount"];
        
        [commentObject addUniqueObjectsFromArray:@[[PFUser currentUser].objectId] forKey:@"flaggedByUsers"];
        
        [commentObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded)
            {
                //[flagView setHidden:YES];
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_LOAD_COMMENTS object:nil userInfo:nil];
            }
            
            else
            {
                [BATUtil showAlertWithMessage:@"Comment could not be flagged, please try again." title:@"Oops!"];
                
            }
        }];
    }];
    
}


@end
