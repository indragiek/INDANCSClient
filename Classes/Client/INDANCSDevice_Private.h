//
//  INDANCSDevice_Private.h
//  INDANCSMac
//
//  Created by Indragie Karunaratne on 12/11/2013.
//  Copyright (c) 2013 Indragie Karunaratne. All rights reserved.
//

#import "INDANCSDevice.h"

@interface INDANCSDevice ()
- (id)initWithCBPeripheral:(CBPeripheral *)peripheral;
@property (nonatomic, strong, readonly) CBPeripheral *peripheral;
@property (nonatomic, copy, readwrite) NSString *name;
@property (nonatomic, strong) CBService *ANCSService;
@property (nonatomic, strong) CBService *NAMEService;
@property (nonatomic, strong) CBCharacteristic *NAMECharacteristic;
@property (nonatomic, strong) CBCharacteristic *NSCharacteristic;
@property (nonatomic, strong) CBCharacteristic *CPCharacteristic;
@property (nonatomic, strong) CBCharacteristic *DSCharacteristic;
@end
