//
// Created by Seamus McGowan on 3/20/14.
// Copyright (c) 2014 Seamus McGowan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NetworkingServiceProtocol.h"

@interface NetworkingService : NSObject <NetworkingServiceProtocol>

+ (id <NetworkingServiceProtocol>)sharedInstance;

@end