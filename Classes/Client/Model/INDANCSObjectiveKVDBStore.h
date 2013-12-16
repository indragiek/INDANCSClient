//
//  INDANCSObjectiveKVDBStore.h
//  INDANCSMac
//
//  Created by Indragie Karunaratne on 12/15/2013.
//  Copyright (c) 2013 Indragie Karunaratne. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ObjectiveKVDB/ObjectiveKVDB.h>
#import "INDANCSKeyValueStore.h"

@interface INDANCSObjectiveKVDBStore : KVDBDatabase <INDANCSKeyValueStore>
@end
