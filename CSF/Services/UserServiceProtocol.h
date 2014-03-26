//
// Created by Seamus McGowan on 3/26/14.
// Copyright (c) 2014 Seamus McGowan. All rights reserved.
//

#import <Foundation/Foundation.h>

@class User;

@protocol UserServiceProtocol <NSObject>

@property (nonatomic, strong) User *currentUser;

- (BOOL)authenticateUser:(User *)user;

@end