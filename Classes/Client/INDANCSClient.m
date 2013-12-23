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
#import "INDANCSApplication_Private.h"
#import "INDANCSApplicationStorage.h"
#import "INDANCSObjectiveKVDBStore.h"
#import "INDANCSRequest.h"
#import "INDANCSResponse.h"

#import "NSData+INDANCSAdditions.h"
#import "CBCharacteristic+INDANCSAdditions.h"

// Uncomment to enable debug logging
// #define DEBUG_LOGGING

static NSUInteger const INDANCSGetNotificationAttributeCount = 5;
static NSUInteger const INDANCSGetAppAttributeCount = 1;
static NSString * const INDANCSDeviceUserInfoKey = @"device";
static NSString * const INDANCSMetadataStoreFilename = @"ANCSMetadata.db";
static NSString * const INDANCSBlacklistStoreFilename = @"ANCSBlacklist.db";

@interface INDANCSClient () <CBCentralManagerDelegate, CBPeripheralDelegate>
@property (nonatomic, strong, readonly) CBCentralManager *manager;
@property (nonatomic, assign, readwrite) CBCentralManagerState state;
@property (nonatomic, strong, readonly) INDANCSApplicationStorage *appStorage;
@property (nonatomic, copy) INDANCSDiscoveryBlock discoveryBlock;
@property (nonatomic, readonly) dispatch_queue_t delegateQueue;
@property (nonatomic, strong) NSMutableArray *powerOnBlocks;
@property (nonatomic, strong, readonly) NSMutableDictionary *devices;
@property (nonatomic, strong, readonly) NSMutableSet *validDevices;
@property (nonatomic, strong, readonly) NSMutableDictionary *disconnects;
@end

@implementation INDANCSClient {
	struct {
		unsigned int deviceDisconnectedWithError:1;
		unsigned int serviceDiscoveryFailedForDeviceWithError:1;
		unsigned int deviceFailedToConnectWithError:1;
	} _delegateFlags;
}

#pragma mark - Initialization

- (id)init
{
	NSURL *parentURL = self.applicationSupportURL;
	NSURL *metadataURL = [parentURL URLByAppendingPathComponent:INDANCSMetadataStoreFilename];
	NSURL *blacklistURL = [parentURL URLByAppendingPathComponent:INDANCSBlacklistStoreFilename];
	INDANCSObjectiveKVDBStore *metadata = [[INDANCSObjectiveKVDBStore alloc] initWithDatabasePath:metadataURL.path];
	INDANCSObjectiveKVDBStore *blacklist = [[INDANCSObjectiveKVDBStore alloc] initWithDatabasePath:blacklistURL.path];
	return [self initWithMetadataStore:metadata blacklistStore:blacklist];
}

- (id)initWithMetadataStore:(id<INDANCSKeyValueStore>)metadata blacklistStore:(id<INDANCSKeyValueStore>)blacklist
{
	if ((self = [super init])) {
		_appStorage = [[INDANCSApplicationStorage alloc] initWithMetadataStore:metadata blacklistStore:blacklist];
		_devices = [NSMutableDictionary dictionary];
		_validDevices = [NSMutableSet set];
		_disconnects = [NSMutableDictionary dictionary];
		_powerOnBlocks = [NSMutableArray array];
		_delegateQueue = dispatch_queue_create("com.indragie.INDANCSClient.DelegateQueue", DISPATCH_QUEUE_SERIAL);
		_manager = [[CBCentralManager alloc] initWithDelegate:self queue:_delegateQueue options:@{CBCentralManagerOptionShowPowerAlertKey : @YES}];
		_registrationTimeout = 5.0;
		_attemptAutomaticReconnection = YES;
	}
	return self;
}

- (NSURL *)applicationSupportURL
{
	NSFileManager *fm = NSFileManager.defaultManager;
	NSURL *appSupportURL = [[fm URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] lastObject];
	NSString *bundleName = NSBundle.mainBundle.infoDictionary[@"CFBundleName"];
	NSURL *dataURL = [appSupportURL URLByAppendingPathComponent:bundleName];
	[fm createDirectoryAtURL:dataURL withIntermediateDirectories:YES attributes:nil error:nil];
	return dataURL;
}

#pragma mark - Cleanup

- (void)dealloc
{
	NSArray *devices = self.devices.allValues;
	for (INDANCSDevice *device in devices) {
		[self.manager cancelPeripheralConnection:device.peripheral];
	}
}

#pragma mark - Devices

- (void)scanForDevices:(INDANCSDiscoveryBlock)discoveryBlock
{
	NSParameterAssert(discoveryBlock);
	self.discoveryBlock = discoveryBlock;
	__weak __typeof(self) weakSelf = self;
	[self schedulePowerOnBlock:^{
		__typeof(self) strongSelf = weakSelf;
		[strongSelf.manager scanForPeripheralsWithServices:nil options:@{CBCentralManagerScanOptionAllowDuplicatesKey : @YES}];
	}];
}

- (void)stopScanning
{
	self.discoveryBlock = nil;
	[self.manager stopScan];
}

#pragma mark - Registration

- (void)registerForNotificationsFromDevice:(INDANCSDevice *)device withBlock:(INDANCSNotificationBlock)notificationBlock
{
	device.notificationBlock = notificationBlock;
	CBPeripheralState state = device.peripheral.state;
	switch (state) {
		case CBPeripheralStateConnected:
			[self setNotificationSettingsForDevice:device];
			break;
		case CBPeripheralStateDisconnected:
			[self.manager connectPeripheral:device.peripheral options:nil];
			break;
		default:
			break;
	}
}

- (void)unregisterForNotificationsFromDevice:(INDANCSDevice *)device
{
	device.notificationBlock = nil;
	[self setNotificationSettingsForDevice:device];
}

- (void)setNotificationSettingsForDevice:(INDANCSDevice *)device
{
	[self invalidateRegistrationTimerForDevice:device];
	BOOL notify = (device.notificationBlock != nil);
	CBPeripheral *peripheral = device.peripheral;
	[peripheral setNotifyValue:notify forCharacteristic:device.DSCharacteristic];
	[peripheral setNotifyValue:notify forCharacteristic:device.NSCharacteristic];
	if (!notify) {
		[self startRegistrationTimerForDevice:device];
	}
}

#pragma mark - CBCentralManagerDelegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
#ifdef DEBUG_LOGGING
	NSLog(@"[CBCentralManager] Updated state to: %ld", central.state);
#endif
	self.state = central.state;
	if (self.state == CBCentralManagerStatePoweredOn && self.powerOnBlocks.count) {
		for (void(^block)() in self.powerOnBlocks) {
			block();
		}
		[self.powerOnBlocks removeAllObjects];
	}
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
#ifdef DEBUG_LOGGING
	NSLog(@"[CBCentralManager] Discovered peripheral: %@\nAdvertisement data:%@\nRSSI: %@", peripheral, advertisementData, RSSI);
#endif
	// Already connected, ignore it.
	if (peripheral.state != CBPeripheralStateDisconnected) return;
	
	peripheral.delegate = self;
	INDANCSDevice *device = [self deviceForPeripheral:peripheral];
	if (device == nil) {
		device = [[INDANCSDevice alloc] initWithCBPeripheral:peripheral];
		[self setDevice:device forPeripheral:peripheral];
	}
	[self.manager stopScan];
	[central connectPeripheral:peripheral options:nil];
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
#ifdef DEBUG_LOGGING
	NSLog(@"[CBCentralManager] Did connect to peripheral: %@", peripheral);
#endif
	[peripheral discoverServices:@[IND_ANCS_SV_UUID, IND_DVCE_SV_UUID]];
	if (self.discoveryBlock) {
		[self.manager scanForPeripheralsWithServices:nil options:@{CBCentralManagerScanOptionAllowDuplicatesKey : @YES}];
	}
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
#ifdef DEBUG_LOGGING
	NSLog(@"[CBCentralManager] Did disconnect peripheral: %@\nError: %@", peripheral, error);
#endif
	INDANCSDevice *device = [self deviceForPeripheral:peripheral];
	if ([self.validDevices containsObject:device]) {
		if (_delegateFlags.deviceDisconnectedWithError) {
			dispatch_async(dispatch_get_main_queue(), ^{
				[self.delegate ANCSClient:self device:device disconnectedWithError:error];
			});
		}
		[self.validDevices removeObject:device];
	}
	
	BOOL didDisconnect = [self didDisconnectForPeripheral:peripheral];
	if (self.attemptAutomaticReconnection && !didDisconnect) {
		[self.manager connectPeripheral:peripheral options:nil];
	} else {
		if (didDisconnect) {
			[self setDidDisconnect:NO forPeripheral:peripheral];
		}
		[self removeDeviceForPeripheral:peripheral];
	}
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
#ifdef DEBUG_LOGGING
	NSLog(@"[CBCentralManager] Did fail to connect to peripheral: %@\nError: %@", peripheral, error);
#endif
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
#ifdef DEBUG_LOGGING
	NSLog(@"[%@] Did discover services: %@\nError: %@", peripheral, peripheral.services, error);
#endif
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
			} else if ([service.UUID isEqual:IND_DVCE_SV_UUID]) {
				device.DVCEService = service;
				[peripheral discoverCharacteristics:@[IND_DVCE_NM_UUID, IND_DVCE_ML_UUID] forService:service];
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
#ifdef DEBUG_LOGGING
	NSLog(@"[%@] Did discover characteristics: %@\nService: %@\nError: %@", peripheral, service.characteristics, service, error);
#endif
	if (error) {
		[self delegateServiceDiscoveryFailedForPeripheral:peripheral withError:error];
		return;
	}
	NSArray *characteristics = service.characteristics;
	INDANCSDevice *device = [self deviceForPeripheral:peripheral];
	CBUUID *serviceUUID = service.UUID;
	if ([serviceUUID isEqual:IND_DVCE_SV_UUID]) {
		for (CBCharacteristic *characteristic in characteristics) {
			CBUUID *charUUID = characteristic.UUID;
			if ([charUUID isEqual:IND_DVCE_NM_UUID]) {
				device.NMCharacteristic = characteristic;
			} else if ([charUUID isEqual:IND_DVCE_ML_UUID]) {
				device.MLCharacteristic = characteristic;
			}
		}
		[peripheral readValueForCharacteristic:device.NMCharacteristic];
		[peripheral readValueForCharacteristic:device.MLCharacteristic];
	} else if ([serviceUUID isEqual:IND_ANCS_SV_UUID]) {
		for (CBCharacteristic *characteristic in characteristics) {
			CBUUID *charUUID = characteristic.UUID;
			if ([charUUID isEqual:IND_ANCS_DS_UUID]) {
				device.DSCharacteristic = characteristic;
			} else if ([charUUID isEqual:IND_ANCS_NS_UUID]) {
				device.NSCharacteristic = characteristic;
			} else if ([charUUID isEqual:IND_ANCS_CP_UUID]) {
				device.CPCharacteristic = characteristic;
			}
		}
		[self setNotificationSettingsForDevice:device];
	}
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
#ifdef DEBUG_LOGGING
	NSLog(@"[%@] Did update value: %@ for characteristic: %@\nError: %@", peripheral, characteristic.value, characteristic, error);
#endif
	INDANCSDevice *device = [self deviceForPeripheral:peripheral];
	if (characteristic == device.NMCharacteristic) {
		device.name = characteristic.ind_stringValue;
		[self handleDiscoveryForDevice:device];
	} else if (characteristic == device.MLCharacteristic) {
		device.modelIdentifier = characteristic.ind_stringValue;
		[self handleDiscoveryForDevice:device];
	} else if (characteristic == device.NSCharacteristic) {
		INDANCSNotification *notification = [self readNotificationWithData:characteristic.value device:device];
		if (notification.latestEventID == INDANCSEventIDNotificationRemoved) {
			[self notifyWithNotification:notification forDevice:device];
			[device removeNotification:notification];
		} else {
			[self requestNotificationAttributesForUID:notification.notificationUID peripheral:peripheral];
		}
	} else if (characteristic == device.DSCharacteristic) {
		INDANCSResponse *response = [device appendDSResponseData:characteristic.value];
		if (response == nil) return;
		
		if (response.commandID == INDANCSCommandIDGetNotificationAttributes) {
			INDANCSNotification *notification = [device notificationForUID:response.notificationUID];
			[notification mergeAttributesFromNotificationAttributeResponse:response];
			[self notifyWithNotification:notification forDevice:device];
		}
	}
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
	if (error == nil) return;
#ifdef DEBUG_LOGGING
	NSLog(@"[%@] Received error: %@ when writing to characteristic: %@", peripheral, error, characteristic);
#endif
	// TODO: Better error handling. Right now it doesn't look at the error code
	// and just tosses notifications for which errors were received.
	NSData *data = characteristic.value;
	NSUInteger offset = 0;
	uint8_t header = [data ind_readUInt8At:&offset];
	if (header == INDANCSCommandIDGetNotificationAttributes) {
		uint32_t UID = [data ind_readUInt32At:&offset];
		INDANCSDevice *device = [self deviceForPeripheral:peripheral];
		[device removeNotificationForUID:UID];
	}
}

- (void)delegateServiceDiscoveryFailedForPeripheral:(CBPeripheral *)peripheral withError:(NSError *)error
{
	INDANCSDevice *device = [self deviceForPeripheral:peripheral];
	if (_delegateFlags.serviceDiscoveryFailedForDeviceWithError) {
		dispatch_async(dispatch_get_main_queue(), ^{
			[self.delegate ANCSClient:self serviceDiscoveryFailedForDevice:device withError:error];
		});
	}
	if (peripheral.state == CBPeripheralStateConnected) {
		[self disconnectFromPeripheral:peripheral];
	} else if (error.code == 3 && peripheral.state == CBPeripheralStateDisconnected && self.attemptAutomaticReconnection) {
		// CBErrorDomain code 3 usually means that the device was not
		// connected.
		[self.manager connectPeripheral:peripheral options:nil];
	}
}

- (void)handleDiscoveryForDevice:(INDANCSDevice *)device
{
	if (device.name && device.modelIdentifier && ![self.validDevices containsObject:device]) {
		[self.validDevices addObject:device];
		if (self.discoveryBlock) {
			self.discoveryBlock(self, device);
		}
		[self startRegistrationTimerForDevice:device];
	}
}

#pragma mark - Timers

- (void)registrationTimerFired:(NSTimer *)timer
{
	INDANCSDevice *device = timer.userInfo[INDANCSDeviceUserInfoKey];
	[self.manager cancelPeripheralConnection:device.peripheral];
}

- (void)startRegistrationTimerForDevice:(INDANCSDevice *)device
{
	device.registrationTimer = [NSTimer scheduledTimerWithTimeInterval:self.registrationTimeout target:self selector:@selector(registrationTimerFired:) userInfo:@{INDANCSDeviceUserInfoKey : device} repeats:NO];
}

- (void)invalidateRegistrationTimerForDevice:(INDANCSDevice *)device
{
	[device.registrationTimer invalidate];
	device.registrationTimer = nil;
}

#pragma mark - R/W

- (void)notifyWithNotification:(INDANCSNotification *)notification forDevice:(INDANCSDevice *)device
{
	INDANCSNotificationBlock notificationBlock = device.notificationBlock;
	if (notificationBlock) {
		notificationBlock(self, device, notification.latestEventID, notification);
	}
}

- (INDANCSNotification *)readNotificationWithData:(NSData *)notificationData device:(INDANCSDevice *)device
{
	NSUInteger offset = sizeof(uint8_t) * 4; // Skip straight to the UID
	uint32_t UID = [notificationData ind_readUInt32At:&offset];
	
	INDANCSNotification *notification = [device notificationForUID:UID];
	if (notification == nil) {
		notification = [[INDANCSNotification alloc] initWithUID:UID];
		[device addNotification:notification];
	}
	[notification mergeAttributesFromGATTNotificationData:notificationData];
	return notification;
}

- (void)requestNotificationAttributesForUID:(uint32_t)UID peripheral:(CBPeripheral *)peripheral
{
	INDANCSDevice *device = [self deviceForPeripheral:peripheral];
	INDANCSRequest *request = [INDANCSRequest getNotificationAttributesRequestWithUID:UID];
	
	const INDANCSNotificationAttributeID attributeIDs[INDANCSGetNotificationAttributeCount] = {
		INDANCSNotificationAttributeIDAppIdentifier,
		INDANCSNotificationAttributeIDTitle,
		INDANCSNotificationAttributeIDSubtitle,
		INDANCSNotificationAttributeIDMessage,
		INDANCSNotificationAttributeIDDate,
	};
	const uint16_t maxLen = UINT16_MAX;
	for (int i = 0; i < INDANCSGetNotificationAttributeCount; i++) {
		INDANCSNotificationAttributeID attr = attributeIDs[i];
		BOOL includeMax = (attr != INDANCSNotificationAttributeIDAppIdentifier && attr != INDANCSNotificationAttributeIDDate);
		[request appendAttributeID:attr maxLength:includeMax ? maxLen : 0];
	}
	[device sendRequest:request];
}

- (void)requestAppAttributesForApplication:(INDANCSApplication *)app peripheral:(CBPeripheral *)peripheral
{
	INDANCSDevice *device = [self deviceForPeripheral:peripheral];
	INDANCSRequest *request = [INDANCSRequest getAppAttributesRequestWithBundleIdentifier:app.bundleIdentifier];
	
	const INDANCSAppAttributeID attributesIDs[INDANCSGetAppAttributeCount] = {
		INDANCSAppAttributeIDDisplayName
	};
	for (int i = 0; i < INDANCSGetAppAttributeCount; i++) {
		[request appendAttributeID:attributesIDs[i] maxLength:0];
	}
	[device sendRequest:request];
}

#pragma mark - Accessors

- (void)setDelegate:(id<INDANCSClientDelegate>)delegate
{
	if (_delegate != delegate) {
		_delegate = delegate;
		_delegateFlags.deviceDisconnectedWithError = [delegate respondsToSelector:@selector(ANCSClient:device:disconnectedWithError:)];
		_delegateFlags.serviceDiscoveryFailedForDeviceWithError = [delegate respondsToSelector:@selector(ANCSClient:serviceDiscoveryFailedForDevice:withError:)];
		_delegateFlags.deviceFailedToConnectWithError = [delegate respondsToSelector:@selector(ANCSClient:device:failedToConnectWithError:)];
	}
}

#pragma mark - State

- (void)schedulePowerOnBlock:(void(^)())block
{
	NSParameterAssert(block);
	if (self.state == CBCentralManagerStatePoweredOn) {
		block();
	} else {
		dispatch_async(self.delegateQueue, ^{
			[self.powerOnBlocks addObject:[block copy]];
		});
	}
}

- (void)setDevice:(INDANCSDevice *)device forPeripheral:(CBPeripheral *)peripheral
{
	NSParameterAssert(peripheral);
	NSParameterAssert(device);
	self.devices[peripheral.identifier] = device;
}

- (INDANCSDevice *)deviceForPeripheral:(CBPeripheral *)peripheral
{
	NSParameterAssert(peripheral);
	return self.devices[peripheral.identifier];
}

- (void)removeDeviceForPeripheral:(CBPeripheral *)peripheral
{
	NSParameterAssert(peripheral);
	[self.devices removeObjectForKey:peripheral.identifier];
}

- (void)setDidDisconnect:(BOOL)disconnect forPeripheral:(CBPeripheral *)peripheral
{
	NSParameterAssert(peripheral);
	if (disconnect) {
		self.disconnects[peripheral.identifier] = @YES;
	} else {
		[self.disconnects removeObjectForKey:peripheral.identifier];
	}
}

- (BOOL)didDisconnectForPeripheral:(CBPeripheral *)peripheral
{
	NSParameterAssert(peripheral);
	return [self.disconnects[peripheral.identifier] boolValue];
}

- (void)disconnectFromPeripheral:(CBPeripheral *)peripheral
{
	[self setDidDisconnect:YES forPeripheral:peripheral];
	[self.manager cancelPeripheralConnection:peripheral];
}

@end
