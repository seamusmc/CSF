//
// Created by Seamus McGowan on 3/20/14.
// Copyright (c) 2014 Seamus McGowan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Order : NSObject

@property(nonatomic, assign, readonly) BOOL   locked;
@property(nonatomic, copy, readonly) NSArray  *items;
@property(nonatomic, copy, readonly) NSString *total;

// Default initializer
- (instancetype)initWithLockedFlag:(BOOL)locked items:(NSArray *)items total:(NSString *)total;

@end