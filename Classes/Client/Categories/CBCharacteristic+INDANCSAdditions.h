//
//  CBCharacteristic+INDANCSAdditions.h
//  INDANCSMac
//
//  Created by Indragie Karunaratne on 12/14/2013.
//  Copyright (c) 2013 Indragie Karunaratne. All rights reserved.
//

#import <IOBluetooth/IOBluetooth.h>

@interface CBCharacteristic (INDANCSAdditions)
/**
 *  Returns the `NSString` value of UTF8 encoded string data in 
 *  the receiver. Returns an empty string if the value is `nil`.
 */
@property (nonatomic, strong, readonly) NSString *ind_stringValue;
@end
