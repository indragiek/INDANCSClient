//
//  INDAppDelegate.m
//  INDANCSMac
//
//  Created by Indragie Karunaratne on 12/11/2013.
//  Copyright (c) 2013 Indragie Karunaratne. All rights reserved.
//

#import "INDAppDelegate.h"
#import "INDANCSClient.h"

@interface INDAppDelegate () <INDANCSClientDelegate>
@property (nonatomic, strong) INDANCSClient *client;
@end

@implementation INDAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	self.client = [INDANCSClient new];
	self.client.delegate = self;
	[self.client scanForDevices:^(INDANCSClient *client, INDANCSDevice *device) {
		NSLog(@"Found %@", device.name);
		[client registerForNotificationsFromDevice:device withBlock:^(INDANCSClient *c, INDANCSDevice *d, INDANCSEventID e, INDANCSNotification *n) {
			NSLog(@"Received notification: %@", n);
		}];
	}];
}

#pragma mark - INDANCSClientDelegate

- (void)ANCSClient:(INDANCSClient *)client device:(INDANCSDevice *)device disconnectedWithError:(NSError *)error
{
	NSLog(@"%@ disconnected with error: %@", device.name, error);
}

- (void)ANCSClient:(INDANCSClient *)client device:(INDANCSDevice *)device failedToConnectWithError:(NSError *)error
{
	NSLog(@"%@ failed to connect with error: %@", device.name, error);
}

- (void)ANCSClient:(INDANCSClient *)client serviceDiscoveryFailedForDevice:(INDANCSDevice *)device withError:(NSError *)error
{
	NSLog(@"Service discovery failed for %@ with error %@", device.name, error);
}

@end
