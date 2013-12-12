//
//  INDANCSServer.h
//  INDANCSClient
//
//  Created by Indragie Karunaratne on 12/11/2013.
//  Copyright (c) 2013 Indragie Karunaratne. All rights reserved.
//

//#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR

#import <Foundation/Foundation.h>
#import <IOBluetooth/IOBluetooth.h>

/**
 *  Exposes iOS device as a Bluetooth peripheral for use with `INDANCSClient`
 */
@interface INDANCSServer : NSObject
@property (nonatomic, assign, readonly) CBPeripheralManagerState state;
/**
 *  Start advertising as a Bluetooth peripheral.
 *
 *  The advertisement will only begin when the underlying `CBPeripheralManager`
 *  is in the `CBPeripheralManagerStatePoweredOn` state.
 */
- (void)startAdvertising;

/**
 *  Stop advertising as a Bluetooth peripheral.
 */
- (void)stopAdvertising;
@end

//#endif