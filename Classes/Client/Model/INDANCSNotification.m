//
//  INDANCSNotification.m
//  INDANCSMac
//
//  Created by Indragie Karunaratne on 12/12/2013.
//  Copyright (c) 2013 Indragie Karunaratne. All rights reserved.
//

#import "INDANCSNotification.h"
#import "INDANCSNotification_Private.h"
#import "INDANCSDevice.h"
#import "INDANCSResponse.h"
#import "INDANCSObjectEquality.h"
#import "NSData+INDANCSAdditions.h"

typedef NS_OPTIONS(uint8_t, INDANCSEventFlags) {
	INDANCSEventFlagSilent = (1 << 0),
	INDANCSEventFlagImportant = (1 << 1)
};

@interface INDANCSNotification ()
@property (assign, readwrite) INDANCSEventID latestEventID;
@property (assign, readwrite) BOOL silent;
@property (assign, readwrite) BOOL important;
@property (assign, readwrite) INDANCSCategoryID categoryID;
@property (assign, readwrite) uint8_t categoryCount;
@property (strong, readwrite) NSString *title;
@property (strong, readwrite) NSString *subtitle;
@property (strong, readwrite) NSString *message;
@property (strong, readwrite) NSDate *date;
@end

@implementation INDANCSNotification

#pragma mark - Initialization

- (id)initWithUID:(uint32_t)UID
{
	if ((self = [super init])) {
		_notificationUID = UID;
	}
	return self;
}

#pragma mark - NSObject

- (NSString *)description
{
	return [NSString stringWithFormat:@"<%@:%p\nlatestEventID: %d\nsilent: %d\nimportant: %d\ncategoryID: %d\ncategoryCount: %d\nnotificationUID: %d\napplication: %@\ntitle: %@\nsubtitle: %@\nmessage: %@\ndate: %@>", NSStringFromClass(self.class), self, self.latestEventID, self.silent, self.important, self.categoryID, self.categoryCount, self.notificationUID, self.application, self.title, self.subtitle, self.message, self.date];
}

- (BOOL)isEqual:(id)object
{
	if (object == self) return YES;
	if (![object isMemberOfClass:self.class]) return NO;
	
	INDANCSNotification *notification = object;
	return (self.notificationUID == notification.notificationUID)
		&& INDANCSEqualObjects(self.device, notification.device);
}

- (NSUInteger)hash
{
	return self.notificationUID ^ self.device.hash;
}

#pragma mark - NSCoder

- (id)initWithCoder:(NSCoder *)aDecoder
{
	if ((self = [super init])) {
		_silent = [aDecoder decodeBoolForKey:@"silent"];
		_important = [aDecoder decodeBoolForKey:@"important"];
		_categoryID = [[aDecoder decodeObjectForKey:@"categoryID"] unsignedCharValue];
		_categoryCount = [[aDecoder decodeObjectForKey:@"categoryCount"] unsignedCharValue];
		_notificationUID = [[aDecoder decodeObjectForKey:@"notificationUID"] unsignedIntValue];
		_application = [aDecoder decodeObjectForKey:@"application"];
		_title = [aDecoder decodeObjectForKey:@"title"];
		_subtitle = [aDecoder decodeObjectForKey:@"subtitle"];
		_message = [aDecoder decodeObjectForKey:@"message"];
		_date = [aDecoder decodeObjectForKey:@"date"];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
	[aCoder encodeBool:self.silent forKey:@"silent"];
	[aCoder encodeBool:self.important forKey:@"important"];
	[aCoder encodeObject:@(self.categoryID) forKey:@"categoryID"];
	[aCoder encodeObject:@(self.categoryCount) forKey:@"categoryCount"];
	[aCoder encodeObject:@(self.notificationUID) forKey:@"notificationUID"];
	[aCoder encodeObject:self.application forKey:@"application"];
	[aCoder encodeObject:self.title forKey:@"title"];
	[aCoder encodeObject:self.subtitle forKey:@"subtitle"];
	[aCoder encodeObject:self.message forKey:@"message"];
	[aCoder encodeObject:self.date forKey:@"date"];
}

#pragma mark - Private

/*
 * GATT notification format
 *
 *  ----------------------------------------------------------------------------------------------
 * |              |                 |                 |                    |                      |
 * | Event ID (1) | Event Flags (1) | Category ID (1) | Category Count (1) | Notification UID (4) |
 * |              |                 |                 |                    |                      |
 *  ----------------------------------------------------------------------------------------------
 *
 */
- (void)mergeAttributesFromGATTNotificationData:(NSData *)data
{
	NSUInteger offset = 0;
	self.latestEventID = [data ind_readUInt8At:&offset];
	uint8_t flags = [data ind_readUInt8At:&offset];
	self.silent = (flags & INDANCSEventFlagSilent) == INDANCSEventFlagSilent;
	self.important = (flags & INDANCSEventFlagImportant) == INDANCSEventFlagImportant;
	self.categoryID = [data ind_readUInt8At:&offset];
	self.categoryCount = [data ind_readUInt8At:&offset];
}

- (void)mergeAttributesFromNotificationAttributeResponse:(INDANCSResponse *)response
{
	[response.allAttributes enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, NSString *obj, BOOL *stop) {
		INDANCSNotificationAttributeID attr = key.unsignedCharValue;
		id transformedValue = [self transformedValueForAttributeValue:obj attributeID:attr];
		NSString *keypath = [self keypathForAttributeID:attr];
		[self setValue:transformedValue forKey:keypath];
	}];
}

- (NSString *)keypathForAttributeID:(INDANCSNotificationAttributeID)attributeID
{
	switch (attributeID) {
		case INDANCSNotificationAttributeIDAppIdentifier:
			return @"bundleIdentifier";
		case INDANCSNotificationAttributeIDMessage:
			return @"message";
		case INDANCSNotificationAttributeIDDate:
			return @"date";
		case INDANCSNotificationAttributeIDTitle:
			return @"title";
		case INDANCSNotificationAttributeIDSubtitle:
			return @"subtitle";
		default:
			return nil;
	}
}

- (id)transformedValueForAttributeValue:(NSString *)value attributeID:(INDANCSNotificationAttributeID)attributeID
{
	switch (attributeID) {
		case INDANCSNotificationAttributeIDDate:
			return [self.notificationDateFormatter dateFromString:value];
		default:
			return value;
	}
}

- (NSDateFormatter *)notificationDateFormatter
{
	static NSDateFormatter *formatter = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		formatter = [[NSDateFormatter alloc] init];
		formatter.dateFormat = @"yyyyMMdd'T'HHmmSS";
	});
	return formatter;
}

@end
