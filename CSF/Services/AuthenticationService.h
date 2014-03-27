//
// Created by Seamus McGowan on 3/26/14.
// Copyright (c) 2014 Seamus McGowan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AuthenticationServiceProtocol.h"

@interface AuthenticationService : NSObject <AuthenticationServiceProtocol>

+ (id <AuthenticationServiceProtocol>) sharedInstance;

@end