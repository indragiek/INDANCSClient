//
//  INDANCSDevice.h
//  INDANCSMac
//
//  Created by Indragie Karunaratne on 12/11/2013.
//  Copyright (c) 2013 Indragie Karunaratne. All rights reserved.
//

@class INDANCSNotification;
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

/**
 * The unique identifier for the device.
 */
@property (nonatomic, strong, readonly) NSUUID *identifier;

/**
 *  Notifications received from the device in the order they
 *  were received (oldest to newest).
 *
 *  Notifications that have been dismissed from the device will be
 *  automatically removed from this set (KVO observable).
 *
 *  @discussion If you need access to a notification with a known
 *  UID, use the -notificationForUID: method for faster O(1) access.
 */
@property (nonatomic, strong, readonly) NSOrderedSet *notifications;

/**
 *  Returns the notification for a specified notification UID or
 *  nil if no notifications match the UID.
 *
 *  @param UID The notification UID.
 *
 *  @return The notification matching the specified UID.
 */
- (INDANCSNotification *)notificationForUID:(uint32_t)UID;

@end
