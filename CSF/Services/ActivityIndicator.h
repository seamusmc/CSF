//
// Created by Seamus McGowan on 8/5/14.
// Copyright (c) 2014 Seamus McGowan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ActivityIndicatorProtocol.h"

@interface ActivityIndicator : NSObject <ActivityIndicatorProtocol>

+ (id <ActivityIndicatorProtocol>) sharedInstance;

@end