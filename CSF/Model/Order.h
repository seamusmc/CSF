//
// Created by Seamus McGowan on 3/20/14.
// Copyright (c) 2014 Seamus McGowan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Order : NSObject

@property (nonatomic, readonly) BOOL locked;
@property (nonatomic, strong, readonly) NSArray *items;

// Default initializer
- (instancetype)initWithLocked:(BOOL)locked items:(NSArray *)items;

@end