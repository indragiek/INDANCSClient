//
//  INDANCSApplication.m
//  INDANCSMac
//
//  Created by Indragie Karunaratne on 12/12/2013.
//  Copyright (c) 2013 Indragie Karunaratne. All rights reserved.
//

#import "INDANCSApplication.h"
#import "INDANCSApplication_Private.h"

@implementation INDANCSApplication

#pragma mark - INDANCSDictionarySerialization

- (id)initWithBundleIdentifier:(NSString *)bundleID dictionary:(NSDictionary *)dictionary
{
	if ((self = [self initWithDictionary:dictionary])) {
		_bundleIdentifier = bundleID;
	}
	return self;
}

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

@end
