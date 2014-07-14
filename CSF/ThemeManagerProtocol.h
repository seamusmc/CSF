//
// Created by Seamus McGowan on 7/10/14.
// Copyright (c) 2014 Seamus McGowan. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ThemeManagerProtocol <NSObject>

#pragma mark - Colors
@property(nonatomic, strong, readonly) UIColor *tintColor;

#pragma mark - Fonts
@property(nonatomic, strong, readonly) UIColor *normalFontColor;
@property(nonatomic, strong, readonly) UIFont *normalFont;

@property(nonatomic, strong, readonly) UIColor *errorFontColor;
@property(nonatomic, strong, readonly) UIFont *errorFont;

@end