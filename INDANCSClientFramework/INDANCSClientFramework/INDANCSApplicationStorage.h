//
//  INDANCSApplicationStorage.h
//  INDANCSMac
//
//  Created by Indragie Karunaratne on 12/15/2013.
//  Copyright (c) 2013 Indragie Karunaratne. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "INDANCSKeyValueStore.h"

@class INDANCSApplication;
@class INDANCSDevice;
/**
 *  Stores application metadata.
 */
@interface INDANCSApplicationStorage : NSObject
/**
 *  Key value store containing application metadata (name, bundle identifier, etc.).
 */
@property (nonatomic, strong, readonly) id<INDANCSKeyValueStore> metadataStore;

#pragma mark - Initialization

/**
 *  Creates a new instance of `INDANCSApplicationStorage`.
 *
 *  @param metadata  Key value store used to store application metadata.
 *
 *  @return A new instance of `INDANCSApplicationStorage`
 */
- (id)initWithMetadataStore:(id<INDANCSKeyValueStore>)metadata;

#pragma mark - Metadata

/**
 *  Returns the `INDANCSApplication` instance for a specified bundle identifier.
 *
 *  @param identifier Application bundle identifier.
 *
 *  @return The `INDANCSApplication` instance for the specified bundle identifier.
 */
- (INDANCSApplication *)applicationForBundleIdentifier:(NSString *)identifier;

/**
 *  Set a new `INDANCSApplication` instance for a bundle identifier, overwriting
 *  any existing data.
 *
 *  @param application The `INDANCSApplication` instance.
 *  @param identifier  The application bundle identifier.
 */
- (void)setApplication:(INDANCSApplication *)application forBundleIdentifier:(NSString *)identifier;

@end
