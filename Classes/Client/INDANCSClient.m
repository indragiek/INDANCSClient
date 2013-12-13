//
//  INDANCSClient.m
//  INDANCSClient
//
//  Created by Indragie Karunaratne on 12/11/2013.
//  Copyright (c) 2013 Indragie Karunaratne. All rights reserved.
//

#import "INDANCSClient.h"
#import "INDANCSDevice_Private.h"

@interface INDANCSClient () <CBCentralManagerDelegate, CBPeripheralDelegate>
@property (nonatomic, strong, readonly) CBCentralManager *manager;

@property (nonatomic) dispatch_queue_t delegateQueue;
@property (nonatomic, strong, readwrite) NSMutableArray *powerOnBlocks;
@property (nonatomic, assign, readwrite) CBCentralManagerState state;
@property (nonatomic, strong, readonly) NSMutableDictionary *devices;
@property (nonatomic, assign) BOOL ready;
@end

@implementation INDANCSClient {
	struct {
		unsigned int didFindDevice:1;
		unsigned int deviceDisconnectedWithError:1;
	} _delegateFlags;
}

#pragma mark - Initialization

- (id)init
{
	if ((self = [super init])) {
		_devices = [NSMutableDictionary dictionary];
		_powerOnBlocks = [NSMutableArray array];
		_delegateQueue = dispatch_queue_create("com.indragie.INDANCSClient.DelegateQueue", DISPATCH_QUEUE_SERIAL);
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
	
	[central connectPeripheral:peripheral options:@{CBConnectPeripheralOptionNotifyOnDisconnectionKey : @YES}];
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
	[peripheral discoverServices:@[IND_ANCS_SV_UUID, IND_NAME_SV_UUID]];
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
	INDANCSDevice *device = [self deviceForPeripheral:peripheral];
	[self removeDeviceForPeripheral:peripheral];
	
	if (_delegateFlags.deviceDisconnectedWithError) {
		[self.delegate ANCSClient:self device:device disconnectedWithError:error];
	}
}

#pragma mark - CBPeripheralDelegate

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
	// TODO: Add delegate error callback
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
		[self.manager cancelPeripheralConnection:peripheral];
	}
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
	// TODO: Add delegate error callback
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
			} else if ([charUUID isEqual:IND_ANCS_CP_UUID]) {
				device.CPCharacteristic = characteristic;
			} else if ([charUUID isEqual:IND_ANCS_DS_UUID]) {
				device.DSCharacteristic = characteristic;
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
	}
}

#pragma mark - Accessors

- (void)setDelegate:(id<INDANCSClientDelegate>)delegate
{
	if (_delegate != delegate) {
		_delegate = delegate;
		_delegateFlags.didFindDevice = [delegate respondsToSelector:@selector(ANCSClient:didFindDevice:)];
		_delegateFlags.deviceDisconnectedWithError = [delegate respondsToSelector:@selector(ANCSClient:device:disconnectedWithError:)];
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
		for (void(^block)() in self.powerOnBlocks) {
			block();
		}
		[self.powerOnBlocks removeAllObjects];
	}
}

#pragma mark - Private

- (void)schedulePowerOnBlock:(void(^)())block
{
	NSParameterAssert(block);
	if (self.ready) {
		block();
	} else {
		[self.powerOnBlocks addObject:[block copy]];
	}
}

- (void)setDevice:(INDANCSDevice *)device forPeripheral:(CBPeripheral *)peripheral
{
	NSParameterAssert(peripheral);
	@synchronized(self) {
		self.devices[peripheral.identifier] = device;
	}
}

- (INDANCSDevice *)deviceForPeripheral:(CBPeripheral *)peripheral
{
	NSParameterAssert(peripheral);
	return self.devices[peripheral.identifier];
}

- (void)removeDeviceForPeripheral:(CBPeripheral *)peripheral
{
	NSParameterAssert(peripheral);
	@synchronized(self) {
		[self.devices removeObjectForKey:peripheral.identifier];
	}
}

@end
