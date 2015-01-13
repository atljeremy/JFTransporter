//
//  JFDataSynchronizable.h
//  JFTransporter
//
//  Created by Jeremy Fox on 1/13/15.
//  Copyright (c) 2015 Jeremy Fox. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol JFDataSynchronizable <NSObject>

@required

#pragma mark ----------------------
#pragma mark Data Synchronization
#pragma mark ----------------------

/**
 * @return Used to tell JFTransporter that this object should be syncchronized. This mean that the -syncAttribute method will be used to determine which model attribute should be used to perform the sync.
 */
+ (BOOL)shouldSync;

/**
 * @return Used to tell JFTransporter which model attribute should be used to determine the synchronization status (insert, update, delete). In most cases this should be an attribute representing the last time the model was updated. (Ex. updatedAt)
 */
+ (NSString*)managedObjectSyncDateAttribute;

/**
 * @return Used to tell JFTransporter what model addtribute to use to determine unique models. This could be an NSNumber attribute named "identifier" that has a value of the database ID in your remote API.
 */
+ (NSString*)managedObjectSyncIdentifierAttribute;

/**
 * @return Used to tell JFTransporter which response object key should be used to get the Date representing the last time the object was updated.
 */
+ (NSString*)responseObjectSyncDateKey;

/**
 * @return Used to format the date string from an API response into a valid NSDate object.
 */
+ (NSString*)responseObjectSyncDateFormat;

/**
 * @return Used to tell JFTransporter what response key to use to determine unique models.
 */
+ (NSString*)responseObjectSyncIdentifierKey;

@end
