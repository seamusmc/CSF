//
// Created by Seamus McGowan on 3/20/14.
// Copyright (c) 2014 Seamus McGowan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OrderDataServiceProtocol.h"

@interface OrderDataService : NSObject <OrderDataServiceProtocol>

+ (id <OrderDataServiceProtocol>) sharedInstance;

@end