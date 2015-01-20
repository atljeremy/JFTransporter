//
//  JFDataManager.m
//  JFTransporter
//
//  Created by Jeremy Fox on 1/9/15.
//  Copyright (c) 2015 Jeremy Fox. All rights reserved.
//

#import "JFDataManager.h"
#import "JFTransportable.h"
#import "JFSynchronizable.h"

@interface JFDataManager ()
@property (nonatomic, strong) NSManagedObjectContext* context;
@end

@implementation JFDataManager

+ (instancetype)sharedManager
{
    static JFDataManager* sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

#pragma mark ----------------------
#pragma mark NSManagedObjectContext
#pragma mark ----------------------

- (void)setManagedObjectContext:(NSManagedObjectContext*)context
{
    self.context = context;
}

- (BOOL)saveContextWithError:(NSError**)error_p
{
    NSAssert(self.context, @"Must provide an NSManagedObjectContext using -setManagedObjectContext");
    __block BOOL saved = NO;
    BOOL hasChanges = [self.context hasChanges];
    if (hasChanges) {
        [self.context performBlockAndWait:^{
            saved = [self.context save:error_p];
            
            NSManagedObjectContext* ancestorContext = self.context.parentContext;
            while (ancestorContext) {
                [ancestorContext performBlockAndWait:^{
                    [ancestorContext save:error_p];
                }];
                ancestorContext = ancestorContext.parentContext;
            }
        }];
    }
    
    if (!saved) {
        NSLog(@"Failed to save context with error: %@", [*error_p localizedDescription]);
    }
    
    return saved;
}

#pragma mark ----------------------
#pragma mark CRUD
#pragma mark ----------------------

- (NSManagedObject<JFTransportable>*)existingObjectWithPredicateFormat:(NSString*)predicateFormat forEntityName:(NSString*)entityName
{
    NSAssert(self.context, @"Must provide an NSManagedObjectContext using -setManagedObjectContext");
    __block NSManagedObject<JFTransportable>* object;
    [self.context performBlockAndWait:^{
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:self.context];
        [fetchRequest setEntity:entity];

        NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateFormat];
        [fetchRequest setPredicate:predicate];
        
        fetchRequest.fetchBatchSize = 1;
        fetchRequest.fetchLimit = 1;
        
        NSArray *fetchedObjects = [self.context executeFetchRequest:fetchRequest error:nil];
        if (fetchedObjects.count == 1) {
            object = fetchedObjects.firstObject;
        }
    }];
    
    return object;
}

- (NSManagedObject<JFTransportable>*)insertNewObjectForEntityForName:(NSString*)entityName
{
    NSAssert(self.context, @"Must provide an NSManagedObjectContext using -setManagedObjectContext");
    return [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:self.context];
}

- (void)deleteObject:(NSManagedObject<JFTransportable>*)object
{
    NSAssert(self.context, @"Must provide an NSManagedObjectContext using -setManagedObjectContext");
    [self.context performBlock:^{
        [self.context deleteObject:object];
    }];
}

@end
