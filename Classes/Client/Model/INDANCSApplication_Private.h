//
//  INDANCSApplication_Private.h
//  INDANCSMac
//
//  Created by Indragie Karunaratne on 12/13/2013.
//  Copyright (c) 2013 Indragie Karunaratne. All rights reserved.
//

#import "INDANCSApplication.h"

@class INDANCSResponse;
@interface INDANCSApplication ()
/**
 *  Read/write declarations for readonly properties.
 */
@property (nonatomic, strong, readwrite) NSString *bundleIdentifier;
@property (nonatomic, strong, readwrite) NSString *name;

/**
 *  Initializes the receiver using a dictionary containing property keys.
 *
 *  @param bundleID   The bundle identifier of the application.
 *  @param dictionary Dictionary containing values for property keys.
 *
 *  @return A new instance of `INDANCSApplication`.
 */
- (id)initWithBundleIdentifier:(NSString *)bundleID dictionary:(NSDictionary *)dictionary;

/**
 *  Initializes the receiver using a response to a Get App Attributes
 *  request.
 *
 *  @param response The response.
 *
 *  @return A new instance of `INDANCSApplication`.
 */
- (id)initWithAppAttributeResponse:(INDANCSResponse *)response;

@end
