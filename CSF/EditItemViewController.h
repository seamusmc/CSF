//
//  EditItemViewController.h
//  CSF
//
//  Created by Seamus McGowan on 3/3/15.
//  Copyright (c) 2015 Seamus McGowan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@class OrderItem;

@protocol EditItemViewControllerDelegate <NSObject>

@optional
- (void) itemEdited;

@end

@interface EditItemViewController : BaseViewController

@property(nonatomic, strong) NSString *orderDate;
@property(nonatomic, strong) OrderItem *orderItem;

@property(nonatomic, weak) id <EditItemViewControllerDelegate> delegate;

@end
