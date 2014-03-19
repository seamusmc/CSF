//
// Created by Seamus McGowan on 3/19/14.
// Copyright (c) 2014 Seamus McGowan. All rights reserved.
//

#import "ServiceLocator.h"
#import "FarmDataService.h"

@implementation ServiceLocator

- (id <FarmDataServiceProtocol>)farmDataService
{
    id <FarmDataServiceProtocol> service = [FarmDataService sharedInstance];
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