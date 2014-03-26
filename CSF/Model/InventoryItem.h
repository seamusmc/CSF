//
// Created by Seamus McGowan on 3/24/14.
// Copyright (c) 2014 Seamus McGowan. All rights reserved.
//
// InventoryItem represents an item from the farmer's stock. The webservice call for this item provides the price
// and an out of stock flag. Note that the call for an Order's item does not return the price!
//
// We have to use the price returned for an InventoryItem to calculate sub-totals and total for an order.
// This is fine because price, sub-totals and total are only estimates and can fluctuate slightly between
// the time an order is made and picked up.
//
// NB removed fractionsUnits property as it does not appear to be populated by the WebService. This flag
// was supposed to be used to determine whether a customer could specify fractional units for an item.
// For example 1.5 lb butter vs 1 gallon of milk.
//

#import <Foundation/Foundation.h>
#import "Item.h"

@interface InventoryItem : Item

@property (nonatomic, assign) BOOL outOfStock;

@end