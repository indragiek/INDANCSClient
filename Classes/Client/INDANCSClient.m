//
//  INDANCSClient.m
//  INDANCSClient
//
//  Created by Indragie Karunaratne on 12/11/2013.
//  Copyright (c) 2013 Indragie Karunaratne. All rights reserved.
//

#import "INDANCSClient.h"

static CBUUID * ind_CBUUID(NSString *str) {
	return [CBUUID UUIDWithString:str];
}

#define IND_ANCS_SV_UUID ind_CBUUID(@"7905F431-B5CE-4E99-A40F-4B1E122D00D0")
#define IND_ANCS_NS_UUID ind_CBUUID(@"9FBF120D-6301-42D9-8C58-25E699A21DBD")
#define IND_ANCS_CP_UUID ind_CBUUID(@"69D1D8F3-45E1-49A8-9821-9BBDFDAAD9D9")
#define IND_ANCS_DS_UUID ind_CBUUID(@"22EAC6E9-24D6-4BB5-BE44-B36ACE7C7BFB")

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
		NSLog(@"SCANNING");
		[strongSelf.manager scanForPeripheralsWithServices:nil options:nil];
	}];
}

#pragma mark - CBCentralManagerDelegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
	self.state = central.state;
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
	NSLog(@"%@", peripheral);
	NSLog(@"%@", advertisementData);
	NSLog(@"%@", RSSI);
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
