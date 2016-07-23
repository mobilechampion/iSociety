//
//  mmSaveEntityResult.h
//  MMiOS
//
//  Created by Kevin McNeish on 7/3/14.
//  Copyright (c) 2014 Oak Leaf Enterprises, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
	SaveStateError,
	SaveStateRulesBroken,
	SaveStateSaveComplete,
	SaveStateRulesWarnings,
} mmSaveState;

@interface mmSaveEntityResult : NSObject

@property (assign, nonatomic) mmSaveState saveState;
@property (strong, nonatomic) NSError *error;
@property (strong, nonatomic) NSString *brokenRulesMessage;

@end
