//
//  NSDictionary+NSDictionary_Extended.m
//  CSF
//
//  Created by Seamus McGowan on 8/20/14.
//  Copyright (c) 2014 Seamus McGowan. All rights reserved.
//

#import "NSDictionary+NSDictionary_Extended.h"

@implementation NSDictionary (NSDictionary_Extended)

- (BOOL)containsKey:(NSString *)key {
    BOOL retVal = NO;

    NSArray *allKeys = [self allKeys];
    retVal = [allKeys containsObject:key];

    return retVal;
}

@end
