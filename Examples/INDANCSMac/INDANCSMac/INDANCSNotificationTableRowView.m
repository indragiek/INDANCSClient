//
//  INDANCSNotificationTableRowView.m
//  INDANCSMac
//
//  Created by Indragie Karunaratne on 12/22/2013.
//  Copyright (c) 2013 Indragie Karunaratne. All rights reserved.
//

#import "INDANCSNotificationTableRowView.h"

@implementation INDANCSNotificationTableRowView

- (void)drawBackgroundInRect:(NSRect)dirtyRect
{
	[super drawBackgroundInRect:dirtyRect];
	NSRect separatorRect = NSMakeRect(0, NSMaxY(self.bounds) - 1, NSWidth(self.bounds), 1);
	[[NSColor grayColor] set];
	NSRectFill(separatorRect);
}

@end
