//
//  INDANCSRequest.h
//  INDANCSMac
//
//  Created by Indragie Karunaratne on 12/22/2013.
//  Copyright (c) 2013 Indragie Karunaratne. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "INDANCSAttributes.h"

typedef NS_ENUM(uint8_t, INDANCSCommandID) {
	INDANCSCommandIDGetNotificationAttributes = 0,
	INDANCSCommandIDGetAppAttributes = 1
};

@interface INDANCSRequest : NSObject
/**
 *  The command ID for the request.
 */
@property (nonatomic, assign, readonly) INDANCSCommandID commandID;

/**
 *  Request data to be written to the control point.
 */
@property (nonatomic, strong, readonly) NSData *requestData;

/**
 *  Request for retrieving information about a particular notification.
 *
 *  @param UID The notification UID.
 *
 *  @return A new instance of `INDANCSRequest`.
 */
+ (instancetype)getNotificationAttributesRequestWithUID:(uint32_t)UID;

/**
 *  Request for retrieving information about a particular application.
 *
 *  @param identifier The bundle identifier of the application.
 *
 *  @return A new instance of `INDANCSRequest`.
 */
+ (instancetype)getAppAttributesRequestWithBundleIdentifier:(NSString *)identifier;

/**
 *  Appends an attribute ID to be included in the request.
 *
 *  @param attributeID The attribute ID.
 *  @param maxLength   An optional maximum length that must be included
 *  with certain attribute IDs. Pass 0 to omit this parameter in the 
 *  request data.
 */
- (void)appendAttributeID:(uint8_t)attributeID maxLength:(uint16_t)maxLength;

@end
