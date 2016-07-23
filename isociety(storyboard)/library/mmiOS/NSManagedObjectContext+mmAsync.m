//
//  NSManagedObjectContext+mmFetchAsync.m
//  Locations2
//
//  Created by Kevin McNeish on 2/28/14.
//
//

#import "NSManagedObjectContext+mmAsync.h"

@implementation NSManagedObjectContext (mmAsync)

- (void)executeFetchRequestAsync:(NSFetchRequest *)request completionHandler:(void (^)(NSMutableArray *entities, NSError *error))completionHandler
{
    // Create a background object context. Specifying NSPrivateQueueConcurrencyType
    // causes the object context to operate on a background thread.
    NSManagedObjectContext *backgroundContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    
    // performBlock executes code on the background context's private dispatch queue
    [backgroundContext performBlock:^{
        
        // Share the persistent store coordinator
        backgroundContext.persistentStoreCoordinator = self.persistentStoreCoordinator;
        
        NSError *error = nil;
        NSArray *fetchedEntities = [backgroundContext executeFetchRequest:request error:&error];
        
        [self performBlock:^{
            if (fetchedEntities) {
                
                // Get the IDs of the fetched entities and store them in the entityObjectIDs array
                NSMutableArray *entityObjectIds = [[NSMutableArray alloc] initWithCapacity:[fetchedEntities count]];
                for (NSManagedObject *entity in fetchedEntities) {
                    [entityObjectIds addObject:entity.objectID];
                }
                
                // Iterate through the entity object IDs, and tell the object context on the main thread
                // to retrieve them from the shared persistent store coordinator
                NSMutableArray *entityObjects = [[NSMutableArray alloc] initWithCapacity:[entityObjectIds count]];
                for (NSManagedObjectID *entityObjectID in entityObjectIds) {
                    NSManagedObject *entityObject = [self objectWithID:entityObjectID];
                    [entityObjects addObject:entityObject];
                }
                
                // Call the completion handler if there is one
                if (completionHandler) {
                    completionHandler(entityObjects, nil);
                }
            }
            else
            {
                if (completionHandler)
                {
                    completionHandler(nil, error);
                }
            }
        }];
    }];
}

- (void)saveAsync: (void (^)(NSError *error))completionHandler
{
    // Create a background object context. Specifying NSPrivateQueueConcurrencyType
    // causes the object context to operate on a background thread.
    NSManagedObjectContext *backgroundContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    
    // Register for a save notification from the
    [[NSNotificationCenter defaultCenter] addObserverForName:NSManagedObjectContextDidSaveNotification object:backgroundContext queue:nil usingBlock:^(NSNotification *note) {
        
        // Unregister for the notification
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:NSManagedObjectContextDidSaveNotification
                                                      object:backgroundContext];
        
        // Merge the changes from the background context
        [self mergeChangesFromContextDidSaveNotification:note];
    }];
    
    // performBlock executes code on the background context's private dispatch queue
    [backgroundContext performBlock:^{
        
        // Share the persistent store coordinator
        backgroundContext.persistentStoreCoordinator = self.persistentStoreCoordinator;;
        
        NSError *error = nil;
        if ([backgroundContext hasChanges] && ![backgroundContext save:&error]) {
			// Replace this implementation with code to handle the error appropriately.
			// abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }];
}

@end
