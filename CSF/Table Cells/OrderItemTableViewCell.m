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

@end

@implementation OrderItemTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.nameLabel = [[UILabel alloc] init];
    }

    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    self.frame = CGRectMake(0.0f, 0.0f, self.superview.frame.size.width, 100.0f);
    self.backgroundColor = [UIColor clearColor];

    [self configureLine];
    [self configureNameLabel];
    [self configureTotalLabel];
    [self configureCommentLabel];
}

- (void)configureCommentLabel {

}

- (void)configureTotalLabel {

}

- (void)configureNameLabel {
    CGSize size = self.contentView.frame.size;

    self.nameLabel.frame                = CGRectMake(0.0f, 0.0f, 150.0f, size.height);
    self.nameLabel.textColor            = [ThemeManager sharedInstance].normalFontColor;
    self.nameLabel.font                 = [ThemeManager sharedInstance].normalFont;
    self.nameLabel.textAlignment        = NSTextAlignmentLeft;
    self.nameLabel.autoresizingMask     = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);

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


@end