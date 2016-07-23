//
//  PostCommentObject.h
//  Seik
//
//  Created by Gavin on 10/26/14.
//  Copyright (c) 2014 Seik, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

typedef void (^ResultBlock) (NSArray* objects, NSError* error) ;

@interface PostCommentObject : NSObject

//Static Methods
+ (void) getCommentsForUser:(PFUser*)user onDone: (ResultBlock) finishBlock;
+ (void)deleteCommentWithCommentObject:(PFObject*)commentObject;
+ (void)flagCommentWithCommentObject:(PFObject*)commentObject;

@end
