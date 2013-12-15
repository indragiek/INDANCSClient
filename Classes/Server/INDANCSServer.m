//
//  INDANCSServer.m
//  INDANCSClient
//
//  Created by Indragie Karunaratne on 12/11/2013.
//  Copyright (c) 2013 Indragie Karunaratne. All rights reserved.
//

#import "INDANCSServer.h"
#import "INDANCSDefines.h"
#include <sys/types.h>
#include <sys/sysctl.h>

static NSString * const INDANCSServerRestorationKey = @"INDANCSServer";

@interface INDANCSServer () <CBPeripheralManagerDelegate>
@property (nonatomic, strong) CBPeripheralManager *manager;
@property (nonatomic, strong) CBMutableService *DVCEService;
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

- (id)initWithUID:(NSString *)UID
{
	if ((self = [super init])) {
		_delegateQueue = dispatch_queue_create("com.indragie.INDANCSServer.DelegateQueue", DISPATCH_QUEUE_SERIAL);
		NSMutableDictionary *options = [@{CBPeripheralManagerOptionShowPowerAlertKey : @YES} mutableCopy];
		if (UID.length) {
			options[CBPeripheralManagerOptionRestoreIdentifierKey] = UID;
		}
		_manager = [[CBPeripheralManager alloc] initWithDelegate:self queue:_delegateQueue options:options];
	}
	return self;
}

#pragma mark - Advertising

- (void)startAdvertising
{
	self.shouldAdvertise = YES;
	if (self.manager.state == CBCentralManagerStatePoweredOn && self.manager.isAdvertising == NO) {
		NSDictionary *advertisementData = @{CBAdvertisementDataServiceUUIDsKey : @[IND_ANCS_SV_UUID, IND_DVCE_SV_UUID], CBAdvertisementDataLocalNameKey : UIDevice.currentDevice.name};
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
	if (self.state == CBPeripheralManagerStatePoweredOn) {
		if (self.DVCEService == nil) {
			self.DVCEService = [self newDVCEService];
			[_manager addService:self.DVCEService];
		}
		if (self.shouldAdvertise) {
			[self startAdvertising];
		}
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

- (void)peripheralManager:(CBPeripheralManager *)peripheral willRestoreState:(NSDictionary *)dict
{
}

#pragma mark - NAME Service

+ (NSData *)deviceNameData
{
	return [UIDevice.currentDevice.name dataUsingEncoding:NSUTF8StringEncoding];
}

+ (NSData *)deviceModelData
{
	size_t size = 20;
    char *model = malloc(size);
    int mib[] = {CTL_HW, HW_MACHINE};
    sysctl(mib, 2, model, &size, NULL, 0);
	// Using size - 1 because we want to strip out the terminating null byte, which
	// NSString does not like.
	NSData *data = [NSData dataWithBytes:model length:size - 1];
	free(model);
	return data;
}

- (CBMutableService *)newDVCEService
{
	CBMutableService *service = [[CBMutableService alloc] initWithType:IND_DVCE_SV_UUID primary:YES];
	NSData *nameData = self.class.deviceNameData;
	NSData *modelData = self.class.deviceModelData;
	
	CBMutableCharacteristic *NMCharacteristic = [[CBMutableCharacteristic alloc] initWithType:IND_DVCE_NM_UUID properties:CBCharacteristicPropertyRead value:nameData permissions:CBAttributePermissionsReadable];
	CBMutableCharacteristic *MLCharacteristic = [[CBMutableCharacteristic alloc] initWithType:IND_DVCE_ML_UUID properties:CBCharacteristicPropertyRead value:modelData permissions:CBAttributePermissionsReadable];
	service.characteristics = @[NMCharacteristic, MLCharacteristic];
	return service;
}

@end
