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
@property (nonatomic, strong, readonly) id<INDANCSKeyValueStore> metadataStore;
@property (nonatomic, strong, readonly) id<INDANCSKeyValueStore> blacklistStore;

#pragma mark - Initialization

- (id)initWithMetadataStore:(id<INDANCSKeyValueStore>)metadata blacklist:(id<INDANCSKeyValueStore>)blacklist;

#pragma mark - Metadata

- (INDANCSApplication *)applicationForBundleIdentifier:(NSString *)identifier;
- (void)setApplication:(INDANCSApplication *)application forBundleIdentifier:(NSString *)identifier;

#pragma mark - Blacklist

- (void)setBlacklisted:(BOOL)blacklisted forApplication:(INDANCSApplication *)application device:(INDANCSDevice *)device;
- (BOOL)isBlacklistedApplication:(INDANCSApplication *)application forDevice:(INDANCSDevice *)device;

@end
