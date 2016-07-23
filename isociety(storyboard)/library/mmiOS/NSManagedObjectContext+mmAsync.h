//
//  NSManagedObjectContext+mmFetchAsync.h
//  Locations2
//
//  Created by Kevin McNeish on 2/28/14.
//
//

#import <CoreData/CoreData.h>

@interface NSManagedObjectContext (mmAsync)

// Fetches the requested entities on a background thread
- (void)executeFetchRequestAsync:(NSFetchRequest *)request completionHandler:(void (^)(NSMutableArray *entities, NSError *error))completionHandler;

- (void)saveAsync: (void (^)(NSError *error))completionHandler;

@end
