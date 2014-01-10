//
//  INDANCSNotificationTableCellView.h
//  INDANCSMac
//
//  Created by Indragie Karunaratne on 1/9/2014.
//  Copyright (c) 2014 Indragie Karunaratne. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface INDANCSNotificationTableCellView : NSTableCellView
@property (nonatomic, weak) IBOutlet NSTextField *deviceLabel;
@property (nonatomic, weak) IBOutlet NSTextField *messageLabel;
@end
