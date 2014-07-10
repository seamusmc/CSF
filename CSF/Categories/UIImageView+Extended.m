//
// Created by Seamus McGowan on 7/10/14.
// Copyright (c) 2014 Seamus McGowan. All rights reserved.
//

#import "UIImageView+Extended.h"


@implementation UIImageView (Extended)

- (void)tintWithColor:(UIColor *)color {
    UIView *overlayView = [[UIView alloc] initWithFrame:self.bounds];
    overlayView.opaque = NO;
    overlayView.backgroundColor = color;
    [self addSubview:overlayView];
}

@end