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

NSString *const FailedAuthentication = @"FailedAuthentication";

@interface UserServices ()

// Define this because we can't auto-synthesize protocol properties
@property(strong, nonatomic) User *currentUser;
@property(strong, nonatomic, readonly) id <NetworkingServiceProtocol> networkingService;

@end

@implementation UserServices

- (User *)currentUser {
    if (!_currentUser) {
        [NSException raise:@"Current User Property Not Set." format:@"The current user property has not been set."];
    }

    return _currentUser;
}

- (void)storeUser:(User *)user withPassword:(NSString *)password {
    FXKeychain *keychain = [FXKeychain defaultKeychain];

    keychain[@"firstname"] = user.firstname;
    keychain[@"lastname"]  = user.lastname;
    keychain[@"group"]     = user.group;
    keychain[@"farm"]      = user.farm;
    keychain[@"password"]  = password;
}

- (void)retrieveUserAndPasswordFromStoreWithCompletionHandler:(void (^)(User *user, NSString *password))completionHandler {
    FXKeychain *keychain = [FXKeychain defaultKeychain];

    User *usr = [[User alloc] initWithFirstname:keychain[@"firstname"]
                                       lastname:keychain[@"lastname"]
                                          group:keychain[@"group"]
                                           farm:keychain[@"farm"]];

    NSString *password = keychain[@"password"];

    completionHandler(usr, password);
}

- (void)authenticateUser:(User *)user
            withPassword:(NSString *)password
   withCompletionHandler:(void (^)(BOOL))completionHandler {
    if (!completionHandler) {
        return;
    }

    NSString *uri = [NSString stringWithFormat:AuthenticationURI, user.farm, user.firstname, user.lastname, password];
    [self.networkingService getDataWithURI:uri withCompletionHandler:^(id responseObject)
            {
                if (responseObject) {
                    NSLog(@"Order JSON: %@", responseObject);

                    // A code of 2 indicates authentication failed. Could be because firstname, lastname,
                    // password and/or farm were not set correctly.
                    NSDictionary *errorInfo = [responseObject objectForKey:@"ErrorInfo"];

                    NSInteger code = [((NSString *) [errorInfo objectForKey:@"Code"]) integerValue];
                    if (code == 2) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [[NSNotificationCenter defaultCenter] postNotificationName:FailedAuthentication
                                                                                object:self];
                        });
                        completionHandler(NO);
                    }
                    else {
                        self.currentUser = [[User alloc] initWithFirstname:user.firstname
                                                                  lastname:user.lastname
                                                                     group:[responseObject objectForKey:@"Group"]
                                                                      farm:user.farm];
                        completionHandler(YES);
                    }
                }
                else {
                    completionHandler(NO);
                }
            }];
}

- (id <NetworkingServiceProtocol>)networkingService {
    return [ServiceLocator sharedInstance].networkingService;
}

+ (id <UserServicesProtocol>)sharedInstance {
    static UserServices    *sharedInstance = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        sharedInstance = [[UserServices alloc] init];
    });

    return sharedInstance;
}

@end