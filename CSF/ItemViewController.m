//
//  ItemViewController.m
//  CSF
//
//  Created by Seamus McGowan on 8/15/14.
//  Copyright (c) 2014 Seamus McGowan. All rights reserved.
//

#import "ItemViewController.h"
#import "ThemeManager.h"
#import "PickerView.h"

static const int kItemsPickerViewTag = 10;

@interface ItemViewController () <UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, UINavigationControllerDelegate>

@property(nonatomic, strong) NSArray *labels;
@property(nonatomic, strong) NSArray *fields;

@property(nonatomic, weak) IBOutlet UILabel *typeLabel;
@property(nonatomic, weak) IBOutlet UILabel *itemLabel;
@property(nonatomic, weak) IBOutlet UILabel *priceLabel;
@property(nonatomic, weak) IBOutlet UILabel *stockLabel;
@property(nonatomic, weak) IBOutlet UILabel *quantityLabel;
@property(nonatomic, weak) IBOutlet UILabel *commentLabel;

@property(nonatomic, weak) IBOutlet UITextField *typeTextField;
@property(nonatomic, weak) IBOutlet UITextField *itemTextField;
@property(nonatomic, weak) IBOutlet UITextField *quantityTextField;

@property(nonatomic, weak) IBOutlet UITextView *commentTextView;

@property(nonatomic, weak) IBOutlet UIButton *addButton;

@end

@implementation ItemViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor clearColor];
    [self configureLabels];
    [self configureFields];
    [self configureCommentTextView];
    [self configureButton];
    [self configureTypesPicker];
    [self configureItemsPicker];

    self.typeTextField.text = self.types[0];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(inputViewWillShowNotification:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField == self.quantityTextField) {
        // Would love to use the Fractions field on item to allow or disallow decimal values, but it
        // doesn't seem to be used. Have to default to allowing fractions, the item will be rejected
        // if its not supposed to have a fractional count. Could be due to test data not being populated
        // correctly.

        NSString *newString  = [textField.text stringByReplacingCharactersInRange:range withString:string];
        NSString *expression = @"^([0-9]+)?(\\.([0-9]{1,2})?)?$";

        // Fractions flag is not populated!
//        if (self.currentItem.fractions)
//            expression = @"^([0-9]+)?(\\.([0-9]{1,2})?)?$";
//        else
//            expression = @"^([0-9]+)?$";

        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:expression
                                                                               options:NSRegularExpressionCaseInsensitive
                                                                                 error:nil];

        NSUInteger numberOfMatches = [regex numberOfMatchesInString:newString
                                                            options:0
                                                              range:NSMakeRange(0, [newString length])];
        double number = [newString doubleValue];
        if (number <= 0 && ([newString length] != 0)) {
            self.quantityTextField.textColor = [ThemeManager sharedInstance].errorFontColor;
            self.quantityLabel.textColor     = [ThemeManager sharedInstance].errorFontColor;
        } else {
            self.quantityTextField.textColor = [ThemeManager sharedInstance].normalFontColor;
            self.quantityLabel.textColor     = [ThemeManager sharedInstance].normalFontColor;
        }

        if (numberOfMatches == 0)
            return NO;
    }

    return YES;
}

#pragma mark - Notifications

- (void)inputViewWillShowNotification:(NSNotification *)notification {
    // Only handle this notification if a UIPickerView is going to
    // be shown. We want to keep the picker and textField in sync.
    for (UIView *view in self.view.subviews) {
        if ([view.inputView isMemberOfClass:[PickerView class]]) {
            if ([view isFirstResponder]) {
                PickerView *pickerView = (PickerView *) view.inputView;

                NSInteger index = [self.types indexOfObject:self.typeTextField.text];

                [pickerView selectRow:index inComponent:0 animated:NO];
            }

            break;
        }
    }
}

#pragma mark - UIPickerViewDelegate

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    [(PickerView *) pickerView configureView];      // Need to figure out how to do this within the PickerView subclass.

    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, pickerView.frame.size.width, 44)];

    label.textColor     = [ThemeManager sharedInstance].normalFontColor;
    label.font          = [ThemeManager sharedInstance].normalFont;
    label.textAlignment = NSTextAlignmentCenter;

    if (pickerView.tag == kItemsPickerViewTag) {
        label.text = @"test";
    } else {
        label.text = self.types[row];
    }

    return label;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.typeTextField.text = (NSString *) [self.types objectAtIndex:row];
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (pickerView.tag == kItemsPickerViewTag) {
        return 3;
    } else {
        return [self.types count];
    }
}

#pragma mark - Gesture Handling

- (IBAction)handleTapGesture:(UITapGestureRecognizer *)sender {
    [self.view endEditing:YES];
}

#pragma mark - Private Methods

- (void)configureTypesPicker {
    CGRect rect = CGRectMake(0.0f, 0.0f, self.view.frame.size.width, 216.0f);
    PickerView *typesPicker = [[PickerView alloc] initWithTitle:@"select a type" backgroundImage:[UIImage imageNamed:@"farm"] frame:rect];

    typesPicker.delegate                = self;
    typesPicker.dataSource              = self;
    typesPicker.showsSelectionIndicator = YES;

    self.typeTextField.inputView = typesPicker;
}

- (void)configureItemsPicker {
    CGRect rect = CGRectMake(0.0f, 0.0f, self.view.frame.size.width, 216.0f);
    PickerView *itemsPicker = [[PickerView alloc] initWithTitle:@"select a type" backgroundImage:[UIImage imageNamed:@"farm"] frame:rect];

    itemsPicker.delegate                = self;
    itemsPicker.dataSource              = self;
    itemsPicker.showsSelectionIndicator = YES;
    itemsPicker.tag                     = kItemsPickerViewTag;

    self.itemTextField.inputView = itemsPicker;
}

- (void)configureCommentTextView {
    self.commentTextView.font      = [ThemeManager sharedInstance].normalFont;
    self.commentTextView.textColor = [ThemeManager sharedInstance].normalFontColor;

    self.commentTextView.backgroundColor = [ThemeManager sharedInstance].tintColor;

    [self.commentTextView  setTextContainerInset:UIEdgeInsetsMake(5, 10, 10, 10)];

    self.commentTextView.layer.cornerRadius = 5.0f;
    self.commentTextView.layer.borderWidth  = 1.0f;
    self.commentTextView.layer.borderColor  = [ThemeManager sharedInstance].tintColor.CGColor;

    self.commentTextView.keyboardAppearance = UIKeyboardAppearanceAlert;
}


- (void)configureLabels {
    self.labels = @[self.typeLabel, self.itemLabel, self.priceLabel, self.stockLabel, self.quantityLabel, self.commentLabel];
    for (UILabel *label in self.labels) {
        label.font = [ThemeManager sharedInstance].normalFont;
        label.textColor = [ThemeManager sharedInstance].normalFontColor;
    }
}

- (void)configureButton {
    self.addButton.titleLabel.font = [ThemeManager sharedInstance].normalFont;

    [self.addButton setTitleColor:[ThemeManager sharedInstance].normalFontColor forState:UIControlStateNormal];
    [self.addButton setTitleColor:[ThemeManager sharedInstance].disabledColor forState:UIControlStateDisabled];

    self.addButton.layer.cornerRadius = 5.0f;
    self.addButton.layer.borderWidth  = 1.0f;
    self.addButton.layer.borderColor  = [ThemeManager sharedInstance].tintColor.CGColor;

    self.addButton.backgroundColor = [ThemeManager sharedInstance].tintColor;
}

- (void)configureFields {
    self.fields = @[self.typeTextField, self.itemTextField, self.quantityTextField];

    for (UITextField *field in self.fields) {
        field.font      = [ThemeManager sharedInstance].normalFont;
        field.textColor = [ThemeManager sharedInstance].normalFontColor;

        field.delegate = self;

        field.borderStyle     = UITextBorderStyleRoundedRect;
        field.backgroundColor = [ThemeManager sharedInstance].tintColor;

        field.layer.cornerRadius = 5.0f;
        field.layer.borderWidth  = 1.0f;
        field.layer.borderColor  = [ThemeManager sharedInstance].tintColor.CGColor;

        if ([field isEqual:self.quantityTextField]) {
            field.keyboardType = UIKeyboardTypeDecimalPad;
        }

        field.keyboardAppearance = UIKeyboardAppearanceAlert;

        UIColor  *color       = [ThemeManager sharedInstance].placeHolderFontColor;
        UIFont   *font        = [ThemeManager sharedInstance].placeHolderFont;
        NSString *placeholder = field.placeholder;
        if (placeholder) {
            field.attributedPlaceholder = [[NSAttributedString alloc] initWithString:placeholder
                                                                          attributes:@{NSForegroundColorAttributeName : color,
                                                                                       NSFontAttributeName            : font}];
        }
    }
}

@end
