//
// Created by Seamus McGowan on 3/26/14.
// Copyright (c) 2014 Seamus McGowan. All rights reserved.
//
// Base class for OrderItem and InventoryItem. Note that the price is only
// populated by the web service call for inventory items, for order items
// we populate the price property at the time the order is created or
// retrieved from the web service.
//

#import <Foundation/Foundation.h>

@interface Item : NSObject

@property(nonatomic, copy) NSString *name;
@property(nonatomic, copy) NSString *type;
@property (nonatomic, strong) NSDecimalNumber *price;

@end