//
//  INDANCSNotification.m
//  INDANCSMac
//
//  Created by Indragie Karunaratne on 12/12/2013.
//  Copyright (c) 2013 Indragie Karunaratne. All rights reserved.
//

#import "INDANCSNotification.h"
#import "INDANCSNotification_Private.h"

@implementation INDANCSNotification

#pragma mark - NSObject

- (NSString *)description
{
	return [NSString stringWithFormat:@"<%@:%p\nlatestEventID: %d\nsilent: %d\nimportant: %d\ncategoryID: %d\ncategoryCount: %d\nnotificationUID: %d\napplication: %@\ntitle: %@\nsubtitle: %@\nmessage: %@\ndate: %@>", NSStringFromClass(self.class), self, self.latestEventID, self.silent, self.important, self.categoryID, self.categoryCount, self.notificationUID, self.application, self.title, self.subtitle, self.message, self.date];
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

@end
