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
