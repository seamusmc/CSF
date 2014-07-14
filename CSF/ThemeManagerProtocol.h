//
// Created by Seamus McGowan on 7/10/14.
// Copyright (c) 2014 Seamus McGowan. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ThemeManagerProtocol <NSObject>

#pragma mark - Colors
@property(nonatomic, strong, readonly) UIColor *tintColor;
@property(nonatomic, strong, readonly) UIColor *fontColor;
@property(nonatomic, strong, readonly) UIColor *fontErrorColor;

#pragma mark - Font
- (UIFont *)normalFont;

@end