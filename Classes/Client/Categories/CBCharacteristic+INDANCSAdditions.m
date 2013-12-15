//
//  CBCharacteristic+INDANCSAdditions.m
//  INDANCSMac
//
//  Created by Indragie Karunaratne on 12/14/2013.
//  Copyright (c) 2013 Indragie Karunaratne. All rights reserved.
//

#import "CBCharacteristic+INDANCSAdditions.h"

@implementation CBCharacteristic (INDANCSAdditions)

- (NSString *)ind_stringValue
{
	NSString *value = @"";
	if (self.value) {
		value = [[NSString alloc] initWithData:self.value encoding:NSUTF8StringEncoding];
	}
	return value;
}

@end
