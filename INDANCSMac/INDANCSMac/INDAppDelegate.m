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
	[self.client scanForDevices];
}

#pragma mark - INDANCSClientDelegate

- (void)ANCSClient:(INDANCSClient *)client didFindDevice:(INDANCSDevice *)device
{
	NSLog(@"%@", device);
}

@end
