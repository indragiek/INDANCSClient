//
//  INDANCSClient.h
//  INDANCSClient
//
//  Created by Indragie Karunaratne on 12/11/2013.
//  Copyright (c) 2013 Indragie Karunaratne. All rights reserved.
//

#import "INDANCSDefines.h"
#import "INDANCSDevice.h"

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
 *  Start scanning for iOS deviecs. Calls the `ANCSClient:didFindDevice`
 *  delegate method when a device is found.
 */
- (void)scanForDevices;

/**
 *  Stops a scan previously started using `-scanForDevices`.
 */
- (void)stopScanning;
@end

@protocol INDANCSClientDelegate <NSObject>
/**
 *  Called when an iOS device is found during a scan.
 *
 *  @param client The `INDANCSClient` instance that found the device.
 *  @param device The device that was found.
 */
- (void)ANCSClient:(INDANCSClient *)client didFindDevice:(INDANCSDevice *)device;
@end