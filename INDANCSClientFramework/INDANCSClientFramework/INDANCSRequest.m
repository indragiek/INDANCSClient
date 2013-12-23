//
//  INDANCSRequest.m
//  INDANCSMac
//
//  Created by Indragie Karunaratne on 12/22/2013.
//  Copyright (c) 2013 Indragie Karunaratne. All rights reserved.
//

#import "INDANCSRequest.h"

@interface INDANCSRequest ()
@property (nonatomic, assign, readwrite) NSUInteger attributeCount;
@end

@implementation INDANCSRequest {
	NSMutableData *_requestData;
}
@synthesize requestData = _requestData;

#pragma mark - Initialization

- (id)initWithCommandID:(INDANCSCommandID)commandID;
{
	if ((self = [super init])) {
		_commandID = commandID;
		_requestData = [NSMutableData dataWithBytes:&commandID length:sizeof(commandID)];
		_attributeCount = 0;
	}
	return self;
}

/*
 * Get Notification Attributes format
 *
 *  ----------------------------------------------------------------------------------------------
 * |                |                      |                    |                            |
 * | Command ID (1) | Notification UID (4) | Attribute ID n (1) | Attribute n Max Length (1) | ....
 * |                |                      |                    |                            |
 *  ----------------------------------------------------------------------------------------------
 *
 */
+ (instancetype)getNotificationAttributesRequestWithUID:(uint32_t)UID
{
	INDANCSRequest *request = [[self alloc] initWithCommandID:INDANCSCommandIDGetNotificationAttributes];
	[request->_requestData appendBytes:&UID length:sizeof(UID)];
	return request;
}

/*
 * Get App Attributes format
 *
 *  -------------------------------------------------------------
 * |                |                |                    |
 * | Command ID (1) | App Identifier | Attribute ID n (1) | ....
 * |                |                |                    |
 *  -------------------------------------------------------------
 *
 */
+ (instancetype)getAppAttributesRequestWithBundleIdentifier:(NSString *)identifier
{
	INDANCSRequest *request = [[self alloc] initWithCommandID:INDANCSCommandIDGetAppAttributes];
	
	// String has to be null terminated, using NSString -dataUsingEncoding:
	// does not return a null terminated string.
	const char *bytes = identifier.UTF8String;
	[request->_requestData appendBytes:bytes length:strlen(bytes) + 1];
	return request;
}

#pragma mark - Attributes

- (void)appendAttributeID:(uint8_t)attributeID maxLength:(uint16_t)maxLength
{
	self.attributeCount++;
	[_requestData appendBytes:&attributeID length:sizeof(attributeID)];
	if (maxLength != 0) {
		[_requestData appendBytes:&maxLength length:sizeof(maxLength)];
	}
}

@end
