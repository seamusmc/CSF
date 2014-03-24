//
// Created by Seamus McGowan on 3/20/14.
// Copyright (c) 2014 Seamus McGowan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OrderItem : NSObject

@property (strong, nonatomic) NSDecimalNumber           *price;
@property (strong, nonatomic) NSString                  *name;
@property (strong, nonatomic) NSDecimalNumber           *quantity;
@property (strong, nonatomic) NSString                  *comment;
@property (strong, nonatomic) NSString                  *type;
@property (strong, nonatomic, readonly) NSDecimalNumber *subtotal;      // qty * price.

@end