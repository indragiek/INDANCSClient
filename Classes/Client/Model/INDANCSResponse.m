//
//  INDANCSResponse.m
//  INDANCSMac
//
//  Created by Indragie Karunaratne on 12/22/2013.
//  Copyright (c) 2013 Indragie Karunaratne. All rights reserved.
//

#import "INDANCSResponse.h"
#import "NSData+INDANCSAdditions.h"

@interface INDANCSResponse ()
@property (nonatomic, assign) NSUInteger expectedAttributeCount;
@property (nonatomic, strong, readwrite) NSDictionary *allAttributes;
@property (nonatomic, assign, readwrite) INDANCSCommandID commandID;
@property (nonatomic, assign, readwrite) uint32_t notificationUID;
@property (nonatomic, strong, readwrite) NSString *bundleIdentifier;
@property (nonatomic, assign, readwrite, getter = isComplete) BOOL complete;
@property (nonatomic, strong, readwrite) NSData *extraneousData;
@end

@implementation INDANCSResponse {
	NSMutableData *_responseData;
}
@synthesize responseData = _responseData;

- (id)initWithExpectedAttributeCount:(NSUInteger)count
{
	if ((self = [super init])) {
		_responseData = [NSMutableData data];
		_expectedAttributeCount = count;
	}
	return self;
}

+ (instancetype)responseWithExpectedAttributeCount:(NSUInteger)count
{
	return [[self alloc] initWithExpectedAttributeCount:count];
}

- (NSString *)valueForAttributeID:(uint8_t)attributeID
{
	return self.allAttributes[@(attributeID)];
}

- (void)appendData:(NSData *)data
{
	[_responseData appendData:data];
	if ([self checkCompletion]) {
		self.complete = YES;
		[self processResponseData];
	}
}

#pragma mark - Private

- (BOOL)checkCompletion
{
	NSUInteger len = self.responseData.length;
	if (len < sizeof(INDANCSCommandID)) return NO;
	
	NSUInteger offset = 0;
	INDANCSCommandID command = [self.responseData ind_readUInt8At:&offset];
	if (command == INDANCSCommandIDGetNotificationAttributes) {
		offset += sizeof(uint32_t);
	} else if (command == INDANCSCommandIDGetAppAttributes) {
		NSUInteger loc = [self.responseData ind_locationOfNullByteFromOffset:offset];
		if (loc == NSNotFound) return NO;
		offset += loc;
	}
	
	// Header consists of one byte containing the Attribute ID and 2 bytes
	// containing the Attribute Length.
	const NSUInteger headerByteCount = sizeof(INDANCSNotificationAttributeID) + sizeof(uint16_t);
	NSUInteger attrCount = self.expectedAttributeCount;
	while ((offset + headerByteCount) <= len && attrCount > 0) {
		offset += sizeof(INDANCSNotificationAttributeID);
		offset += [self.responseData ind_readUInt16At:&offset]; // Attribute length
		if (offset > len) break;
		attrCount--;
	}
	return (attrCount == 0);
}

/*
 * Get Notification Attributes response format
 *
 *  -----------------------------------------------------------------------------------------------------------------
 * |                |                      |                    |                        |
 * | Command ID (1) | Notification UID (4) | Attribute ID n (1) | Attribute n Length (1) | Attribute n Contents ...
 * |                |                      |                    |                        |
 *  -----------------------------------------------------------------------------------------------------------------
 *
 */
- (void)processResponseData
{
	NSUInteger offset = 0;
	self.commandID = [self.responseData ind_readUInt8At:&offset];
	switch (self.commandID) {
		case INDANCSCommandIDGetNotificationAttributes:
			self.notificationUID = [self.responseData ind_readUInt32At:&offset];
			break;
		case INDANCSCommandIDGetAppAttributes: {
			NSUInteger loc = [self.responseData ind_locationOfNullByteFromOffset:offset];
			NSData *stringData = [self.responseData subdataWithRange:NSMakeRange(offset, loc - offset)];
			self.bundleIdentifier = [[NSString alloc] initWithData:stringData encoding:NSUTF8StringEncoding];
			offset += stringData.length + 1; // Skip null byte
		}
		default:
			break;
	}
	NSMutableDictionary *responseValues = [NSMutableDictionary dictionaryWithCapacity:self.expectedAttributeCount];
	for (int i = 0; i < self.expectedAttributeCount; i++) {
		uint8_t attr = [self.responseData ind_readUInt8At:&offset];
		uint16_t attrLen = [self.responseData ind_readUInt16At:&offset];
		if (attrLen != 0) {
			NSData *val = [self.responseData subdataWithRange:NSMakeRange(offset, attrLen)];
			responseValues[@(attr)] = [[NSString alloc] initWithData:val encoding:NSUTF8StringEncoding];
			offset += attrLen;
		}
	}
	self.allAttributes = responseValues;
	
	const NSUInteger len = self.responseData.length;
	if (offset < len) {
		NSRange range = NSMakeRange(offset, len - offset);
		self.extraneousData = [self.responseData subdataWithRange:range];
		[_responseData replaceBytesInRange:range withBytes:NULL length:0];
	}
}

@end
