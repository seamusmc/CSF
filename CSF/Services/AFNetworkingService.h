//
// Created by Seamus McGowan on 3/28/14.
// Copyright (c) 2014 Seamus McGowan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NetworkingServiceProtocol.h"

@interface AFNetworkingService : NSObject <NetworkingServiceProtocol>

+ (id <NetworkingServiceProtocol>)sharedInstance;

@end