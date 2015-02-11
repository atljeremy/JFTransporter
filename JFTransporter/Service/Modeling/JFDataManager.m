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
@property (nonatomic, strong) NSManagedObjectContext* parentContext;
@property (nonatomic, strong) NSManagedObjectContext* privateContext;
- (NSManagedObjectContext*)privateContext;
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

- (void)setParentContext:(NSManagedObjectContext *)parentContext
{
    NSAssert(parentContext, @"Must provide an NSManagedObjectContext using -setParentContext");
    _parentContext = parentContext;
    _privateContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    _privateContext.parentContext = _parentContext;
}

- (NSManagedObjectContext*)privateContext
{
    NSAssert(_privateContext.parentContext, @"Must provide an NSManagedObjectContext using -setParentContext");
    return _privateContext;
}

- (BOOL)saveContextWithError:(NSError**)error_p
{
    __block BOOL saved = NO;
    BOOL hasChanges = [self.privateContext hasChanges];
    if (hasChanges) {
        [self.privateContext performBlockAndWait:^{
            saved = [self.privateContext save:error_p];
            
            NSManagedObjectContext* ancestorContext = self.privateContext.parentContext;
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
    __block NSManagedObject<JFTransportable>* object;
    [self.privateContext performBlockAndWait:^{
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:self.privateContext];
        [fetchRequest setEntity:entity];

        NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateFormat];
        [fetchRequest setPredicate:predicate];
        
        fetchRequest.fetchBatchSize = 1;
        fetchRequest.fetchLimit = 1;
        
        NSArray *fetchedObjects = [self.privateContext executeFetchRequest:fetchRequest error:nil];
        if (fetchedObjects.count == 1) {
            object = fetchedObjects.firstObject;
        }
    }];
    
    return object;
}

- (NSManagedObject<JFTransportable>*)insertNewObjectForEntityForName:(NSString*)entityName inMOC:(NSManagedObjectContext*)moc
{
    if (!moc) {
        moc = self.privateContext;
    }
    return [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:moc];
}

- (NSManagedObject<JFTransportable>*)insertNewObjectForEntityForName:(NSString*)entityName
{
    return [self insertNewObjectForEntityForName:entityName inMOC:self.privateContext];
}

- (void)deleteObject:(NSManagedObject<JFTransportable>*)object
{
    [self.privateContext performBlock:^{
        [self.privateContext deleteObject:object];
    }];
}

@end
