//
//  ItemViewController.h
//  CSF
//
//  Created by Seamus McGowan on 8/15/14.
//  Copyright (c) 2014 Seamus McGowan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@protocol ItemViewControllerDelegate <NSObject>

@optional
- (void) itemAdded;

@end

@interface ItemViewController : BaseViewController

@property(nonatomic, strong) NSArray  *types;
@property(nonatomic, strong) NSString *orderDate;

@property(nonatomic, weak) id <ItemViewControllerDelegate> delegate;

- (void)enableControls;

@end
