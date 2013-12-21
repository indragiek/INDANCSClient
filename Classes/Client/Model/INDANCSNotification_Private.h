//
//  INDANCSNotification_Private.h
//  INDANCSMac
//
//  Created by Indragie Karunaratne on 12/12/2013.
//  Copyright (c) 2013 Indragie Karunaratne. All rights reserved.
//

#import "INDANCSNotification.h"

@interface INDANCSNotification ()
@property (nonatomic, weak, readwrite) INDANCSDevice *device;
@property (nonatomic, assign, readwrite) INDANCSEventID latestEventID;
@property (nonatomic, assign, readwrite) BOOL silent;
@property (nonatomic, assign, readwrite) BOOL important;
@property (nonatomic, assign, readwrite) INDANCSCategoryID categoryID;
@property (nonatomic, assign, readwrite) uint8_t categoryCount;
@property (nonatomic, assign, readwrite) uint32_t notificationUID;
@property (nonatomic, strong, readwrite) INDANCSApplication *application;
@property (nonatomic, strong, readwrite) NSString *title;
@property (nonatomic, strong, readwrite) NSString *subtitle;
@property (nonatomic, strong, readwrite) NSString *message;
@property (nonatomic, strong, readwrite) NSDate *date;
@end
