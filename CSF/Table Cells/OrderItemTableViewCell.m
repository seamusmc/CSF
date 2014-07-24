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
        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 0.0f, 20.0f)];
        self.quantityLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, self.nameLabel.frame.size.height, 0.0f, 20.0f)];
    }

    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    self.backgroundColor = [UIColor clearColor];

    self.contentView.frame = CGRectMake(0.0f, 0.0f, self.superview.frame.size.width, 45.0f);
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    [self configureLine];
    [self configureNameLabel];
    [self configureQuantityLabel];
    [self configureCommentLabel];
}

- (void)configureCommentLabel {

}

- (void)configureQuantityLabel {
    self.quantityLabel.textColor     = [ThemeManager sharedInstance].tableViewDescriptionFontColor;
    self.quantityLabel.font          = [ThemeManager sharedInstance].tableViewDescriptionFont;
    self.quantityLabel.textAlignment = NSTextAlignmentLeft;

    [self.contentView addSubview:self.quantityLabel];
    [self.quantityLabel alignLeadingEdgeWithView:self.contentView predicate:@"20"];
}

- (void)configureNameLabel {
    self.nameLabel.textColor     = [ThemeManager sharedInstance].tableViewTitleFontColor;
    self.nameLabel.font          = [ThemeManager sharedInstance].tableViewTitleFont;
    self.nameLabel.textAlignment = NSTextAlignmentLeft;

    [self.contentView addSubview:self.nameLabel];
    [self.nameLabel alignLeadingEdgeWithView:self.contentView predicate:@"20"];

}

- (void)configureLine {
    CGSize  size   = self.contentView.frame.size;
    CGPoint origin = self.contentView.frame.origin;

    self.lineView                 = [[UIView alloc] initWithFrame:CGRectMake(origin.x + 20.0f, size.height, size.width - 40.0f, 1.0f)];
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