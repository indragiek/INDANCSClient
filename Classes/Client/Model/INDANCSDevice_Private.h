//
//  INDANCSDevice_Private.h
//  INDANCSMac
//
//  Created by Indragie Karunaratne on 12/11/2013.
//  Copyright (c) 2013 Indragie Karunaratne. All rights reserved.
//

#import "INDANCSDevice.h"

@class INDANCSNotification;
@class INDANCSRequest;

@interface INDANCSDevice ()
/**
 *  Designated initializer.
 *
 *  @param peripheral The underlying Core Bluetooth `CBPeripheral`.
 *
 *  @return A new instance of `INDANCSDevice`.
 */
- (id)initWithCBPeripheral:(CBPeripheral *)peripheral;

/**
 *  The underlying Core Bluetooth `CBPeripheral`.
 */
@property (nonatomic, strong, readonly) CBPeripheral *peripheral;

@property (nonatomic, strong, readwrite) NSString *name;
@property (nonatomic, strong, readwrite) NSString *modelIdentifier;

/**
 *  The Apple Notification Center Service.
 */
@property (nonatomic, strong) CBService *ANCSService;

/**
 *  The device information service.
 */
@property (nonatomic, strong) CBService *DVCEService;

/**
 *  Name characteristic of the device information service.
 */
@property (nonatomic, strong) CBCharacteristic *NMCharacteristic;

/**
 *  Model characteristic of the device information service.
 */
@property (nonatomic, strong) CBCharacteristic *MLCharacteristic;

/**
 *  Notification Source characteristic of the ANCS service.
 */
@property (nonatomic, strong) CBCharacteristic *NSCharacteristic;

/**
 *  Control Point characteristic of the ANCS service.
 */
@property (nonatomic, strong) CBCharacteristic *CPCharacteristic;

/**
 *  Data Source characteristic of the ANCS service.
 */
@property (nonatomic, strong) CBCharacteristic *DSCharacteristic;

/**
 *  Device-specific state only used by `INDANCSClient`.
 */
@property (nonatomic, strong) NSTimer *registrationTimer;
@property (nonatomic, copy) id notificationBlock;

/**
 *  Adds a notification to the notifications set.
 *
 *  @param notification The notification to add.
 */
- (void)addNotification:(INDANCSNotification *)notification;

/**
 *  Removes a notification from the notification set.
 *
 *  @param notification The notification to remove.
 */
- (void)removeNotification:(INDANCSNotification *)notification;

/**
 *  Removes a notification with the specified UID from the 
 *  notification set. Does nothing if no notification with the UID
 *  is in the notification set.
 *
 *  @param UID The UID of the notification to remove.
 */
- (void)removeNotificationForUID:(uint32_t)UID;

/**
 *  Sends a request through the ANCS Control Point characteristic.
 *
 *  @param request The request to send.
 */
- (void)sendRequest:(INDANCSRequest *)request;

@end
