//
//  INDANCSApplicationStorage.m
//  INDANCSMac
//
//  Created by Indragie Karunaratne on 12/15/2013.
//  Copyright (c) 2013 Indragie Karunaratne. All rights reserved.
//

#import "INDANCSApplicationStorage.h"
#import "INDANCSApplication_Private.h"
#import "INDANCSDevice.h"

@interface INDANCSApplicationStorage ()
@property (nonatomic, strong) NSMutableDictionary *metadataCache;
@property (nonatomic, strong) NSMutableDictionary *blacklistCache;
@end

@implementation INDANCSApplicationStorage

#pragma mark - Initialization

- (id)initWithMetadataStore:(id<INDANCSKeyValueStore>)metadata blacklistStore:(id<INDANCSKeyValueStore>)blacklist
{
	NSParameterAssert(metadata);
	NSParameterAssert(blacklist);
	
	if ((self = [super init])) {
		_metadataStore = metadata;
		_blacklistStore = blacklist;
		_metadataCache = [NSMutableDictionary dictionary];
		_blacklistCache = [NSMutableDictionary dictionary];
	}
	return self;
}

#pragma mark - Metadata

- (INDANCSApplication *)applicationForBundleIdentifier:(NSString *)identifier
{
	NSParameterAssert(identifier);
	INDANCSApplication *application = self.metadataCache[identifier];
	if (application != nil) {
		return application;
	}
	
	NSString *JSONString = self.metadataStore[identifier];
	NSData *JSONData = [JSONString dataUsingEncoding:NSUTF8StringEncoding];
	if (JSONData == nil) return nil;
	
	NSError *error = nil;
	NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:JSONData options:0 error:&error];
	if (dictionary == nil) {
		NSLog(@"Error reading JSON data: %@", error);
		return nil;
	}
	application = [[INDANCSApplication alloc] initWithBundleIdentifier:identifier dictionary:dictionary];
	if (application) {
		self.metadataCache[identifier] = [application copy];
	}
	return application;
}

- (void)setApplication:(INDANCSApplication *)application forBundleIdentifier:(NSString *)identifier
{
	NSParameterAssert(identifier);
	
	INDANCSApplication *existingApplication = self.metadataCache[identifier];
	if ([application isEqual:existingApplication]) return;
	
	NSDictionary *dictionary = [application dictionaryValue];
	NSString *JSONString = nil;
	
	if (dictionary != nil) {
		NSError *error = nil;
		NSData *JSONData = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:&error];
		if (JSONData == nil) {
			NSLog(@"Error serializing to JSON: %@", error);
			return;
		} else {
			JSONString = [[NSString alloc] initWithData:JSONData encoding:NSUTF8StringEncoding];
		}
	}
	
	self.metadataStore[identifier] = JSONString;
	if (application == nil) {
		[self.metadataCache removeObjectForKey:identifier];
	} else {
		self.metadataCache[identifier] = [application copy];
	}
}

#pragma mark - Blacklisting

- (void)setBlacklisted:(BOOL)blacklisted forApplication:(INDANCSApplication *)application device:(INDANCSDevice *)device
{
	NSString *key = [self blacklistKeyForApplication:application device:device];
	BOOL hasExistingValue = (self.blacklistCache[key] != nil);
	if (blacklisted && !hasExistingValue) {
		self.blacklistStore[key] = @"1";
		self.blacklistCache[key] = @YES;
	} else if (!blacklisted && hasExistingValue) {
		self.blacklistStore[key] = nil;
		[self.blacklistCache removeObjectForKey:key];
	}
}

- (BOOL)isBlacklistedApplication:(INDANCSApplication *)application forDevice:(INDANCSDevice *)device
{
	NSString *key = [self blacklistKeyForApplication:application device:device];
	NSNumber *value = self.blacklistCache[key];
	if (value == nil) {
		NSString *stringValue = self.blacklistStore[key];
		value = @(stringValue.boolValue);
		self.blacklistCache[key] = value;
	}
	return value.boolValue;
}

- (NSString *)blacklistKeyForApplication:(INDANCSApplication *)application device:(INDANCSDevice *)device
{
	return [NSString stringWithFormat:@"%@:%@", application.bundleIdentifier, device.identifier.UUIDString];
}

@end
