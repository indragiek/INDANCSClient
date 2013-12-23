//
//  INDANCSNotification_Private.h
//  INDANCSMac
//
//  Created by Indragie Karunaratne on 12/12/2013.
//  Copyright (c) 2013 Indragie Karunaratne. All rights reserved.
//

#import "INDANCSNotification.h"

@class INDANCSResponse;
@interface INDANCSNotification ()
/**
 *  Read/write declarations of public facing properties.
 */
@property (nonatomic, weak, readwrite) INDANCSDevice *device;
@property (nonatomic, strong, readwrite) INDANCSApplication *application;

/**
 *  Bundle identifier of the application that this notification
 *  originated from.
 */
@property (nonatomic, strong) NSString *bundleIdentifier;

/**
 *  Designated initializer.
 *
 *  @param UID The UID of the receiver.
 *
 *  @return A new instance of `INDANCSNotification`.
 */
- (id)initWithUID:(uint32_t)UID;

/**
 *  Merges notification attributes contained in a GATT notification.
 *
 *  @param data Notification data.
 */
- (void)mergeAttributesFromGATTNotificationData:(NSData *)data;

/**
 *  Merges notification attributes contained in a response to
 *  a Get Notification Attributes command.
 *
 *  @param response Command response.
 */
- (void)mergeAttributesFromNotificationAttributeResponse:(INDANCSResponse *)response;
@end
