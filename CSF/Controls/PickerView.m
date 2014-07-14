//
// Created by Seamus McGowan on 7/14/14.
// Copyright (c) 2014 Seamus McGowan. All rights reserved.
//

#import "PickerView.h"
#import "ThemeManager.h"
#import "UIColor+Extended.h"
#import "UIImageView+Extended.h"
#import "PickerViewAccessoryDelegate.h"

@interface PickerView ()

@property(nonatomic, strong, readwrite) UIView *inputAccessory;
@property(nonatomic, strong, readonly) NSString *title;
@property(nonatomic, strong, readonly) UIImage *backgroundImage;

@end

@implementation PickerView

- (instancetype)initWithTitle:(NSString *)title backgroundImage:(UIImage *)backgroundImage frame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _title           = title;
        _backgroundImage = backgroundImage;

        self.showsSelectionIndicator = YES;
    }
    return self;
}

- (UIView *)inputAccessory {
    if (_inputAccessory == nil) {
        _inputAccessory = [self configureInputAccessory];
    }

    return _inputAccessory;
}

#pragma mark - Private Methods

- (void)doneAction {
    if (self.accessoryDelegate != nil) {
        [self.accessoryDelegate done];
    }
}

- (UIView *)configureInputAccessory {
    UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.frame.size.width, 45.0f)];
    toolBar.barStyle    = UIBarStyleBlackTranslucent;
    toolBar.translucent = YES;

    // Making my own because the system ones are not centering vertically????
    UIButton *button = [[UIButton alloc] init];
    button.tintColor       = [UIColor whiteColor];
    button.titleLabel.font = [[ThemeManager sharedInstance] fontWithSize:20.0f];

    [button setTitle:@"done" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(doneAction) forControlEvents:UIControlEventTouchUpInside];
    [button sizeToFit];

    UILabel *title = [[UILabel alloc] init];
    title.text = @"select a farm";            // Need the spaces for the title to center horizontally?
    title.font = [[ThemeManager sharedInstance] fontWithSize:21.0f];
    [title sizeToFit];
    title.textColor = [UIColor whiteColor];

    UIBarButtonItem *flexible     = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                  target:nil
                                                                                  action:nil];
    UIBarButtonItem *toolBarTitle = [[UIBarButtonItem alloc] initWithCustomView:title];
    UIBarButtonItem *doneButton   = [[UIBarButtonItem alloc] initWithCustomView:button];

    // the middle button is to make the Done button align to right
    [toolBar setItems:[NSArray arrayWithObjects:flexible,
                                                toolBarTitle,
                                                flexible,
                                                doneButton,
                                                nil]];
    return toolBar;
}

// Ugly hack to customize the UIPickerView to have a translucent look, as it originally had in iOS7
- (void)configureView{
    static dispatch_once_t onceToken;

    // We only need or want to do this once, because of how we have to execute this hack.
    dispatch_once(&onceToken, ^{
        // Make the selection indicators white with an alpha so that they are visible.
        UIView *temp = self.subviews[1];
        temp.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.5f];

        temp = self.subviews[2];
        temp.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.5f];

        // All we need is the bottom of the background image.
        CGRect rect = CGRectMake(0,
                                 self.backgroundImage.size.height - self.bounds.size.height,
                                 self.bounds.size.width,
                                 self.bounds.size.height);

        UIImage *croppedImage = [self getSubImageFrom:self.backgroundImage
                                             WithRect:rect];

        UIImageView *imageView = [[UIImageView alloc] initWithImage:croppedImage];
        imageView.bounds      = self.bounds;
        imageView.contentMode = UIViewContentModeBottom | UIViewContentModeRedraw;
        [imageView tintWithColor:[UIColor colorWithRGBHex:0x000000 alpha:0.5f]];

        [self insertSubview:imageView atIndex:0];

        // Use the UIToolbar as an overlay, it still can give us the blurred or translucent effect we are after.
        UIToolbar *overlayHack = [[UIToolbar alloc] initWithFrame:self.bounds];
        overlayHack.barStyle    = UIBarStyleBlackTranslucent;
        overlayHack.translucent = YES;

        [self insertSubview:overlayHack atIndex:1];
    });
}

- (UIImage *)getSubImageFrom:(UIImage *)img WithRect:(CGRect)rect {

    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();

    // translated rectangle for drawing sub image
    CGRect drawRect = CGRectMake(-rect.origin.x, -rect.origin.y, img.size.width, img.size.height);

    // clip to the bounds of the image context
    // not strictly necessary as it will get clipped anyway?
    CGContextClipToRect(context, CGRectMake(0, 0, rect.size.width, rect.size.height));

    // draw image
    [img drawInRect:drawRect];

    // grab image
    UIImage *subImage = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();

    return subImage;
}

@end