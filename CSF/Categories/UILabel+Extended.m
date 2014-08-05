//
// Created by Seamus McGowan on 8/5/14.
// Copyright (c) 2014 Seamus McGowan. All rights reserved.
//

#import <objc/runtime.h>
#import "UILabel+Extended.h"
#import "ThemeManager.h"

@implementation UILabel (Extended)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self swizzleInstanceSelector:@selector(setTextColor:) withNewSelector:@selector(swizzledSetTextColor:)];
        [self swizzleInstanceSelector:@selector(willMoveToSuperview:) withNewSelector:@selector(swizzledWillMoveToSuperview:)];
        [self swizzleInstanceSelector:@selector(setFont:) withNewSelector:@selector(swizzledSetFont:)];
        [self swizzleInstanceSelector:@selector(setText:) withNewSelector:@selector(swizzledSetText:)];

    });
}

- (void)swizzledSetText:(NSString *)text {
    if ([self view:self hasSuperviewOfClass:[UIDatePicker class]] ||
        [self view:self hasSuperviewOfClass:NSClassFromString(@"UIDatePickerWeekMonthDayView")] ||
        [self view:self hasSuperviewOfClass:NSClassFromString(@"UIDatePickerContentView")]) {

        [self swizzledSetText:[text lowercaseString]];
    } else {
        //Carry on with the default
        [self swizzledSetText:text];
    }
}

- (void)swizzledSetFont:(UIFont *)font {
    if ([self view:self hasSuperviewOfClass:[UIDatePicker class]] ||
        [self view:self hasSuperviewOfClass:NSClassFromString(@"UIDatePickerWeekMonthDayView")] ||
        [self view:self hasSuperviewOfClass:NSClassFromString(@"UIDatePickerContentView")]) {

        [self swizzledSetFont:[ThemeManager sharedInstance].normalFont];
    } else {
        //Carry on with the default
        [self swizzledSetFont:font];
    }
}

// Forces the text colour of the label to be white only for UIDatePicker and its components
- (void)swizzledSetTextColor:(UIColor *)textColor {
    if ([self view:self hasSuperviewOfClass:[UIDatePicker class]] ||
        [self view:self hasSuperviewOfClass:NSClassFromString(@"UIDatePickerWeekMonthDayView")] ||
        [self view:self hasSuperviewOfClass:NSClassFromString(@"UIDatePickerContentView")]) {

//        label.font          = [ThemeManager sharedInstance].normalFont;

        [self swizzledSetTextColor:[ThemeManager sharedInstance].normalFontColor];
    } else {
        //Carry on with the default
        [self swizzledSetTextColor:textColor];
    }
}

// Some of the UILabels haven't been added to a superview yet so listen for when they do.
- (void)swizzledWillMoveToSuperview:(UIView *)newSuperview {
    [self swizzledSetTextColor:self.textColor];
    [self swizzledWillMoveToSuperview:newSuperview];
}

// -- helpers --
- (BOOL)view:(UIView *)view hasSuperviewOfClass:(Class)class {
    if (view.superview) {
        if ([view.superview isKindOfClass:class]) {
            return true;
        }
        return [self view:view.superview hasSuperviewOfClass:class];
    }
    return false;
}

+ (void)swizzleInstanceSelector:(SEL)originalSelector
                withNewSelector:(SEL)newSelector {
    Method originalMethod = class_getInstanceMethod(self, originalSelector);
    Method newMethod      = class_getInstanceMethod(self, newSelector);

    BOOL methodAdded = class_addMethod([self class],
                                       originalSelector,
                                       method_getImplementation(newMethod),
                                       method_getTypeEncoding(newMethod));

    if (methodAdded) {
        class_replaceMethod([self class],
                            newSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, newMethod);
    }
}

@end