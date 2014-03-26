//
// Created by Seamus McGowan on 3/26/14.
// Copyright (c) 2014 Seamus McGowan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserServiceProtocol.h"

@interface UserService : NSObject <UserServiceProtocol>

+ (id <UserServiceProtocol>) sharedInstance;

@end