//
// Created by Seamus McGowan on 3/20/14.
// Copyright (c) 2014 Seamus McGowan. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol NetworkingServiceProtocol <NSObject>

- (void)getDataWithURI:(NSString *)uri withCompletionHandler:(void (^)(id responseObject))completionHandler;

@end