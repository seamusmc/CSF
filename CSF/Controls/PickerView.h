//
// Created by Seamus McGowan on 7/14/14.
// Copyright (c) 2014 Seamus McGowan. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PickerViewAccessoryDelegate;

@interface PickerView : UIPickerView

@property(nonatomic, strong, readonly) UIView *inputAccessory;
@property(nonatomic, strong) id <PickerViewAccessoryDelegate> accessoryDelegate;

- (instancetype)initWithTitle:(NSString *)title backgroundImage:(UIImage *)backgroundImage frame:(CGRect)frame;
- (void)configureView;

@end