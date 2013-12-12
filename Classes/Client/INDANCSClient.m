//
//  INDANCSClient.m
//  INDANCSClient
//
//  Created by Indragie Karunaratne on 12/11/2013.
//  Copyright (c) 2013 Indragie Karunaratne. All rights reserved.
//

#import "INDANCSClient.h"
#import "INDANCSDefines.h"

@interface INDANCSClient () <CBCentralManagerDelegate>
@property (nonatomic, strong, readonly) CBCentralManager *manager;
@property (nonatomic) dispatch_queue_t delegateQueue;
@property (nonatomic, strong, readwrite) NSMutableArray *powerOnBlocks;
@property (nonatomic, assign, readwrite) CBCentralManagerState state;
@property (nonatomic, assign) BOOL ready;
@end

@implementation INDANCSClient

#pragma mark - Initialization

- (id)init
{
	if ((self = [super init])) {
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
		[strongSelf.manager scanForPeripheralsWithServices:@[IND_ANCS_SV_UUID] options:nil];
	}];
}

#pragma mark - CBCentralManagerDelegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
	self.state = central.state;
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
	
}

#pragma mark - Accessors

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

@end
