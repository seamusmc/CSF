//
// Created by Seamus McGowan on 3/19/14.
// Copyright (c) 2014 Seamus McGowan. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FarmDataServiceProtocol;
@protocol NetworkingServiceProtocol;

@protocol ServiceLocatorProtocol <NSObject>

@property (nonatomic, strong, readonly) id <FarmDataServiceProtocol> farmDataService;
@property (nonatomic, strong, readonly) id <NetworkingServiceProtocol> networkingService;

@end