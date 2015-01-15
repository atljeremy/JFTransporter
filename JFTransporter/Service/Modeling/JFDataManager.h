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
- (void)setManagedObjectContext:(NSManagedObjectContext*)context;

- (NSManagedObject<JFTransportable>*)existingObjectWithAttribute:(NSString*)attribute matchingValue:(id)value forEntityName:(NSString*)entityName;
- (NSManagedObject<JFTransportable>*)existingObjectWithPredicate:(NSPredicate*)predicate forEntityName:(NSString*)entityName;
- (NSManagedObject<JFTransportable>*)insertNewObjectForEntityForName:(NSString*)entityName;
- (void)deleteObject:(NSManagedObject<JFTransportable>*)object;
- (BOOL)saveContextWithError:(NSError**)error_p;

@end
