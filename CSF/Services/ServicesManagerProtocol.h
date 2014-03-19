//
// Created by Seamus McGowan on 3/19/14.
// Copyright (c) 2014 Seamus McGowan. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FarmDataServiceProtocol;

@protocol ServicesManagerProtocol <NSObject>

@property (nonatomic, strong, readonly) id <FarmDataServiceProtocol> farmDataService;

@end