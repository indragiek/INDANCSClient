//
//  NSData+INDANCSAdditions.h
//  INDANCSMac
//
//  Created by Indragie Karunaratne on 12/12/2013.
//  Copyright (c) 2013 Indragie Karunaratne. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  Convenience methods for reading bytes from data buffers.
 */
@interface NSData (INDANCSAdditions)
/**
 *  Reads and returns a `uint8_t` at the specified location.
 *
 *  @param offset Pointer to offset to read from. The offset
 *  is incremented after reading the data.
 *
 *  @return The read integer.
 */
- (uint8_t)ind_readUInt8At:(NSUInteger *)offset;

/**
 *  Reads and returns a `uint16_t` at the specified location.
 *
 *  @param offset Pointer to offset to read from. The offset
 *  is incremented after reading the data.
 *
 *  @return The read integer.
 */
- (uint16_t)ind_readUInt16At:(NSUInteger *)offset;

/**
 *  Reads and returns a `uint32_t` at the specified location.
 *
 *  @param offset Pointer to offset to read from. The offset
 *  is incremented after reading the data.
 *
 *  @return The read integer.
 */
- (uint32_t)ind_readUInt32At:(NSUInteger *)offest;
@end
