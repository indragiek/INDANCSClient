//
//  INDANCSObjectiveKVDBStore.m
//  INDANCSMac
//
//  Created by Indragie Karunaratne on 12/15/2013.
//  Copyright (c) 2013 Indragie Karunaratne. All rights reserved.
//

#import "INDANCSObjectiveKVDBStore.h"
#import <ObjectiveKVDB/ObjectiveKVDB.h>

@interface INDANCSObjectiveKVDBStore ()
@property (nonatomic, strong, readonly) KVDBDatabase *db;
@end

@implementation INDANCSObjectiveKVDBStore

#pragma mark - INDANCSKeyValueStore

- (id)initWithDatabasePath:(NSString *)path
{
	if ((self = [super init])) {
		_db = [KVDBDatabase databaseWithPath:path];
	}
	return self;
}

- (void)setObject:(id)obj forKeyedSubscript:(id<NSCopying>)key
{
	[self.db setObject:obj forKeyedSubscript:key];
}

- (id)objectForKeyedSubscript:(id<NSCopying>)key
{
	return [self.db objectForKeyedSubscript:key];
}


@end
