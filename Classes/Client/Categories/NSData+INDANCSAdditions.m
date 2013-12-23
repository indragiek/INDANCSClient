//
//  NSData+INDANCSAdditions.m
//  INDANCSMac
//
//  Created by Indragie Karunaratne on 12/12/2013.
//  Copyright (c) 2013 Indragie Karunaratne. All rights reserved.
//

#import "NSData+INDANCSAdditions.h"

@implementation NSData (INDANCSAdditions)

- (uint8_t)ind_readUInt8At:(NSUInteger *)offset;
{
	uint8_t val = 0;
	[self getBytes:&val range:NSMakeRange(*offset, sizeof(val))];
	*offset += sizeof(val);
	return val;
}

- (uint16_t)ind_readUInt16At:(NSUInteger *)offset
{
	uint16_t val = 0;
	[self getBytes:&val range:NSMakeRange(*offset, sizeof(val))];
	*offset += sizeof(val);
	return val;
}

- (uint32_t)ind_readUInt32At:(NSUInteger *)offset
{
	uint32_t val = 0;
	[self getBytes:&val range:NSMakeRange(*offset, sizeof(val))];
	*offset += sizeof(val);
	return val;
}

- (NSUInteger)ind_locationOfNullByteFromOffset:(NSUInteger)offset
{
	NSData *nullByte = [NSData dataWithBytes:"\0" length:1];
	NSRange range = [self rangeOfData:nullByte options:0 range:NSMakeRange(offset, self.length - offset)];
	return range.location;
}

@end
