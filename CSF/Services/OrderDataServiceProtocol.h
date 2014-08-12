//
// Created by Seamus McGowan on 3/20/14.
// Copyright (c) 2014 Seamus McGowan. All rights reserved.
//

#import <Foundation/Foundation.h>

@class User;
@class Order;
@class OrderItem;

@protocol OrderDataServiceProtocol <NSObject>

- (void)getOrderForUser:(User *)user
                   date:(NSDate *)date
           successBlock:(void (^)(Order *order))successBlock
           failureBlock:(void (^)(NSString *message))failureBlock;

- (void)removeItem:(OrderItem *)item
              user:(User *)user
              date:(NSDate *)date
      successBlock:(void (^)(void))successBlock
      failureBlock:(void (^)(NSString *message))failureBlock;

@end