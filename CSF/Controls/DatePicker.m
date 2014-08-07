//
// Created by Seamus McGowan on 8/5/14.
// Copyright (c) 2014 Seamus McGowan. All rights reserved.
//

#import "DatePicker.h"
#import "UIColor+Extended.h"
#import "UIImageView+Extended.h"

@implementation DatePicker

- (instancetype)init {
    self = [super init];
    if (self) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self configurePicker];
        });
    }

    return self;
}


- (void)configurePicker {
    UIView *pickerView = self.subviews[0];

    // Make the selection indicators white with an alpha so that they are visible.
    UIView *temp = pickerView.subviews[1];
    temp.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.5f];

    temp = pickerView.subviews[2];
    temp.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.5f];

    // All we need is the bottom of the background image.
    UIImage *backgroundImage = [UIImage imageNamed:@"farm"];
    CGRect  rect             = CGRectMake(0,
                                          backgroundImage.size.height - pickerView.bounds.size.height,
                                          pickerView.bounds.size.width,
                                          pickerView.bounds.size.height);

    UIImage *croppedImage = [self getSubImageFrom:backgroundImage
                                         WithRect:rect];

    UIImageView *imageView = [[UIImageView alloc] initWithImage:croppedImage];
    imageView.bounds      = self.bounds;
    imageView.contentMode = UIViewContentModeBottom | UIViewContentModeRedraw;
    [imageView tintWithColor:[UIColor colorWithRGBHex:0x000000 alpha:0.5f]];

    [pickerView insertSubview:imageView atIndex:0];

    // Use the UIToolbar as an overlay, it still can give us the blurred or translucent effect we are after.
    UIToolbar *overlayHack = [[UIToolbar alloc] initWithFrame:self.bounds];
    overlayHack.barStyle    = UIBarStyleBlackTranslucent;
    overlayHack.translucent = YES;

    [pickerView insertSubview:overlayHack atIndex:1];
}

- (UIImage *)getSubImageFrom:(UIImage *)img WithRect:(CGRect)rect {
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();

    // Translated rectangle for drawing sub image
    CGRect drawRect = CGRectMake(-rect.origin.x, -rect.origin.y, img.size.width, img.size.height);

    // Clip to the bounds of the image context
    // not strictly necessary as it will get clipped anyway?
    CGContextClipToRect(context, CGRectMake(0, 0, rect.size.width, rect.size.height));

    // Draw image
    [img drawInRect:drawRect];

    // Grab image
    UIImage *subImage = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();

    return subImage;
}

@end