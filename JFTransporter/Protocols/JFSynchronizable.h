//
//  JFDataSynchronizable.h
//  JFTransporter
//
//  Created by Jeremy Fox on 1/13/15.
//  Copyright (c) 2015 Jeremy Fox. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol JFSynchronizable <NSObject>

@required

#pragma mark ----------------------
#pragma mark Data Synchronization
#pragma mark ----------------------

/**
 * @return Used to tell JFTransporter which model attribute should be used to determine the synchronization status (insert, update, delete). In most cases this should be an attribute representing the last time the model was updated. (Ex. updatedAt)
 */
+ (NSString*)managedObjectSyncDateAttribute;

/**
 * @return Used to tell JFTransporter which response object key should be used to get the Date representing the last time the object was updated.
 */
+ (NSString*)responseObjectSyncDateKey;

/**
 * @return Used to format the date string from an API response into a valid NSDate object.
 */
+ (NSString*)responseObjectSyncDateFormat;

+ (NSString*)syncPredicateFormat;

+ (NSDictionary*)syncPredicateValueIdentifiers;

@optional

+ (NSDictionary*)relationshipKeyPaths;

@end
