//
//  ItemViewController.h
//  CSF
//
//  Created by Seamus McGowan on 8/15/14.
//  Copyright (c) 2014 Seamus McGowan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface ItemViewController : BaseViewController

@property(nonatomic, strong) NSArray *types;

- (void)enableControls;
@end
