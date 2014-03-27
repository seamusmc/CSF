//
// Created by Seamus McGowan on 3/26/14.
// Copyright (c) 2014 Seamus McGowan. All rights reserved.
//

#import <Foundation/Foundation.h>

@class User;

@protocol AuthenticationServiceProtocol <NSObject>

@property (nonatomic, strong, readonly) User *currentUser;

- (void)authenticateUser:(User *)user withPassword:(NSString *)password withCompletionHandler:(void (^)(BOOL authenticated))completionHandler;

@end