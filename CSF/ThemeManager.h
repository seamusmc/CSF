//
// Created by Seamus McGowan on 5/6/14.
// Copyright (c) 2014 Seamus McGowan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ThemeManager : NSObject

@property (strong, nonatomic,readonly) UIColor *tintColor;

- (UIFont *)fontWithSize:(CGFloat)size;

+ (instancetype)sharedInstance;

@end