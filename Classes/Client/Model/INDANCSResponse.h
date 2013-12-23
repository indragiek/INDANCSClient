//
//  INDANCSResponse.h
//  INDANCSMac
//
//  Created by Indragie Karunaratne on 12/22/2013.
//  Copyright (c) 2013 Indragie Karunaratne. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "INDANCSAttributes.h"

/**
 *  Model object for reading ANCS data source responses.
 */
@interface INDANCSResponse : NSObject

/**
 *  The command ID of the response. 
 *
 *  @discussion The return value of this method while the response is not complete
 *  is undefined.
 */
@property (nonatomic, assign, readonly) INDANCSCommandID commandID;

/**
 *  The notification UID if the response is for a Get Notification Attributes
 *  command.
 *
 *  @discussion The return value of this method while the response is not complete
 *  is undefined.
 */
@property (nonatomic, assign, readonly) uint32_t notificationUID;

/**
 *  The bundle identifier if the response is for a Get App Attributes
 *  command.
 *
 *  @discussion Returns `nil` if the response is not complete.
 */
@property (nonatomic, strong, readonly) NSString *bundleIdentifier;

/**
 *  Whether the response is complete or requires more data.
 */
@property (nonatomic, assign, readonly, getter = isComplete) BOOL complete;

/**
 *  The raw response data.
 */
@property (nonatomic, strong, readonly) NSData *responseData;

/**
 *  Extraneous data that was not part of the notification response.
 *
 *  @discussion Returns `nil` if the response is not complete.
 */
@property (nonatomic, strong, readonly) NSData *extraneousData;

/**
 *  All attribute values contained in the response, keyed by attribute ID.
 *
 *  @discussion Returns `nil` if the response is not complete.
 */
@property (nonatomic, strong, readonly) NSDictionary *allAttributes;

/**
 *  Creates a new instance of `INDANCSResponse`.
 *
 *  @param count The number of attributes to expect in the response.
 *
 *  @return A new instance of `INDANCSResponse`.
 */
+ (instancetype)responseWithExpectedAttributeCount:(NSUInteger)count;

/**
 *  Returns the string value for the specified attributeID, or nil
 *  if no such attribute was included in the response.
 *
 *  @discussion When `-isComplete` returns `NO`, this method will always
 *  return `nil`.
 *
 *  @param attributeID The attribute ID.
 *
 *  @return The value for the specified attribute ID.
 */
- (NSString *)valueForAttributeID:(uint8_t)attributeID;

/**
 *  Appends received response data to the data buffer. 
 *
 *  @discussion Use the `complete` property to determine whether the
 *  response data is complete.
 *
 *  @param data The data to append.
 */
- (void)appendData:(NSData *)data;

@end
