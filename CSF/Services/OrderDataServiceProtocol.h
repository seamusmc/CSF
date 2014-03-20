//
// Created by Seamus McGowan on 3/20/14.
// Copyright (c) 2014 Seamus McGowan. All rights reserved.
//

#import <Foundation/Foundation.h>

@class User;

@protocol OrderDataServiceProtocol <NSObject>

- (void)getOrderForUser:(User *)user forFarm:(NSString *)farm forDate:(NSDate *)date;

@end