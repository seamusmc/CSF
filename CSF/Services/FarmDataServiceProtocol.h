//
// Created by Seamus McGowan on 3/19/14.
// Copyright (c) 2014 Seamus McGowan. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FarmDataServiceProtocol <NSObject>

@property (nonatomic, strong, readonly) NSArray *farms;

- (void)getItemTypesForFarm:(NSString *)farm withCompletionHandler:(void (^)(NSArray *types))completionHandler;

@end