//
// Created by Seamus McGowan on 8/5/14.
// Copyright (c) 2014 Seamus McGowan. All rights reserved.
//

#import "ActivityIndicator.h"
#import "FBShimmeringView+Extended.h"
#import "ThemeManager.h"


@implementation ActivityIndicator

+ (id <ActivityIndicatorProtocol>)sharedInstance {
    static ActivityIndicator *sharedInstance = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        sharedInstance = [[ActivityIndicator alloc] init];
    });

    return sharedInstance;
}

- (FBShimmeringView *)createActivityIndicator:(UIView *)view {
    CGRect frame = CGRectMake(0, 0, view.bounds.size.width, 1.0f);
    FBShimmeringView *shimmeringView = [[FBShimmeringView alloc] initWithFrame:frame];

    shimmeringView.hidden                      = YES;
    shimmeringView.shimmeringSpeed             = [ThemeManager sharedInstance].shimmerSpeed;
    shimmeringView.shimmeringBeginFadeDuration = [ThemeManager sharedInstance].shimmeringBeginFadeDuration;
    shimmeringView.shimmeringEndFadeDuration   = [ThemeManager sharedInstance].shimmeringEndFadeDuration;
    shimmeringView.shimmeringOpacity           = [ThemeManager sharedInstance].shimmeringOpacity;

    [view addSubview:shimmeringView];

    UIView *progressView = [[UIView alloc] initWithFrame:shimmeringView.bounds];
    progressView.backgroundColor = [ThemeManager sharedInstance].shimmeringColor;
    shimmeringView.contentView = progressView;

    return shimmeringView;
}



@end