//
//  INDANCSDevice.m
//  INDANCSMac
//
//  Created by Indragie Karunaratne on 12/11/2013.
//  Copyright (c) 2013 Indragie Karunaratne. All rights reserved.
//

#import "INDANCSDevice.h"
#import "INDANCSDevice_Private.h"
#import "INDANCSNotification_Private.h"
#import "INDANCSObjectEquality.h"

@interface INDANCSDevice ()
@property (nonatomic, readonly) dispatch_queue_t notificationQueue;
@property (nonatomic, strong, readonly) NSMutableDictionary *notificationMap;
@end

@implementation INDANCSDevice {
	NSMutableOrderedSet *_notifications;
}
@synthesize notifications = _notifications;

#pragma mark - Initialization

- (id)initWithCBPeripheral:(CBPeripheral *)peripheral
{
	if ((self = [super init])) {
		_peripheral = peripheral;
		_notificationQueue = dispatch_queue_create("com.indragie.INDANCSClient.NotificationQueue", DISPATCH_QUEUE_CONCURRENT);
		_notifications = [NSMutableOrderedSet orderedSet];
		_notificationMap = [NSMutableDictionary dictionary];
		self.name = peripheral.name;
	}
	return self;
}

#pragma mark - Accessors

- (NSUUID *)identifier
{
	return self.peripheral.identifier;
}

#pragma mark - Notifications

- (INDANCSNotification *)notificationForUID:(uint32_t)UID
{
	__block INDANCSNotification *notification = nil;
	dispatch_sync(self.notificationQueue, ^{
		notification = self.notificationMap[@(UID)];
	});
	return notification;
}

- (NSOrderedSet *)notifications
{
	return [_notifications copy];
}

- (void)addNotification:(INDANCSNotification *)notification
{
	notification.device = self;
	dispatch_barrier_async(self.notificationQueue, ^{
		[_notifications addObject:notification];
		self.notificationMap[@(notification.notificationUID)] = notification;
	});
}

- (void)removeNotification:(INDANCSNotification *)notification
{
	dispatch_barrier_async(self.notificationQueue, ^{
		[_notifications removeObject:notification];
		[self.notificationMap removeObjectForKey:@(notification.notificationUID)];
	});
}

- (void)removeNotificationForUID:(uint32_t)UID
{
	dispatch_barrier_async(self.notificationQueue, ^{
		INDANCSNotification *notification = self.notificationMap[@(UID)];
		[self.notificationMap removeObjectForKey:@(UID)];
		[_notifications removeObject:notification];
	});
}

- (NSMutableOrderedSet *)notificationsSet
{
	return [self mutableOrderedSetValueForKey:@"notifications"];
}

#pragma mark - NSObject

- (NSString *)description
{
	return [NSString stringWithFormat:@"<%@:%p name:%@ modelIdentifier:%@>", NSStringFromClass(self.class), self, self.name, self.modelIdentifier];
}

- (BOOL)isEqual:(id)object
{
	if (object == self) return YES;
	if (![object isMemberOfClass:self.class]) return NO;
	
	INDANCSDevice *device = object;
	return INDANCSEqualObjects(self.identifier, device.identifier);
}

- (NSUInteger)hash
{
	return self.identifier.hash;
}

@end
