//
// Created by Seamus McGowan on 7/24/14.
// Copyright (c) 2014 Seamus McGowan. All rights reserved.
//

#import "OrderItemTableViewCell.h"
#import "ThemeManager.h"

NSString *const kOrderItemCellIdentifier = @"orderItemCellIdentifier";

@interface OrderItemTableViewCell ()

@property(strong, nonatomic) UIView  *lineView;
@property(strong, nonatomic) UILabel *nameLabel;
@property(strong, nonatomic) UILabel *quantityLabel;
@property(strong, nonatomic) UILabel *commentLabel;

@end

@implementation OrderItemTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        CGRect initialFrame = CGRectMake(0.0f, 0.0f, 0.0f, 0.0f);

        self.nameLabel     = [[UILabel alloc] initWithFrame:initialFrame];
        self.quantityLabel = [[UILabel alloc] initWithFrame:initialFrame];
        self.commentLabel  = [[UILabel alloc] initWithFrame:initialFrame];

        self.lineView = [[UIView alloc] initWithFrame:initialFrame];

        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    return self;
}

- (void)layoutSubviews {
    self.backgroundColor = [UIColor clearColor];

    [self configureLine];
    [self configureNameLabel];

    CGFloat y = self.nameLabel.frame.origin.y + self.nameLabel.frame.size.height;
    [self configureQuantityLabel:y];

    CGFloat x = self.quantityLabel.frame.origin.x + self.quantityLabel.frame.size.width + 15.0f;
    CGPoint point = CGPointMake(x, y);
    [self configureCommentLabel:point];

    [super layoutSubviews];
}

- (void)configureCommentLabel:(CGPoint)point {
    CGSize size = self.contentView.frame.size;

    CGFloat width = size.width - self.quantityLabel.frame.size.width;
    self.commentLabel.frame = CGRectMake(point.x, point.y, width - 55.0f, 20.0f);

    self.commentLabel.textColor     = [ThemeManager sharedInstance].tableViewDescriptionFontColor;
    self.commentLabel.font          = [ThemeManager sharedInstance].tableViewDescriptionFont;
    self.commentLabel.textAlignment = NSTextAlignmentRight;

    [self.contentView addSubview:self.commentLabel];
}

- (void)configureQuantityLabel:(CGFloat) y {
    CGPoint origin = self.contentView.frame.origin;

    self.quantityLabel.frame = CGRectMake(origin.x + 20.0f, y, 100.0f, 20.0f);

    self.quantityLabel.textColor     = [ThemeManager sharedInstance].tableViewDescriptionFontColor;
    self.quantityLabel.font          = [ThemeManager sharedInstance].tableViewDescriptionFont;
    self.quantityLabel.textAlignment = NSTextAlignmentLeft;

    [self.contentView addSubview:self.quantityLabel]    ;
}

- (void)configureNameLabel {
    CGSize  size   = self.contentView.frame.size;
    CGPoint origin = self.contentView.frame.origin;

    self.nameLabel.frame = CGRectMake(origin.x + 20.0f, 4.0f, size.width - 40.0f, 23.0f);

    self.nameLabel.textColor     = [ThemeManager sharedInstance].tableViewTitleFontColor;
    self.nameLabel.font          = [ThemeManager sharedInstance].tableViewTitleFont;
    self.nameLabel.textAlignment = NSTextAlignmentLeft;

    [self.contentView addSubview:self.nameLabel];
}

- (void)configureLine {
    CGSize  size   = self.contentView.frame.size;
    CGPoint origin = self.contentView.frame.origin;

    self.lineView.frame = CGRectMake(origin.x + 20.0f, size.height - 1.0f, size.width - 40.0f, 1.0f);

    self.lineView.backgroundColor = [ThemeManager sharedInstance].tintColor;

    [self.contentView addSubview:self.lineView];
}

#pragma mark - Property Overrides

- (NSString *)comment {
    return self.commentLabel.text;
}

- (void)setComment:(NSString *)comment {
    self.commentLabel.text = comment;
}

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