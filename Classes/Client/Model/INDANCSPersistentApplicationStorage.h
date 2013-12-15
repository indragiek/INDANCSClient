//
//  INDANCSPersistentApplicationStorage.h
//  INDANCSMac
//
//  Created by Indragie Karunaratne on 12/14/2013.
//  Copyright (c) 2013 Indragie Karunaratne. All rights reserved.
//

#import <Foundation/Foundation.h>

@class INDANCSApplication;
typedef void (^INDANCSPersistentStorageFetchBlock)(INDANCSApplication *, NSError *);

@interface INDANCSPersistentApplicationStorage : NSObject

/**
 *  Asynchronously fetches or creates an `INDANCSApplication` instance
 *  for the specified bundle identifier. The information for the application
 *  is retrieved from persistent storage. 
 *
 *  Returns `nil` if no such application is in the persistent store.
 *
 *  @param bundleID The bundle identifier for which to create an `INDANCSPersistentApplication` instance
 *  @param block    Completion block.
 */
- (void)fetchApplicationForBundleID:(NSString *)bundleID completion:(INDANCSPersistentStorageFetchBlock)block;

@end
