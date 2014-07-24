//
// Created by Seamus McGowan on 7/24/14.
// Copyright (c) 2014 Seamus McGowan. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const kOrderItemCellIdentifier;

@interface OrderItemTableViewCell : UITableViewCell

@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UILabel *quantityLabel;
@property (strong, nonatomic) UILabel *commentLabel;

@end