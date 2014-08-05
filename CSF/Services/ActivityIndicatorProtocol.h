//
// Created by Seamus McGowan on 8/5/14.
// Copyright (c) 2014 Seamus McGowan. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FBShimmeringView;

@protocol ActivityIndicatorProtocol <NSObject>

- (FBShimmeringView *)createActivityIndicator:(UIView *)view;

@end