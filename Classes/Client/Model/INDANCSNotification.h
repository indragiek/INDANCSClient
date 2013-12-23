//
//  INDANCSNotification.h
//  INDANCSMac
//
//  Created by Indragie Karunaratne on 12/12/2013.
//  Copyright (c) 2013 Indragie Karunaratne. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(uint8_t, INDANCSCategoryID) {
	INDANCSCategoryIDOther = 0,
	INDANCSCategoryIDIncomingCall = 1,
	INDANCSCategoryIDMissedCall = 2,
	INDANCSCategoryIDVoicemail = 3,
	INDANCSCategoryIDSocial = 4,
	INDANCSCategoryIDSchedule = 5,
	INDANCSCategoryIDEmail = 6,
	INDANCSCategoryIDNews = 7,
	INDANCSCategoryIDHealthAndFitness = 8,
	INDANCSCategoryIDBusinessAndFinance = 9,
	INDANCSCategoryIDLocation = 10,
	INDANCSCategoryIDEntertainment = 11
};

typedef NS_ENUM(uint8_t, INDANCSEventID) {
	INDANCSEventIDNotificationAdded = 0,
	INDANCSEventIDNotificationModified = 1,
	INDANCSEventIDNotificationRemoved = 2
};

@class INDANCSApplication;
@class INDANCSDevice;

/**
 *  Model object representing a push notification received from an iOS device.
 */
@interface INDANCSNotification : NSObject <NSCoding>
/**
 *  The device the notification originated from.
 */
@property (weak, readonly) INDANCSDevice *device;
/**
 *  The event ID of the latest event received for the notification.
 */
@property (assign, readonly) INDANCSEventID latestEventID;
/**
 *  Whether the notification was silent.
 */
@property (assign, readonly) BOOL silent;

/**
 *  Whether the notification was flagged as important.
 */
@property (assign, readonly) BOOL important;

/**
 *  The category in which the iOS notification can be classified.
 */
@property (assign, readonly) INDANCSCategoryID categoryID;

/**
 *  The current number of active iOS notifications in the given category.
 */
@property (assign, readonly) uint8_t categoryCount;

/**
 *  A 32-bit numerical value that is the unique identifier (UID) for the 
 *  iOS notification.
 */
@property (assign, readonly) uint32_t notificationUID;

/**
 *  The application that posted the notification.
 */
@property (strong, readonly) INDANCSApplication *application;

/**
 *  The title of the notification.
 */
@property (strong, readonly) NSString *title;

/**
 *  The subtitle of the notification.
 */
@property (strong, readonly) NSString *subtitle;

/**
 *  The notification message.
 */
@property (strong, readonly) NSString *message;

/**
 *  The date the notification was posted.
 */
@property (strong, readonly) NSDate *date;
@end
