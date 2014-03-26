//
// Created by Seamus McGowan on 3/26/14.
// Copyright (c) 2014 Seamus McGowan. All rights reserved.
//

#import "UserService.h"
#import "User.h"
#import "NetworkingServiceProtocol.h"
#import "ServiceLocator.h"

@interface UserService ()

// Define this because we can't auto-synthesize protocol properties
@property (nonatomic, strong) User *currentUser;

@end

@implementation UserService
{
    id <NetworkingServiceProtocol> _networkingService;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        _networkingService = [[ServiceLocator sharedInstance] networkingService];
    }

    return self;
}


- (BOOL)authenticateUser:(User *)user
{
    _currentUser = user;

    return YES;
}

+ (id <UserServiceProtocol>)sharedInstance
{
    static UserService *sharedInstance = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^
    {
        sharedInstance = [[UserService alloc] init];
    });

    return sharedInstance;
}


@end