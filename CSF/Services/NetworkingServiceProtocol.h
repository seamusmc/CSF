//
// Created by Seamus McGowan on 3/20/14.
// Copyright (c) 2014 Seamus McGowan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NetworkingServiceConstants.h"

@protocol NetworkingServiceProtocol <NSObject>

- (void)getDataWithURI:(NSString *)uri successBlock:(void (^)(id response))successBlock failureBlock:(void (^)(NSError *error))failureBlock;
- (void)postDataWithURLString:(NSString *)uri successBlock:(void (^)(id response))successBlock failureBlock:(void (^)(NSError *error))failureBlock;

@end