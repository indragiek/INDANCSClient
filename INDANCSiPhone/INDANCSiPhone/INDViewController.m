//
//  INDViewController.m
//  INDANCSiPhone
//
//  Created by Indragie Karunaratne on 12/11/2013.
//  Copyright (c) 2013 Indragie Karunaratne. All rights reserved.
//

#import "INDViewController.h"

@interface INDViewController ()

@end

@implementation INDViewController

- (IBAction)postNotification:(id)sender
{
	UILocalNotification *notification = [[UILocalNotification alloc] init];
	notification.alertBody = @"Test Notification";
	[[UIApplication sharedApplication] presentLocalNotificationNow:notification];
}

@end
