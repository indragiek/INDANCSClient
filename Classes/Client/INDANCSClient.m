//
//  INDANCSClient.m
//  INDANCSClient
//
//  Created by Indragie Karunaratne on 12/11/2013.
//  Copyright (c) 2013 Indragie Karunaratne. All rights reserved.
//

#import "INDANCSClient.h"
#import "INDANCSDevice_Private.h"
#import "INDANCSNotification_Private.h"
#import "NSData+INDANCSAdditions.h"

typedef NS_ENUM(uint8_t, INDANCSEventFlags) {
	INDANCSEventFlagSilent = (1 << 0),
	INDANCSEventFlagImportant = (1 << 1)
};

typedef NS_ENUM(uint8_t, INDANCSCommandID) {
	INDANCSCommandIDGetNotificationAttributes = 0,
	INDANCSCommandIDGetAppAttributes = 1
};

typedef NS_ENUM(uint8_t, INDANCSNotificationAttributeID) {
	INDANCSNotificationAttributeIDAppIdentifier = 0,
	INDANCSNotificationAttributeIDTitle = 1,
	INDANCSNotificationAttributeIDSubtitle = 2,
	INDANCSNotificationAttributeIDMessage = 3,
	INDANCSNotificationAttributeIDMessageSize = 4,
	INDANCSNotificationAttributeIDDate = 5
};

typedef NS_ENUM(uint8_t, INDANCSAppAttributeID) {
	INDANCSAppAttributeIDDisplayName = 0
};

@interface INDANCSClient () <CBCentralManagerDelegate, CBPeripheralDelegate>
@property (nonatomic, strong, readonly) CBCentralManager *manager;
@property (nonatomic, assign, readwrite) CBCentralManagerState state;

@property (nonatomic) dispatch_queue_t delegateQueue;
@property (nonatomic) dispatch_queue_t stateQueue;

@property (nonatomic, strong, readwrite) NSMutableArray *powerOnBlocks;
@property (nonatomic, strong, readonly) NSMutableDictionary *devices;
@property (nonatomic, strong, readonly) NSMutableDictionary *notifications;
@property (nonatomic, assign) BOOL ready;
@end

@implementation INDANCSClient {
	struct {
		unsigned int didFindDevice:1;
		unsigned int deviceDisconnectedWithError:1;
		unsigned int serviceDiscoveryFailedForDeviceWithError:1;
		unsigned int deviceFailedToConnectWithError:1;
	} _delegateFlags;
}

#pragma mark - Initialization

- (id)init
{
	if ((self = [super init])) {
		_devices = [NSMutableDictionary dictionary];
		_notifications = [NSMutableDictionary dictionary];
		_powerOnBlocks = [NSMutableArray array];
		_delegateQueue = dispatch_queue_create("com.indragie.INDANCSClient.DelegateQueue", DISPATCH_QUEUE_SERIAL);
		_stateQueue = dispatch_queue_create("com.indragie.INDANCSClient.StateQueue", DISPATCH_QUEUE_CONCURRENT);
		_manager = [[CBCentralManager alloc] initWithDelegate:self queue:_delegateQueue options:@{CBCentralManagerOptionShowPowerAlertKey : @YES}];
	}
	return self;
}

#pragma mark - Devices

- (void)scanForDevices
{
	__weak __typeof(self) weakSelf = self;
	[self schedulePowerOnBlock:^{
		__typeof(self) strongSelf = weakSelf;
		[strongSelf.manager scanForPeripheralsWithServices:nil options:nil];
	}];
}

- (void)stopScanning
{
	[self.manager stopScan];
}

#pragma mark - CBCentralManagerDelegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
	self.state = central.state;
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
	peripheral.delegate = self;
	INDANCSDevice *device = [[INDANCSDevice alloc] initWithCBPeripheral:peripheral];
	[self setDevice:device forPeripheral:peripheral];
	
	[central connectPeripheral:peripheral options:nil];
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
	[peripheral discoverServices:@[IND_ANCS_SV_UUID, IND_NAME_SV_UUID]];
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
	INDANCSDevice *device = [self deviceForPeripheral:peripheral];
	if (_delegateFlags.deviceDisconnectedWithError) {
		dispatch_async(dispatch_get_main_queue(), ^{
			[self.delegate ANCSClient:self device:device disconnectedWithError:error];
		});
	}
	[self removeDeviceForPeripheral:peripheral];
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
	INDANCSDevice *device = [self deviceForPeripheral:peripheral];
	if (_delegateFlags.deviceFailedToConnectWithError) {
		dispatch_async(dispatch_get_main_queue(), ^{
			[self.delegate ANCSClient:self device:device failedToConnectWithError:error];
		});
	}
	[self removeDeviceForPeripheral:peripheral];
}

#pragma mark - CBPeripheralDelegate

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
	if (error) {
		[self delegateServiceDiscoveryFailedForPeripheral:peripheral withError:error];
		return;
	}
	NSArray *services = peripheral.services;
	static NSInteger const serviceCount = 2;
	NSMutableArray *foundServices = [NSMutableArray arrayWithCapacity:serviceCount];
	
	if (services.count >= serviceCount) {
		INDANCSDevice *device = [self deviceForPeripheral:peripheral];
		for (CBService *service in services) {
			if ([service.UUID isEqual:IND_ANCS_SV_UUID]) {
				device.ANCSService = service;
				[peripheral discoverCharacteristics:@[IND_ANCS_CP_UUID, IND_ANCS_DS_UUID, IND_ANCS_NS_UUID] forService:service];
				[foundServices addObject:service];
			} else if ([service.UUID isEqual:IND_NAME_SV_UUID]) {
				device.NAMEService = service;
				[peripheral discoverCharacteristics:@[IND_NAME_CH_UUID] forService:service];
				[foundServices addObject:service];
			}
		}
	}
	if (foundServices.count < serviceCount) {
		[self delegateServiceDiscoveryFailedForPeripheral:peripheral withError:nil];
	}
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
	if (error) {
		[self delegateServiceDiscoveryFailedForPeripheral:peripheral withError:error];
		return;
	}
	NSArray *characteristics = service.characteristics;
	INDANCSDevice *device = [self deviceForPeripheral:peripheral];
	CBUUID *serviceUUID = service.UUID;
	if ([serviceUUID isEqual:IND_NAME_SV_UUID]) {
		CBCharacteristic *NAMECharacteristic = nil;
		for (CBCharacteristic *characteristic in characteristics) {
			if ([characteristic.UUID isEqual:IND_NAME_CH_UUID]) {
				NAMECharacteristic = characteristic;
				break;
			}
		}
		device.NAMECharacteristic = NAMECharacteristic;
		[peripheral readValueForCharacteristic:NAMECharacteristic];
	} else if ([serviceUUID isEqual:IND_ANCS_SV_UUID]) {
		for (CBCharacteristic *characteristic in characteristics) {
			CBUUID *charUUID = characteristic.UUID;
			if ([charUUID isEqual:IND_ANCS_NS_UUID]) {
				device.NSCharacteristic = characteristic;
				[peripheral setNotifyValue:YES forCharacteristic:characteristic];
			} else if ([charUUID isEqual:IND_ANCS_CP_UUID]) {
				device.CPCharacteristic = characteristic;
			} else if ([charUUID isEqual:IND_ANCS_DS_UUID]) {
				device.DSCharacteristic = characteristic;
				[peripheral setNotifyValue:YES forCharacteristic:characteristic];
			}
		}
	}
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
	INDANCSDevice *device = [self deviceForPeripheral:peripheral];
	if (characteristic == device.NAMECharacteristic) {
		NSString *name = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
		if (name.length) device.name = name;
		if (_delegateFlags.didFindDevice) {
			dispatch_async(dispatch_get_main_queue(), ^{
				[self.delegate ANCSClient:self didFindDevice:device];
			});
		}
	} else if (characteristic == device.NSCharacteristic) {
		uint32_t UID = [self readNotificationWithData:characteristic.value];
		[self requestNotificationAttributesForUID:UID peripheral:peripheral];
	}
}

#pragma mark - R/W

- (uint32_t)readNotificationWithData:(NSData *)notificationData
{
	INDANCSNotification *notification = [INDANCSNotification new];
	NSUInteger offset = 0;
	notification.eventID = [notificationData ind_readUInt8At:&offset];
	uint8_t flags = [notificationData ind_readUInt8At:&offset];
	notification.silent = (flags & INDANCSEventFlagSilent) == INDANCSEventFlagSilent;
	notification.important = (flags & INDANCSEventFlagImportant) == INDANCSEventFlagImportant;
	notification.categoryID = [notificationData ind_readUInt8At:&offset];
	notification.categoryCount = [notificationData ind_readUInt8At:&offset];
	uint32_t UID = [notificationData ind_readUInt32At:&offset];
	notification.notificationUID = UID;
	[self setNotification:notification forUID:UID];
	return UID;
}

- (void)requestNotificationAttributesForUID:(uint32_t)UID peripheral:(CBPeripheral *)peripheral
{
	INDANCSDevice *device = [self deviceForPeripheral:peripheral];
	NSMutableData *data = [NSMutableData dataWithBytes:"\x00" length:1];
	[data appendBytes:&UID length:sizeof(UID)];
	const uint8_t attributeIDs[] = {INDANCSNotificationAttributeIDAppIdentifier,
		INDANCSNotificationAttributeIDTitle,
		INDANCSNotificationAttributeIDSubtitle,
		INDANCSNotificationAttributeIDMessage,
		INDANCSNotificationAttributeIDDate};
	
	const uint16_t maxLen = UINT16_MAX;
	for (int i = 0; i < sizeof(attributeIDs); i++) {
		uint8_t attr = attributeIDs[i];
		[data appendBytes:&attr length:sizeof(attr)];
		if (attr != INDANCSNotificationAttributeIDAppIdentifier && attr != INDANCSNotificationAttributeIDDate) {
			[data appendBytes:&maxLen length:sizeof(maxLen)];
		}
	}
	[peripheral writeValue:data forCharacteristic:device.CPCharacteristic type:CBCharacteristicWriteWithResponse];
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
	if (error == nil) return;
	
	// TODO: Better error handling. Right now it doesn't look at the error code
	// and just tosses notifications for which errors were received.
	NSData *data = characteristic.value;
	NSUInteger offset = 0;
	uint8_t header = [data ind_readUInt8At:&offset];
	if (header == INDANCSCommandIDGetNotificationAttributes) {
		uint32_t UID = [data ind_readUInt32At:&offset];
		[self removeNotificationForUID:UID];
	}
}

#pragma mark - Accessors

- (void)setDelegate:(id<INDANCSClientDelegate>)delegate
{
	if (_delegate != delegate) {
		_delegate = delegate;
		_delegateFlags.didFindDevice = [delegate respondsToSelector:@selector(ANCSClient:didFindDevice:)];
		_delegateFlags.deviceDisconnectedWithError = [delegate respondsToSelector:@selector(ANCSClient:device:disconnectedWithError:)];
		_delegateFlags.serviceDiscoveryFailedForDeviceWithError = [delegate respondsToSelector:@selector(ANCSClient:serviceDiscoveryFailedForDevice:withError:)];
		_delegateFlags.deviceFailedToConnectWithError = [delegate respondsToSelector:@selector(ANCSClient:device:failedToConnectWithError:)];
	}
}

- (void)setState:(CBCentralManagerState)state
{
	_state = state;
	self.ready = (state == CBCentralManagerStatePoweredOn);
}

- (void)setReady:(BOOL)ready
{
	_ready = ready;
	if (ready && self.powerOnBlocks.count) {
		dispatch_sync(self.stateQueue, ^{
			for (void(^block)() in self.powerOnBlocks) {
				block();
			}
			[self.powerOnBlocks removeAllObjects];
		});
	}
}

#pragma mark - Private

- (void)schedulePowerOnBlock:(void(^)())block
{
	NSParameterAssert(block);
	if (self.ready) {
		block();
	} else {
		dispatch_barrier_async(self.stateQueue, ^{
			[self.powerOnBlocks addObject:[block copy]];
		});
	}
}

- (void)setDevice:(INDANCSDevice *)device forPeripheral:(CBPeripheral *)peripheral
{
	NSParameterAssert(peripheral);
	NSParameterAssert(device);
	dispatch_barrier_async(self.stateQueue, ^{
		self.devices[peripheral.identifier] = device;
	});
}

- (INDANCSDevice *)deviceForPeripheral:(CBPeripheral *)peripheral
{
	NSParameterAssert(peripheral);
	__block INDANCSDevice *device = nil;
	dispatch_sync(self.stateQueue, ^{
		device = self.devices[peripheral.identifier];
	});
	return device;
}

- (void)removeDeviceForPeripheral:(CBPeripheral *)peripheral
{
	NSParameterAssert(peripheral);
	dispatch_barrier_async(self.stateQueue, ^{
		[self.devices removeObjectForKey:peripheral.identifier];
	});
}

- (void)setNotification:(INDANCSNotification *)notification forUID:(uint32_t)UID
{
	NSParameterAssert(notification);
	dispatch_barrier_async(self.stateQueue, ^{
		self.notifications[@(UID)] = notification;
	});
}

- (INDANCSNotification *)notificationForUID:(uint32_t)UID
{
	__block INDANCSNotification *notification = nil;
	dispatch_sync(self.stateQueue, ^{
		notification = self.notifications[@(UID)];
	});
	return notification;
}

- (void)removeNotificationForUID:(uint32_t)UID
{
	dispatch_barrier_async(self.stateQueue, ^{
		[self.notifications removeObjectForKey:@(UID)];
	});
}

- (void)delegateServiceDiscoveryFailedForPeripheral:(CBPeripheral *)peripheral withError:(NSError *)error
{
	INDANCSDevice *device = [self deviceForPeripheral:peripheral];
	if (_delegateFlags.serviceDiscoveryFailedForDeviceWithError) {
		dispatch_async(dispatch_get_main_queue(), ^{
			[self.delegate ANCSClient:self serviceDiscoveryFailedForDevice:device withError:error];
		});
	}
	[self.manager cancelPeripheralConnection:peripheral];
}

@end
