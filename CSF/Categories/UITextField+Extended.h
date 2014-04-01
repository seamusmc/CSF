//
// Created by Seamus McGowan on 4/1/14.
// Copyright (c) 2014 Seamus McGowan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UITextField (Extended)

// Property that allows us to indicate what the next field is
// in the 'Next/Return Key' order. aka tab order.
@property(retain, nonatomic)UITextField* nextTextField;

@end