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
 *  Stores application metadata and blacklist.
 */
@interface INDANCSApplicationStorage : NSObject
/**
 *  Key value store containing application metadata (name, bundle identifier, etc.).
 */
@property (nonatomic, strong, readonly) id<INDANCSKeyValueStore> metadataStore;

/**
 *  Key value store containing blacklisting preferences for applications & devices.
 */
@property (nonatomic, strong, readonly) id<INDANCSKeyValueStore> blacklistStore;

#pragma mark - Initialization

/**
 *  Creates a new instance of `INDANCSApplicationStorage`.
 *
 *  @param metadata  Key value store used to store application metadata.
 *  @param blacklist Key value store used to store blacklist preferences.
 *
 *  @return A new instance of `INDANCSApplicationStorage`
 */
- (id)initWithMetadataStore:(id<INDANCSKeyValueStore>)metadata blacklistStore:(id<INDANCSKeyValueStore>)blacklist;

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

#pragma mark - Blacklist

/**
 *  Set blacklisting preferences for a particular application and device.
 *
 *  @param blacklisted Whether the application should be blacklisted.
 *  @param application The application to set the blacklist preference for.
 *  @param device      The device to set the blacklist preference for.
 */
- (void)setBlacklisted:(BOOL)blacklisted forApplication:(INDANCSApplication *)application device:(INDANCSDevice *)device;


/**
 *  Retrieve blacklisting preferences for a particular application and device.
 *
 *  @param application The application for which to retrieve the blacklisting preference.
 *  @param device      The device for which to retrieve the blacklisting preference.
 *
 *  @return The blacklisting preference for the specified application and device.
 */
- (BOOL)isBlacklistedApplication:(INDANCSApplication *)application forDevice:(INDANCSDevice *)device;

@end
