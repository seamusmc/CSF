//
// Created by Seamus McGowan on 3/19/14.
// Copyright (c) 2014 Seamus McGowan. All rights reserved.
//

#import "ServiceLocator.h"
#import "FarmDataService.h"
#import "NetworkingServiceProtocol.h"
#import "NetworkingService.h"
#import "OrderDataService.h"
#import "UserServices.h"

@implementation ServiceLocator

- (id <OrderDataServiceProtocol>)orderDataService
{
    id <OrderDataServiceProtocol> service = [OrderDataService sharedInstance];
    return service;
}

- (id <FarmDataServiceProtocol>)farmDataService
{
    id <FarmDataServiceProtocol> service = [FarmDataService sharedInstance];
    return service;
}

- (id <NetworkingServiceProtocol>)networkingService
{
    id <NetworkingServiceProtocol> service = [NetworkingService sharedInstance];
    return service;
}

- (id <UserServicesProtocol>)userServices
{
    id <UserServicesProtocol> service = [UserServices sharedInstance];
    return service;
}

+ (id <ServiceLocatorProtocol>)sharedInstance
{
    static ServiceLocator *sharedInstance = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^
    {
        sharedInstance = [[ServiceLocator alloc] init];
    });

    return sharedInstance;
}

@end