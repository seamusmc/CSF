//
// Created by Seamus McGowan on 3/19/14.
// Copyright (c) 2014 Seamus McGowan. All rights reserved.
//
// Singleton implementation of a farm service. This service
// provides the list of farms supported by the application.
// It also provides the list of items each farm sells.

#import <Foundation/Foundation.h>
#import "FarmDataServiceProtocol.h"

@interface FarmDataService : NSObject <FarmDataServiceProtocol>

+ (id <FarmDataServiceProtocol>) sharedInstance;

@end