//
// Created by Seamus McGowan on 3/24/14.
// Copyright (c) 2014 Seamus McGowan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface InventoryItem : NSObject

@property (nonatomic, assign) BOOL            fractionalUnits;
@property (nonatomic, assign) BOOL            outOfStock;
@property (nonatomic, strong) NSString        *name;
@property (nonatomic, strong) NSDecimalNumber *price;
@property (strong, nonatomic) NSString        *type;

@end