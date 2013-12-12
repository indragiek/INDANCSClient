//
//  INDANCSServer.m
//  INDANCSClient
//
//  Created by Indragie Karunaratne on 12/11/2013.
//  Copyright (c) 2013 Indragie Karunaratne. All rights reserved.
//

#import "INDANCSServer.h"
#import "INDANCSDefines.h"

@interface INDANCSServer () <CBPeripheralManagerDelegate>
@property (nonatomic, strong) CBPeripheralManager *manager;
@property (nonatomic) dispatch_queue_t delegateQueue;
@property (nonatomic, assign, readwrite) CBPeripheralManagerState state;
@property (nonatomic, assign) BOOL shouldAdvertise;
@end

@implementation INDANCSServer {
	struct {
		unsigned int didStartAdvertising:1;
	} _delegateFlags;
}

#pragma mark - Initialization

- (id)init
{
	if ((self = [super init])) {
		_delegateQueue = dispatch_queue_create("com.indragie.INDANCSServer.DelegateQueue", DISPATCH_QUEUE_SERIAL);
		_manager = [[CBPeripheralManager alloc] initWithDelegate:self queue:_delegateQueue options:@{CBPeripheralManagerOptionShowPowerAlertKey : @YES}];
	}
	return self;
}

#pragma mark - Advertising

- (void)startAdvertising
{
	self.shouldAdvertise = YES;
	if (self.manager.state == CBCentralManagerStatePoweredOn && self.manager.isAdvertising == NO) {
		NSDictionary *advertisementData = @{CBAdvertisementDataLocalNameKey : UIDevice.currentDevice.name,
											CBAdvertisementDataServiceUUIDsKey : @[IND_ANCS_SV_UUID]};
		[self.manager startAdvertising:advertisementData];
	}
}

- (void)stopAdvertising
{
	self.shouldAdvertise = NO;
	if (self.manager.isAdvertising == YES) {
		[self.manager stopAdvertising];
	}
}

#pragma mark - Accessors

- (void)setDelegate:(id<INDANCSServerDelegate>)delegate
{
	if (_delegate != delegate) {
		_delegate = delegate;
		_delegateFlags.didStartAdvertising = [delegate respondsToSelector:@selector(ANCSServer:didStartAdvertisingWithError:)];
	}
}

- (BOOL)isAdvertising
{
	return self.manager.isAdvertising;
}

+ (NSSet *)keyPathsForValuesAffectingAdvertising
{
	return [NSSet setWithObject:@"manager.isAdvertising"];
}

#pragma mark - CBPeripheralManagerDelegate

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
	self.state = peripheral.state;
	if (self.state == CBPeripheralManagerStatePoweredOn && self.shouldAdvertise) {
		[self startAdvertising];
	} else {
		[self stopAdvertising];
	}
}

- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error
{
	if (_delegateFlags.didStartAdvertising) {
		dispatch_async(dispatch_get_main_queue(), ^{
			[self.delegate ANCSServer:self didStartAdvertisingWithError:error];
		});
	}
}

@end
