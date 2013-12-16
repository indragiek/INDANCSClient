//
//  INDANCSInMemoryStore.m
//  INDANCSMac
//
//  Created by Indragie Karunaratne on 12/15/2013.
//  Copyright (c) 2013 Indragie Karunaratne. All rights reserved.
//

#import "INDANCSInMemoryStore.h"

@interface INDANCSInMemoryStore ()
@property (nonatomic, strong, readonly) NSMutableDictionary *backingDictionary;
@end

@implementation INDANCSInMemoryStore

#pragma mark - INDANCSKeyValueStore

- (id)initWithDatabasePath:(NSString *)path
{
	if ((self = [super init])) {
		_backingDictionary = [NSMutableDictionary dictionary];
	}
	return self;
}

- (id)objectForKeyedSubscript:(id <NSCopying>)key
{
	return [self.backingDictionary objectForKeyedSubscript:key];
}

- (void)setObject:(id)obj forKeyedSubscript:(id <NSCopying>)key
{
	[self.backingDictionary setObject:obj forKeyedSubscript:key];
}

@end
