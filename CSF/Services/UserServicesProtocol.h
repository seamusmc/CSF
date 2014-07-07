//
// Created by Seamus McGowan on 3/26/14.
// Copyright (c) 2014 Seamus McGowan. All rights reserved.
//

#import <Foundation/Foundation.h>

@class User;

@protocol UserServicesProtocol <NSObject>

@property (strong, nonatomic, readonly) User *currentUser;

// Authenticates the specified user with password. Sets the currentUser property if successful.
// The completionHandler provides a flag indicating if the user was successfully authenticated.
- (void)authenticateUser:(User *)user withPassword:(NSString *)password withCompletionHandler:(void (^)(BOOL authenticated, NSString *message))completionHandler;

// Stores the specified user and password to some store, (KeyChain for example)
- (void)storeUser:(User *)user withPassword:(NSString *)password;

// Retrieve any user/password persisted in a store, (KeyChain for example)
- (void)retrieveUserAndPasswordFromStoreWithCompletionHandler:(void (^)(User *user, NSString *password))completionHandler;

@end