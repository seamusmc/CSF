//
// Created by Seamus McGowan on 3/26/14.
// Copyright (c) 2014 Seamus McGowan. All rights reserved.
//

#import <Foundation/Foundation.h>

@class User;

@protocol UserServicesProtocol <NSObject>

// The currentUser is only accessible after authenticating the user.
@property (nonatomic, strong, readonly) User *currentUser;

// Authenticates the specified user with password. Sets the currentUser property if successful.
// The completionHandler provides a flag indicating if the user was successfully authenticated.
- (void)authenticateUser:(User *)user withPassword:(NSString *)password withCompletionHandler:(void (^)(BOOL authenticated))completionHandler;

// Stores the specified user and password to some store, (KeyChain for example)
- (void)storeUser:(User *)user withPassword:(NSString *)password;

// Attempts to retrieve the user name and password from a store, (KeyChain for example), authenticate the user
// and set the currentUser property if successful. The completionHandler provides a flag indicating if the user
// was successfully authenticated.
- (void)authenticateWithStoredUserCredentialsWithCompletionHandler:(void (^)(BOOL authenticated))completionHandler;

@end