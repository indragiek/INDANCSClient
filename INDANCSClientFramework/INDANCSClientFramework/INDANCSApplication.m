//
//  INDANCSApplication.m
//  INDANCSMac
//
//  Created by Indragie Karunaratne on 12/12/2013.
//  Copyright (c) 2013 Indragie Karunaratne. All rights reserved.
//

#import "INDANCSApplication.h"
#import "INDANCSApplication_Private.h"
#import "INDANCSResponse.h"
#import "INDANCSObjectEquality.h"

@implementation INDANCSApplication

#pragma mark - Initialization

- (id)initWithAppAttributeResponse:(INDANCSResponse *)response
{
	if ((self = [super init])) {
		_bundleIdentifier = response.bundleIdentifier;
		_name = [response valueForAttributeID:INDANCSAppAttributeIDDisplayName];
	}
	return self;
}

- (id)initWithBundleIdentifier:(NSString *)bundleID dictionary:(NSDictionary *)dictionary
{
	if ((self = [self initWithDictionary:dictionary])) {
		_bundleIdentifier = bundleID;
	}
	return self;
}

#pragma mark - INDANCSDictionarySerialization


- (id)initWithDictionary:(NSDictionary *)dictionary
{
	if ((self = [super init])) {
		_name = dictionary[@"name"];
	}
	return self;
}

- (NSDictionary *)dictionaryValue
{
	if (self.name == nil) return nil;
	return @{@"name" : self.name};
}

#pragma mark - NSObject

- (NSString *)description
{
	return [NSString stringWithFormat:@"<%@:%p bundleIdentifier:%@ name:%@>", NSStringFromClass(self.class), self, self.bundleIdentifier, self.name];
}

- (BOOL)isEqual:(id)object
{
	if (object == self) return YES;
	if (![object isMemberOfClass:self.class]) return NO;
	
	INDANCSApplication *application = object;
	return INDANCSEqualObjects(self.bundleIdentifier, application.bundleIdentifier)
		&& INDANCSEqualObjects(self.name, application.name);
}

- (NSUInteger)hash
{
	return self.name.hash ^ self.bundleIdentifier.hash;
}

#pragma mark - NSCoder

- (id)initWithCoder:(NSCoder *)aDecoder
{
	if ((self = [super init])) {
		_bundleIdentifier = [aDecoder decodeObjectForKey:@"bundleIdentifier"];
		_name = [aDecoder decodeObjectForKey:@"name"];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
	[aCoder encodeObject:self.bundleIdentifier forKey:@"bundleIdentifier"];
	[aCoder encodeObject:self.name forKey:@"name"];
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
	INDANCSApplication *application = [[INDANCSApplication allocWithZone:zone] init];
	application.bundleIdentifier = self.bundleIdentifier;
	application.name = self.name;
	return application;
}

@end
