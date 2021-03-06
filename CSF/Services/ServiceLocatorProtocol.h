//
// Created by Seamus McGowan on 3/19/14.
// Copyright (c) 2014 Seamus McGowan. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FarmDataServiceProtocol;
@protocol NetworkingServiceProtocol;
@protocol OrderDataServiceProtocol;
@protocol UserServicesProtocol;

@protocol ServiceLocatorProtocol <NSObject>

@property (nonatomic, strong, readonly) id <OrderDataServiceProtocol>  orderDataService;
@property (nonatomic, strong, readonly) id <FarmDataServiceProtocol>   farmDataService;
@property (nonatomic, strong, readonly) id <NetworkingServiceProtocol> networkingService;
@property (nonatomic, strong, readonly) id <UserServicesProtocol> userServices;

@end