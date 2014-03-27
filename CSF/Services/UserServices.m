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

@interface UserServices ()

// Define this because we can't auto-synthesize protocol properties
@property (nonatomic, strong) User *currentUser;

@end

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

- (User *)currentUser
{
    if (!_currentUser)
    {
        [NSException raise:@"Ccurrent User Property Not Set." format:@"The current user property has not been set."];
    }

    return _currentUser;
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

- (void)authenticateWithStoredUserCredentialsWithCompletionHandler:(void (^)(BOOL authenticated))completionHandler
{
    FXKeychain *keychain = [FXKeychain defaultKeychain];

    User *user = [[User alloc] initWithFirstname:keychain[@"firstname"]
                                        lastname:keychain[@"lastname"]
                                           group:keychain[@"group"]
                                            farm:keychain[@"farm"]];

    [self authenticateUser:user withPassword:keychain[@"password"] withCompletionHandler:completionHandler];
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
                int          code       = [((NSString *) [errorInfo objectForKey:@"Code"]) integerValue];
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