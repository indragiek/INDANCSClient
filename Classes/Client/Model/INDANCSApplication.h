//
//  INDANCSApplication.h
//  INDANCSMac
//
//  Created by Indragie Karunaratne on 12/12/2013.
//  Copyright (c) 2013 Indragie Karunaratne. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "INDANCSDictionarySerialization.h"

/**
 *  Model object representing an iOS application that posted a notification.
 */
@interface INDANCSApplication : NSObject <NSCoding, INDANCSDictionarySerialization>

/**
 *  The bundle identifier of the application.
 */
@property (nonatomic, strong, readonly) NSString *bundleIdentifier;

/**
 *  The display name of the application.
 */
@property (nonatomic, strong, readonly) NSString *name;

@end
