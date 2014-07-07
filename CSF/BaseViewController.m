//
//  BaseViewController.m
//  CSF
//
//  Created by Seamus McGowan on 7/7/14.
//  Copyright (c) 2014 Seamus McGowan. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.screenName = NSStringFromClass([self class]);
}

@end
