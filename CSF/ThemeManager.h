//
// Created by Seamus McGowan on 5/6/14.
// Copyright (c) 2014 Seamus McGowan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ThemeManagerProtocol.h"

@interface ThemeManager : NSObject <ThemeManagerProtocol>

+ (instancetype)sharedInstance;

@end