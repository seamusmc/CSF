//
// Created by Seamus McGowan on 3/19/14.
// Copyright (c) 2014 Seamus McGowan. All rights reserved.
//

#import "ServicesManager.h"
#import "FarmDataService.h"
#import "FarmDataServiceProtocol.h"

@implementation ServicesManager

- (id <FarmDataServiceProtocol>)farmDataService
{
    id <FarmDataServiceProtocol> service = [FarmDataService sharedInstance];
    return service;
}

+ (id <ServicesManagerProtocol>)sharedInstance
{
    static ServicesManager *sharedInstance = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^
    {
        sharedInstance = [[ServicesManager alloc] init];
    });

    return sharedInstance;
}

@end