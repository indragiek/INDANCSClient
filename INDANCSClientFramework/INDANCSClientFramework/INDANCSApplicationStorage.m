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
@end

@implementation INDANCSApplicationStorage

#pragma mark - Initialization

- (id)initWithMetadataStore:(id<INDANCSKeyValueStore>)metadata
{
	NSParameterAssert(metadata);
	
	if ((self = [super init])) {
		_metadataStore = metadata;
		_metadataCache = [NSMutableDictionary dictionary];
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

@end
