//
//  INDANCSObjectEquality.h
//  INDANCSMac
//
//  Created by Indragie Karunaratne on 12/16/2013.
//  Copyright (c) 2013 Indragie Karunaratne. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_INLINE BOOL INDANCSEqualObjects(id obj1, id obj2) {
	return (obj1 == obj2) || [obj1 isEqual:obj2];
}
