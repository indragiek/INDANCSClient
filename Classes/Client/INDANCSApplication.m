//
//  INDANCSApplication.m
//  INDANCSMac
//
//  Created by Indragie Karunaratne on 12/12/2013.
//  Copyright (c) 2013 Indragie Karunaratne. All rights reserved.
//

#import "INDANCSApplication.h"

@implementation INDANCSApplication

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
