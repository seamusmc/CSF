//
// Created by Seamus McGowan on 3/19/14.
// Copyright (c) 2014 Seamus McGowan. All rights reserved.
//
// Singleton factory responsible for all of the individual services
// used in this application. Responsibilities include creation, access
// and lifetime management of the services.

#import <Foundation/Foundation.h>
#import "ServiceLocatorProtocol.h"

@interface ServiceLocator : NSObject <ServiceLocatorProtocol>

+ (id <ServiceLocatorProtocol>) sharedInstance;

@end