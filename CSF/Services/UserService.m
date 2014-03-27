//
// Created by Seamus McGowan on 3/26/14.
// Copyright (c) 2014 Seamus McGowan. All rights reserved.
//

#import "UserService.h"
#import "User.h"
#import "NetworkingServiceProtocol.h"
#import "ServiceLocator.h"
#import "ServiceConstants.h"

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


- (void)authenticateUser:(User *)user withPassword:(NSString *)password withCompletionHandler:(void (^)(BOOL authenticated))completionHandler
{
    self.currentUser = nil;

    if (!completionHandler)
    {
        return;
    }

    NSString *uri = [NSString stringWithFormat:AuthenticationURI, user.farm, user.firstname, user.lastname, password];
    [_networkingService getDataWithURI:uri withCompletionHandler:^(NSData *data)
    {
        if (data)
        {
            // We may get data back, an error page for example, but it won't serialize to json.
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data
                                                                 options:0
                                                                   error:nil];
            if (!json)
            {
                completionHandler(NO);
            }
            else
            {
                NSLog(@"Order JSON: %@", json);

                // A code of 2 indicates authentication failed. Could be because firstname, lastname,
                // password or farm were not set correctly.
                NSDictionary *errorInfo = [json objectForKey:@"ErrorInfo"];
                int code = [((NSString *) [errorInfo objectForKey:@"Code"]) integerValue];
                if (code == 2)
                {
                    completionHandler(NO);
                }
                else
                {
                    self.currentUser = user;
                    completionHandler(YES);
                }
            }
        }
        else
        {
            completionHandler(NO);
        }
    }];
}

+ (id <UserServiceProtocol>)sharedInstance
{
    static UserService     *sharedInstance = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^
    {
        sharedInstance = [[UserService alloc] init];
    });

    return sharedInstance;
}

@end