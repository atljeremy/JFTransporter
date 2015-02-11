//
//  JFDataManager.h
//  JFTransporter
//
//  Created by Jeremy Fox on 1/9/15.
//  Copyright (c) 2015 Jeremy Fox. All rights reserved.
//

@import Foundation;
@import CoreData;
#import "JFTransportable.h"

@interface JFDataManager : NSObject

+ (instancetype)sharedManager;
- (void)setParentContext:(NSManagedObjectContext*)parentContext;

- (NSManagedObject<JFTransportable>*)existingObjectWithPredicateFormat:(NSString*)predicateFormat forEntityName:(NSString*)entityName;
- (NSManagedObject<JFTransportable>*)existingObjectWithPredicateFormat:(NSString*)predicateFormat forEntityName:(NSString*)entityName inMOC:(NSManagedObjectContext*)moc;
- (NSManagedObject<JFTransportable>*)insertNewObjectForEntityForName:(NSString*)entityName;
- (NSManagedObject<JFTransportable>*)insertNewObjectForEntityForName:(NSString*)entityName inMOC:(NSManagedObjectContext*)moc;
- (void)deleteObject:(NSManagedObject<JFTransportable>*)object;
- (BOOL)saveContextWithError:(NSError**)error_p;

@end
