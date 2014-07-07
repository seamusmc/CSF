//
// Created by Seamus McGowan on 3/20/14.
// Copyright (c) 2014 Seamus McGowan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Order : NSObject

@property(nonatomic, assign, readonly) BOOL  locked;
@property(nonatomic, copy, readonly) NSArray *items;

// Default initializer
- (instancetype)initWithLocked:(BOOL)locked items:(NSArray *)items;

@end