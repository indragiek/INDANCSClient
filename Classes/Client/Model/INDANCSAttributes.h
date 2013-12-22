//
//  INDANCSAttributes.h
//  INDANCSMac
//
//  Created by Indragie Karunaratne on 12/22/2013.
//  Copyright (c) 2013 Indragie Karunaratne. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef IND_ANCS_ATTRIBUTES
#define IND_ANCS_ATTRIBUTES

typedef NS_ENUM(uint8_t, INDANCSNotificationAttributeID) {
	INDANCSNotificationAttributeIDAppIdentifier = 0,
	INDANCSNotificationAttributeIDTitle = 1,
	INDANCSNotificationAttributeIDSubtitle = 2,
	INDANCSNotificationAttributeIDMessage = 3,
	INDANCSNotificationAttributeIDMessageSize = 4,
	INDANCSNotificationAttributeIDDate = 5
};

typedef NS_ENUM(uint8_t, INDANCSAppAttributeID) {
	INDANCSAppAttributeIDDisplayName = 0
};

#endif