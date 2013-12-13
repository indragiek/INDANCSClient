//
//  INDANCSNotification.m
//  INDANCSMac
//
//  Created by Indragie Karunaratne on 12/12/2013.
//  Copyright (c) 2013 Indragie Karunaratne. All rights reserved.
//

#import "INDANCSNotification.h"
#import "INDANCSNotification_Private.h"

typedef NS_ENUM(NSInteger, INDANCSEventFlags) {
	INDANCSEventFlagSilent = (1 << 0),
	INDANCSEventFlagImportant = (1 << 1)
};

@implementation INDANCSNotification

#pragma mark - NSCoder

- (id)initWithCoder:(NSCoder *)aDecoder
{
	if ((self = [super init])) {
		_eventID = [[aDecoder decodeObjectForKey:@"eventID"] unsignedCharValue];
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
	[aCoder encodeObject:@(self.eventID) forKey:@"eventID"];
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
