//
//  INDANCSKeyValueStore.h
//  INDANCSMac
//
//  Created by Indragie Karunaratne on 12/15/2013.
//  Copyright (c) 2013 Indragie Karunaratne. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  Interface for a key value store that is used by the framework to store things
 *  like application metadata.
 *
 *  The implementation of the store is decoupled so that you are free to swap in
 *  your choice of persistent or in-memory key value storage. This framework
 *  includes two concrete implementations of an `INDANCSKeyValueStore`, the in
 *  memory store (`INDANCSInMemoryStore`) and a persistent store using kvdb 
 *  (`INDANCSObjectiveKVDBStore`).
 */
@protocol INDANCSKeyValueStore <NSObject>
/**
 *  Designated initializer for the key value store. In-memory stores can ignore
 *  the `path` parameter, but persistent stores should store their database file
 *  at the specified path.
 *
 *  @param path Path or persistent stores to store their database file.
 *
 *  @return A new key value store instance.
 */
- (id)initWithDatabasePath:(NSString *)path;

/*
 *  The key value store should implement keyed subscripting such that values can
 *  be written and retrieved from the store. 
 *
 *  All keys and values will be `NSString` instances.
 *
 *  Setting a value of `nil` for a key should delete the key from the store.
 */
- (id)objectForKeyedSubscript:(id <NSCopying>)key;
- (void)setObject:(id)obj forKeyedSubscript:(id <NSCopying>)key;
@end
