//
//  RecordAdViewController.h
//  TheDime
//
//  Created by Kevin McNeish on 6/20/14.
//  Copyright (c) 2014 Anonoymous - ICN. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PBJVision.h"
#import "ReviewVideoViewController.h"
#import "AddNewPostViewController.h"

@interface RecordAdViewController : UIViewController <RetakeVideoDelegate>

@property (strong, nonatomic) NSString *videoPath;
@property id<GetVideoPath> delegate;

- (void)visionSessionDidStop:(PBJVision *)vision;
- (void)vision:(PBJVision *)vision capturedVideo:(NSDictionary *)videoDict error:(NSError *)error;
- (void)resetCapture;
- (void)endCapture;
- (IBAction)close:(id)sender;

@end
