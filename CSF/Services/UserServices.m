//
// Created by Seamus McGowan on 3/26/14.
// Copyright (c) 2014 Seamus McGowan. All rights reserved.
//

#import "UserServices.h"
#import "User.h"
#import "NetworkingServiceProtocol.h"
#import "ServiceLocator.h"
#import "ServiceConstants.h"
#import "FXKeychain.h"

@implementation UserServices
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

- (void)storeUser:(User *)user withPassword:(NSString *)password
{
    FXKeychain *keychain = [FXKeychain defaultKeychain];

    keychain[@"firstname"] = user.firstname;
    keychain[@"lastname"]  = user.lastname;
    keychain[@"group"]     = user.group;
    keychain[@"farm"]      = user.farm;
    keychain[@"password"]  = password;
}

- (void)authenticateUser:(User *)user withPassword:(NSString *)password withCompletionHandler:(void (^)(BOOL, User *))completionHandler
{
    if (!completionHandler)
    {
        return;
    }

    NSString *uri = [NSString stringWithFormat:AuthenticationURI, user.farm, user.firstname, user.lastname, password];
    [_networkingService getDataWithURI:uri withCompletionHandler:^(id responseObject)
    {
        if (responseObject)
        {
            NSLog(@"Order JSON: %@", responseObject);

            // A code of 2 indicates authentication failed. Could be because firstname, lastname,
            // password or farm were not set correctly.
            NSDictionary *errorInfo = [responseObject objectForKey:@"ErrorInfo"];

            NSInteger code = [((NSString *) [errorInfo objectForKey:@"Code"]) integerValue];
            if (code == 2)
            {
                completionHandler(NO, nil);
            }
            else
            {
                User *authenticatedUser = [[User alloc] initWithFirstname:user.firstname
                                                                 lastname:user.lastname
                                                                    group:[responseObject objectForKey:@"Group"]
                                                                     farm:user.farm];
                completionHandler(YES, authenticatedUser);
            }

        }
        else
        {
            completionHandler(NO, nil);
        }
    }];
}

+ (id <UserServicesProtocol>)sharedInstance
{
    static UserServices    *sharedInstance = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^
    {
        sharedInstance = [[UserServices alloc] init];
    });

    return sharedInstance;
}

@end