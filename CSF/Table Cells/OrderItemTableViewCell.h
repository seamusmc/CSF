//
// Created by Seamus McGowan on 7/24/14.
// Copyright (c) 2014 Seamus McGowan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SWTableViewCell.h"

extern NSString *const kOrderItemCellIdentifier;

@interface OrderItemTableViewCell : SWTableViewCell

@property(nonatomic, assign) NSString *name;
@property(nonatomic, assign) NSString *quantity;

@end