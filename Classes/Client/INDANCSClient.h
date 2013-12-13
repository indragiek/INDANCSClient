//
//  INDANCSClient.h
//  INDANCSClient
//
//  Created by Indragie Karunaratne on 12/11/2013.
//  Copyright (c) 2013 Indragie Karunaratne. All rights reserved.
//

#import "INDANCSDefines.h"
#import "INDANCSDevice.h"
#import "INDANCSNotification.h"
#import "INDANCSApplication.h"

@protocol INDANCSClientDelegate;

/**
 *  Objective-C client for the Apple Notification Center Service.
 */
@interface INDANCSClient : NSObject
/**
 *  Current state of the underlying Bluetooth manager. KVO observable.
 */
@property (nonatomic, assign, readonly) CBCentralManagerState state;

/**
 *  Delegate object.
 */
@property (nonatomic, assign) id<INDANCSClientDelegate> delegate;

/**
 *  Start scanning for iOS devices. Calls the `ANCSClient:didFindDevice`
 *  delegate method when a device is found.
 */
- (void)scanForDevices;

/**
 *  Stops a scan previously started using `-scanForDevices`.
 */
- (void)stopScanning;
@end

@protocol INDANCSClientDelegate <NSObject>
@optional

/**
 *  Called when an iOS device is found during a scan. The device is automatically
 *  connected to in order to find out the device name and other characteristics.
 *
 *  @param client The `INDANCSClient` instance that found the device.
 *  @param device The device that was found.
 */
- (void)ANCSClient:(INDANCSClient *)client didFindDevice:(INDANCSDevice *)device;

/**
 *  Called when an `INDANCSDevice` disconnects.
 *
 *  @param client The `INDANCSClient` instance.
 *  @param error  An error describing the cause of the disconnection.
 */
- (void)ANCSClient:(INDANCSClient *)client device:(INDANCSDevice *)device disconnectedWithError:(NSError *)error;

/**
 *  Called when an attempted connection to an `INDANCSDevice` fails.
 *
 *  @param client The `INDANCSClient` instance.
 *  @param device The `INDANCSDevice` for which the connection failed.
 *  @param error  An error describing the connection failure.
 */
- (void)ANCSClient:(INDANCSClient *)client device:(INDANCSDevice *)device failedToConnectWithError:(NSError *)error;

/**
 *  Called when service discovery fails for a device (ie. the ANCS service couldn't
 *  be found).
 *
 *  @param client The `INDANCSClient` instance.
 *  @param device The `INDANCSDevice` for which service discovery failed.
 *  @param error  An error describing the cause of the service discovery failure.
 */
- (void)ANCSClient:(INDANCSClient *)client serviceDiscoveryFailedForDevice:(INDANCSDevice *)device withError:(NSError *)error;

@end
