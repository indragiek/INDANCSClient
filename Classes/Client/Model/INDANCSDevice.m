//
//  INDANCSDevice.m
//  INDANCSMac
//
//  Created by Indragie Karunaratne on 12/11/2013.
//  Copyright (c) 2013 Indragie Karunaratne. All rights reserved.
//

#import "INDANCSDevice.h"
#import "INDANCSDevice_Private.h"
#import "INDANCSObjectEquality.h"

@implementation INDANCSDevice

#pragma mark - Initialization

- (id)initWithCBPeripheral:(CBPeripheral *)peripheral
{
	if ((self = [super init])) {
		_peripheral = peripheral;
		self.name = peripheral.name;
	}
	return self;
}

#pragma mark - Accessors

- (NSUUID *)identifier
{
	return self.peripheral.identifier;
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
