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

typedef NS_ENUM(uint8_t, INDANCSEventID) {
	INDANCSEventIDNotificationAdded = 0,
	INDANCSEventIDNotificationModified = 1,
	INDANCSEventIDNotificationRemoved = 2
};

@class INDANCSClient;
@protocol INDANCSClientDelegate;

typedef void (^INDANCSDiscoveryBlock)(INDANCSClient *, INDANCSDevice *);

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
 *  Timeout to allow for registration before a discovered iOS device
 *  is disconnected from. Default value is 5.0 seconds.
 *
 *  @seealso -scanForDevices:
 */
@property (nonatomic, assign) NSTimeInterval registrationTimeout;

/**
 *  Scans for iOS devices to connect to. For each iOS device found,
 *  the specified discovery block is called.
 *
 *  @discussion Each discovered iOS device is connected to automatically
 *  to retrieve identifying information like the device name. After this
 *  initial connection, the device stays connected for a small period of
 *  time to allow you to register for notifications from that device. If
 *  no registration is received within the time out, the connection is
 *  dropped.
 *
 *  If you call this method multiple times, only the newest discovery
 *  block will be called.
 *
 *  @param discoveryBlock Discovery block to call when a new iOS device
 *  is discovered.
 */
- (void)scanForDevices:(INDANCSDiscoveryBlock)discoveryBlock;

/**
 *  Stops a scan previously started using `-scanForDevices:`.
 */
- (void)stopScanning;
@end

@protocol INDANCSClientDelegate <NSObject>
@optional

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
