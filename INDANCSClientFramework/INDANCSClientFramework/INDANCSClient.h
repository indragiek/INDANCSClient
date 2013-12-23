//
//  INDANCSClient.h
//  INDANCSClient
//
//  Created by Indragie Karunaratne on 12/11/2013.
//  Copyright (c) 2013 Indragie Karunaratne. All rights reserved.
//

#import <IOBluetooth/IOBluetooth.h>
#import "INDANCSDevice.h"
#import "INDANCSNotification.h"
#import "INDANCSApplication.h"
#import "INDANCSKeyValueStore.h"

@class INDANCSClient;
@protocol INDANCSClientDelegate;

typedef void (^INDANCSDiscoveryBlock)(INDANCSClient *, INDANCSDevice *);
typedef void (^INDANCSNotificationBlock)(INDANCSClient *, INDANCSNotification *);

/**
 *  Objective-C client for the Apple Notification Center Service.
 */
@interface INDANCSClient : NSObject
/**
 *  Current state of the underlying Bluetooth manager. KVO observable.
 */
@property (assign, readonly) CBCentralManagerState state;

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
@property (assign) NSTimeInterval registrationTimeout;

/**
 *  If a device disconnects on its own, whether to attempt an automatic
 *  reconnection. Default value is `YES`.
 */
@property (assign) BOOL attemptAutomaticReconnection;

/**
 *  Key value store used to store application metadata.
 */
@property (nonatomic, strong, readonly) id<INDANCSKeyValueStore> metadataStore;

/**
 *  Key value store used to store blacklist preferences.
 */
@property (nonatomic, strong, readonly) id<INDANCSKeyValueStore> blacklistStore;


#pragma mark - Initialization

/**
 *  Default initializer that initializes the client using a persistent 
 *  key value store for app metadata. The store file will be placed in the
 *  application support directory.
 *
 *  @return A new instance of `INDANCSClient`.
 */
- (id)init;

/**
 *  Initializes the receiver using manually specified key value stores instances.
 *
 *  @param metadata  Key value store for storing application metadata.
 *
 *  @return A new instance of `INDANCSClient`
 */
- (id)initWithMetadataStore:(id<INDANCSKeyValueStore>)metadata;

#pragma mark - Devices

/**
 *  Scans for iOS devices to connect to. For each iOS device found,
 *  the specified discovery block is called.
 *
 *  @discussion Each discovered iOS device is connected to automatically
 *  to retrieve identifying information like the device name. After this
 *  initial connection, the device stays connected for a `registrationTimeout`
 *  seconds to allow you to register for notifications from that device. If
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

#pragma mark - Notifications

/**
 *  Registers to receive notifications from a specified iOS device.
 *
 *  @param device            The iOS device to receive notifications from.
 *  @param notificationBlock Block to be called when a notification is received.
 *
 *  @discussion Each device can only have a single notification block. Calling
 *  this method multiple times with different blocks will result in only the
 *  newest block being called.
 */
- (void)registerForNotificationsFromDevice:(INDANCSDevice *)device withBlock:(INDANCSNotificationBlock)notificationBlock;

/**
 *  Unregisters for notifications from a specified iOS device.
 *
 *  @param device The iOS device to unregister from.
 *
 *  @discussion The device is automatically disconnected after
 *  `registrationTimeout`.
 */
- (void)unregisterForNotificationsFromDevice:(INDANCSDevice *)device;

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
