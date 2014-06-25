//
// Created by Seamus McGowan on 6/25/14.
// Copyright (c) 2014 Seamus McGowan. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const kNetworkingServiceDomain;

// Codes
typedef NS_ENUM(NSUInteger, NetworkingServiceCode) {
    NetworkingServiceCodeUnknown            = 0,
    NetworkingServiceCodeSuccess            = 200,
    NetworkingServiceCodeBadRequest         = 400,
    NetworkingServiceCodeServiceUnavailable = 503,
    NetworkingServiceCodeTimeout            = 504
};