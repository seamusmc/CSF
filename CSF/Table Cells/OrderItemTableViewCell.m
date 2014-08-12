//
// Created by Seamus McGowan on 7/24/14.
// Copyright (c) 2014 Seamus McGowan. All rights reserved.
//

#import "OrderItemTableViewCell.h"
#import "ThemeManager.h"
#import "UIView+FLKAutoLayout.h"

NSString *const kOrderItemCellIdentifier = @"orderItemCellIdentifier";

@interface OrderItemTableViewCell ()

@property(strong, nonatomic) UIView *lineView;
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UILabel *quantityLabel;
@property (strong, nonatomic) UILabel *commentLabel;

@end

@implementation OrderItemTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        CGRect initialFrame = CGRectMake(0.0f, 0.0f, 0.0f, 0.0f);

        self.nameLabel     = [[UILabel alloc] initWithFrame:initialFrame];
        self.quantityLabel = [[UILabel alloc] initWithFrame:initialFrame];
        self.lineView      = [[UIView alloc] initWithFrame:initialFrame];
    }

    return self;
}

- (void)layoutSubviews {
    self.backgroundColor = [UIColor clearColor];

    self.contentView.frame = CGRectMake(0.0f, 0.0f, self.superview.frame.size.width, 45.0f);

    [self configureLine];
    [self configureNameLabel];
    [self configureQuantityLabel];

    [super layoutSubviews];
}

- (void)configureQuantityLabel {
    CGSize  size   = self.contentView.frame.size;
    CGPoint origin = self.contentView.frame.origin;

    if (self.editing) {
        self.quantityLabel.frame = CGRectMake(origin.x + 70.0f, self.nameLabel.frame.size.height, size.width - 90.0f, 20.0f);
    } else {
        self.quantityLabel.frame = CGRectMake(origin.x + 20.0f, self.nameLabel.frame.size.height, size.width - 40.0f, 20.0f);
    }

    self.quantityLabel.textColor     = [ThemeManager sharedInstance].tableViewDescriptionFontColor;
    self.quantityLabel.font          = [ThemeManager sharedInstance].tableViewDescriptionFont;
    self.quantityLabel.textAlignment = NSTextAlignmentLeft;

    [self.contentView addSubview:self.quantityLabel];
}

- (void)configureNameLabel {
    CGSize  size   = self.contentView.frame.size;
    CGPoint origin = self.contentView.frame.origin;

    if (self.editing) {
        self.nameLabel.frame = CGRectMake(origin.x + 70.0f, 0.0f, size.width - 90.0f, 20.0f);
    } else {
        self.nameLabel.frame = CGRectMake(origin.x + 20.0f, 0.0f, size.width - 40.0f, 20.0f);
    }

    self.nameLabel.textColor     = [ThemeManager sharedInstance].tableViewTitleFontColor;
    self.nameLabel.font          = [ThemeManager sharedInstance].tableViewTitleFont;
    self.nameLabel.textAlignment = NSTextAlignmentLeft;

    [self.contentView addSubview:self.nameLabel];
}

- (void)configureLine {
    CGSize  size   = self.contentView.frame.size;
    CGPoint origin = self.contentView.frame.origin;

    if (self.editing) {
        self.lineView.frame = CGRectMake(origin.x + 70.0f, size.height, size.width - 90.0f, 1.0f);
    } else {
        self.lineView.frame = CGRectMake(origin.x + 20.0f, size.height, size.width - 40.0f, 1.0f);
    }

    self.lineView.backgroundColor = [ThemeManager sharedInstance].tintColor;

    [self.contentView addSubview:self.lineView];
}

#pragma mark - Property Overrides

- (NSString *)name {
    return self.nameLabel.text;
}

- (void)setName:(NSString *)name {
    self.nameLabel.text = name;
}

- (NSString *)quantity {
    return self.quantityLabel.text;
}

- (void)setQuantity:(NSString *)quantity {
    self.quantityLabel.text = quantity;
}

@end