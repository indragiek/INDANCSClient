//
//  INDAppDelegate.m
//  INDANCSMac
//
//  Created by Indragie Karunaratne on 12/11/2013.
//  Copyright (c) 2013 Indragie Karunaratne. All rights reserved.
//

#import "INDAppDelegate.h"
#import "INDANCSNotificationTableRowView.h"
#import "INDANCSNotificationTableCellView.h"
#import <INDANCSClient/INDANCSClientFramework.h>

@interface INDAppDelegate () <INDANCSClientDelegate, NSTableViewDataSource, NSTableViewDelegate, NSUserNotificationCenterDelegate>
@property (nonatomic, strong) INDANCSClient *client;
@property (nonatomic, weak) IBOutlet NSTableView *tableView;
@property (nonatomic, strong) NSMutableArray *notifications;
@end

@implementation INDAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	self.notifications = [NSMutableArray array];
	self.client = [[INDANCSClient alloc] init];
	self.client.delegate = self;
	NSUserNotificationCenter.defaultUserNotificationCenter.delegate = self;
	
	[self.client scanForDevices:^(INDANCSClient *client, INDANCSDevice *device) {
		[self handleNewDevice:device];
		[client registerForNotificationsFromDevice:device withBlock:^(INDANCSClient *c, INDANCSNotification *n) {
			[self handleNewNotification:n];
		}];
	}];
}

- (void)handleNewDevice:(INDANCSDevice *)device
{
	NSLog(@"Found device: %@", device.name);
	NSUserNotification *notification = [[NSUserNotification alloc] init];
	notification.title = @"Found iOS Device";
	notification.informativeText = [NSString stringWithFormat:@"Registered for notifications from %@", device.name];
	[NSUserNotificationCenter.defaultUserNotificationCenter deliverNotification:notification];
}

- (void)handleNewNotification:(INDANCSNotification *)n
{
	switch (n.latestEventID) {
		case INDANCSEventIDNotificationAdded:
			[self.notifications insertObject:n atIndex:0];
			[self.tableView insertRowsAtIndexes:[NSIndexSet indexSetWithIndex:0] withAnimation:NSTableViewAnimationSlideLeft];
			[self postUserNotificationWithANCSNotification:n];
			break;
		case INDANCSEventIDNotificationRemoved: {
			NSUInteger index = [self.notifications indexOfObject:n];
			if (index != NSNotFound) {
				[self.notifications removeObjectAtIndex:index];
				[self.tableView removeRowsAtIndexes:[NSIndexSet indexSetWithIndex:index] withAnimation:NSTableViewAnimationSlideLeft];
			}
			break;
		}
		case INDANCSEventIDNotificationModified: {
			NSUInteger index = [self.notifications indexOfObject:n];
			if (index != NSNotFound) {
				[self.notifications replaceObjectAtIndex:index withObject:n];
				[self.tableView reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:index] columnIndexes:[NSIndexSet indexSetWithIndex:0]];
				[self postUserNotificationWithANCSNotification:n];
			}
			break;
		}
		default:
			break;
	}
}

- (void)postUserNotificationWithANCSNotification:(INDANCSNotification *)n
{
	NSUserNotification *notification = [[NSUserNotification alloc] init];
	notification.title = n.title;
	notification.subtitle = n.device.name;
	if (n.subtitle) {
		notification.informativeText = [NSString stringWithFormat:@"%@\n%@", n.subtitle, n.message];
	} else {
		notification.informativeText = n.message;
	}
	[NSUserNotificationCenter.defaultUserNotificationCenter deliverNotification:notification];
}

#pragma mark - INDANCSClientDelegate

- (void)ANCSClient:(INDANCSClient *)client device:(INDANCSDevice *)device disconnectedWithError:(NSError *)error
{
	NSLog(@"%@ disconnected with error: %@", device.name, error);
	NSMutableIndexSet *removalIndexes = [NSMutableIndexSet indexSet];
	[self.notifications enumerateObjectsUsingBlock:^(INDANCSNotification *n, NSUInteger idx, BOOL *stop) {
		if (n.device == device) {
			[removalIndexes addIndex:idx];
		}
	}];
	[self.notifications removeObjectsAtIndexes:removalIndexes];
	[self.tableView removeRowsAtIndexes:removalIndexes withAnimation:NSTableViewAnimationSlideLeft];
}

- (void)ANCSClient:(INDANCSClient *)client device:(INDANCSDevice *)device failedToConnectWithError:(NSError *)error
{
	NSLog(@"%@ failed to connect with error: %@", device.name, error);
}

- (void)ANCSClient:(INDANCSClient *)client serviceDiscoveryFailedForDevice:(INDANCSDevice *)device withError:(NSError *)error
{
	NSLog(@"Service discovery failed for %@ with error %@", device.name, error);
}

#pragma mark - NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
	return self.notifications.count;
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
	return self.notifications[rowIndex];
}

#pragma mark - NSTableViewDelegate

- (NSTableRowView *)tableView:(NSTableView *)tableView rowViewForRow:(NSInteger)row
{
	return [[INDANCSNotificationTableRowView alloc] initWithFrame:NSZeroRect];
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	static NSString *cellIdentifier = @"ANCSCell";
	INDANCSNotification *notification = self.notifications[row];
	INDANCSNotificationTableCellView *cellView = [tableView makeViewWithIdentifier:cellIdentifier owner:self];
	cellView.textField.stringValue = notification.title ?: @"";
	cellView.deviceLabel.stringValue = notification.device.name ?: @"";
	cellView.messageLabel.stringValue = notification.message ?: @"";
	return cellView;
}

#pragma mark - NSUserNotificationCenterDelegate

- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification
{
	return YES;
}

@end
