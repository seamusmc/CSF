//
// Created by Seamus McGowan on 3/20/14.
// Copyright (c) 2014 Seamus McGowan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject

@property(nonatomic, copy, readonly) NSString *firstname;
@property(nonatomic, copy, readonly) NSString *lastname;
@property(nonatomic, copy, readonly) NSString *group;
@property(nonatomic, copy, readonly) NSString *farm;

// Default initializer
- (instancetype)initWithFirstname:(NSString *)firstname
                         lastname:(NSString *)lastname
                            group:(NSString *)group
                             farm:(NSString *)farm;

@end