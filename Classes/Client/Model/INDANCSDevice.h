//
//  INDANCSDevice.h
//  INDANCSMac
//
//  Created by Indragie Karunaratne on 12/11/2013.
//  Copyright (c) 2013 Indragie Karunaratne. All rights reserved.
//

#import "INDANCSDefines.h"

/**
 *  Model object representing an iOS device.
 */
@interface INDANCSDevice : NSObject
/**
 *  The name of the device.
 */
@property (nonatomic, strong, readonly) NSString *name;

/**
 *  The model identifier of the device (e.g. iPhone 5,1)
 */
@property (nonatomic, strong, readonly) NSString *modelIdentifier;
@end
