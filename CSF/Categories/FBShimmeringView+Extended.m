//
// Created by Seamus McGowan on 7/16/14.
// Copyright (c) 2014 Seamus McGowan. All rights reserved.
//

#import "FBShimmeringView+Extended.h"


@implementation FBShimmeringView (Extended)

- (void)start {
    self.hidden = NO;
    self.shimmering = YES;
}

- (void)stop {
    self.hidden = YES;
    self.shimmering = NO;
}

@end