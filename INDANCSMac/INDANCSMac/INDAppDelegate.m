//
//  INDAppDelegate.m
//  INDANCSMac
//
//  Created by Indragie Karunaratne on 12/11/2013.
//  Copyright (c) 2013 Indragie Karunaratne. All rights reserved.
//

#import "INDAppDelegate.h"
#import "INDANCSClient.h"

@interface INDAppDelegate ()
@property (nonatomic, strong) INDANCSClient *client;
@end

@implementation INDAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	self.client = [INDANCSClient new];
	[self.client scanForDevices];
}

@end
