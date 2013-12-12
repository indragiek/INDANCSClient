//
//  INDANCSClient.h
//  INDANCSClient
//
//  Created by Indragie Karunaratne on 12/11/2013.
//  Copyright (c) 2013 Indragie Karunaratne. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <IOBluetooth/IOBluetooth.h>

@protocol INDANCSClientDelegate;

/**
 *  Objective-C client for the Apple Notification Center Service.
 */
@interface INDANCSClient : NSObject
/**
 *  Current state of the underlying Bluetooth manager. KVO observable.
 */
@property (nonatomic, assign, readonly) CBCentralManagerState state;
- (void)scanForDevices;
@end

@protocol INDANCSClientDelegate <NSObject>
@end