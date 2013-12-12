//
//  INDANCSServer.m
//  INDANCSClient
//
//  Created by Indragie Karunaratne on 12/11/2013.
//  Copyright (c) 2013 Indragie Karunaratne. All rights reserved.
//

#import "INDANCSServer.h"

@interface INDANCSServer () <CBPeripheralManagerDelegate>
@property (nonatomic, strong) CBPeripheralManager *manager;
@property (nonatomic, assign) BOOL shouldAdvertise;
@end

@implementation INDANCSServer

#pragma mark - Initialization

- (void)startAdvertising
{
	self.shouldAdvertise = YES;
	if (self.manager.state == CBCentralManagerStatePoweredOn &&  self.manager.isAdvertising == NO) {
		[self.manager startAdvertising:@{<#key#>: <#object, ...#>}]
	}
}

- (void)stopAdvertising
{
	self.shouldAdvertise = NO;
}


#pragma mark - CBPeripheralManagerDelegate

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
	
}

#pragma mark - Accessors

- (void)setShouldAdvertise:(BOOL)shouldAdvertise
{
	_shouldAdvertise = shouldAdvertise;
	
}

- (CBPeripheralManagerState)state
{
	return self.manager.state;
}

+ (NSSet *)keyPathsForValuesAffectingState
{
	return [NSSet setWithObject:@"manager.state"];
}

@end
