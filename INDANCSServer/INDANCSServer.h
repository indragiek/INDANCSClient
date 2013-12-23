//
//  INDANCSServer.h
//  INDANCSClient
//
//  Created by Indragie Karunaratne on 12/11/2013.
//  Copyright (c) 2013 Indragie Karunaratne. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@protocol INDANCSServerDelegate;

/**
 *  Exposes iOS device as a Bluetooth peripheral for use with `INDANCSClient`
 */
@interface INDANCSServer : NSObject
/**
 *  State of the underlying `CBPeripheralManager`. KVO observable.
 */
@property (nonatomic, assign, readonly) CBPeripheralManagerState state;

/**
 *  Returns whether the underlying `CBPeripheralManager` is advertising.
 */
@property (nonatomic, assign, readonly, getter = isAdvertising) BOOL advertising;

@property (nonatomic, assign) id<INDANCSServerDelegate> delegate;

/**
 *  Creates and initializes a new `INDANCSServer` instance.
 *
 *  @param UID A unique identifier used to restore the peripheral manager
 *  between launches.
 *
 *  @return A new instance of `INDANCSServer`
 */
- (id)initWithUID:(NSString *)UID;

/**
 *  Start advertising as a Bluetooth peripheral.
 *
 *  The advertisement will only begin when the underlying `CBPeripheralManager`
 *  is in the `CBPeripheralManagerStatePoweredOn` state. When the advertising
 *  begins, the delegate method `ANCSServer:didStartAdvertisingWithError:`
 *  will be called.
 */
- (void)startAdvertising;

/**
 *  Stop advertising as a Bluetooth peripheral.
 */
- (void)stopAdvertising;
@end

@protocol INDANCSServerDelegate <NSObject>
/**
 *  Called when advertising begins (after a call to -startAdvertising)
 *
 *  @param server The `INDANCSServer` object that started advertising.
 *  @param error  An error that occurred when attempting to advertise, or `nil` if no error occurred.
 */
- (void)ANCSServer:(INDANCSServer *)server didStartAdvertisingWithError:(NSError *)error;
@end