//
//  INDANCSDictionarySerialization.h
//  INDANCSMac
//
//  Created by Indragie Karunaratne on 12/15/2013.
//  Copyright (c) 2013 Indragie Karunaratne. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  Protocol for serializing and deserializing objects from dictionaries.
 */
@protocol INDANCSDictionarySerialization <NSObject>
@required
- (id)initWithDictionary:(NSDictionary *)dictionary;
- (NSDictionary *)dictionaryValue;
@end
