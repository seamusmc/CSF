//
//  ItemViewController.m
//  CSF
//
//  Created by Seamus McGowan on 8/15/14.
//  Copyright (c) 2014 Seamus McGowan. All rights reserved.
//

#import <Shimmer/FBShimmeringView.h>
#import "ItemViewController.h"
#import "ThemeManager.h"
#import "PickerView.h"
#import "FarmDataService.h"
#import "UserServices.h"
#import "User.h"
#import "ActivityIndicator.h"
#import "FBShimmeringView+Extended.h"
#import "DDLogMacros.h"
#import "InventoryItem.h"
#import "NSDictionary+NSDictionary_Extended.h"

static const int kItemsPickerViewTag = 10;

static NSString *const kPriceLabelFormatString = @"price %@";
static NSString *const kInStockLabelFormatString = @"in stock? %@";

@interface ItemViewController () <UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, UINavigationControllerDelegate, UITextViewDelegate>

@property(nonatomic, copy) NSArray *labels;
@property(nonatomic, copy) NSArray *fields;

@property(nonatomic, copy) NSArray *items;                              // The current list of items for the current type.
@property(nonatomic, strong) NSMutableDictionary *itemsDictionary;      // Cache of items keyed by type.

@property(nonatomic, weak) IBOutlet UILabel *typeLabel;
@property(nonatomic, weak) IBOutlet UILabel *itemLabel;
@property(nonatomic, weak) IBOutlet UILabel *priceLabel;
@property(nonatomic, weak) IBOutlet UILabel *stockLabel;
@property(nonatomic, weak) IBOutlet UILabel *quantityLabel;
@property(nonatomic, weak) IBOutlet UILabel *commentLabel;

@property(nonatomic, weak) IBOutlet UITextField *typeTextField;
@property(nonatomic, weak) IBOutlet UITextField *itemTextField;
@property(nonatomic, weak) IBOutlet UITextField *quantityTextField;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property(nonatomic, weak) IBOutlet UITextView *commentTextView;
@property(nonatomic, weak) IBOutlet UIButton   *addButton;
@property(nonatomic, weak) FBShimmeringView    *activityIndicator;

//@property(nonatomic) BOOL shouldScroll;

@end

@implementation ItemViewController

#pragma mark - Lifecycle

- (void)viewDidLayoutSubviews {
    self.scrollView.contentSize = CGSizeMake(320, self.view.frame.size.height * 2);  // Basically two pages tall.
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.itemsDictionary = [[NSMutableDictionary alloc] init];
    //self.shouldScroll = NO;

    self.view.backgroundColor = [UIColor clearColor];
    [self configureLabels];
    [self configureFields];
    [self configureCommentTextView];
    [self configureButton];
    [self configureTypesPicker];
    [self configureItemsPicker];

    self.typeTextField.text = self.types[0];

    [self getItemsForType:self.types[0]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self registerForKeyboardNotifications];
}

- (void)viewDidDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    [super viewDidDisappear:animated];
}

- (FBShimmeringView *)activityIndicator {
    if (_activityIndicator == nil) {
        _activityIndicator = [[ActivityIndicator sharedInstance] createActivityIndicator:self.view];
    }

    return _activityIndicator;
}

#pragma mark - UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView {
//    self.shouldScroll = YES;
    self.commentTextView;
}

- (void)textViewDidEndEditing:(UITextView *)textView {
//    self.shouldScroll = NO;
    [self scrollViewDown];
}

#pragma mark - UITextFieldDelegate

// 'Scroll' the view's frame up to accommodate the keyboard if necessary.
- (void)textFieldDidBeginEditing:(UITextField *)textField {
//    if ([textField isEqual:self.quantityTextField]) {
//        if (self.view.frame.size.height == 480) {
//            activeField = textField;
//        }
//    }
    textField;
}

// 'Scroll' the view's frame down when the keyboard is removed.
- (void)textFieldDidEndEditing:(UITextField *)textField {
//    activeField = nil;
    textField;
}

- (BOOL) textFieldShouldReturn:(UITextField*)textField {
    [textField resignFirstResponder];
    return YES;
}

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

- (void)registerForKeyboardNotifications {

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShowNotification:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)keyboardWasShown:(NSNotification*)notification {
    NSDictionary* info = [notification userInfo];
    [self scrollViewUp:info];
}

- (void)keyboardWillBeHidden:(NSNotification*)notification {
    [self scrollViewDown];
}

- (void)keyboardWillShowNotification:(NSNotification *)notification {
    // Only handle this notification if a UIPickerView is going to
    // be shown. We want to keep the picker and textField in sync.
    for (UIView *view in self.view.subviews) {
        if ([view.inputView isMemberOfClass:[PickerView class]]) {
            if ([view isFirstResponder]) {
                PickerView *pickerView = (PickerView *) view.inputView;

                NSInteger index;
                if (pickerView.tag == kItemsPickerViewTag) {
                    index = [self.types indexOfObject:self.itemTextField.text];
                } else {
                    index = [self.types indexOfObject:self.typeTextField.text];
                }

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
        InventoryItem *item = self.items[row];
        label.text = item.name;
    } else {
        label.text = self.types[row];
    }

    return label;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (pickerView.tag == kItemsPickerViewTag) {
        NSString *temp = self.itemTextField.text;
        if (![temp isEqualToString:(NSString *) self.items[row]]) {
            [self populateItemFields:self.items[row]];
        }
    } else {
        NSString *temp = self.typeTextField.text;
        if (![temp isEqualToString:(NSString *)self.types[row]]) {
            self.typeTextField.text = (NSString *) self.types[row];
            [self getItemsForType:self.types[row]];
        }
    }
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (pickerView.tag == kItemsPickerViewTag) {
        return self.items.count;
    } else {
        return self.types.count;
    }
}

#pragma mark - Gesture Handling

- (IBAction)handleTapGesture:(UITapGestureRecognizer *)sender {
    [self.view endEditing:YES];
}

#pragma mark - Private Methods

- (void)getItemsForType:(NSString *)type {
    // We'll cache the items for each type selected in a dictionary, for the life of this VC.
    if ([self.itemsDictionary containsKey:type]) {
        self.items = self.itemsDictionary[type];

        [self populateItemFields:self.items[0]];

        UIPickerView *picker = (UIPickerView *) self.itemTextField.inputView;
        [picker reloadComponent:0];
    } else {
        [self.activityIndicator start];
        [self disableControls];

        __typeof(self) __weak weakSelf = self;
        [[FarmDataService sharedInstance] getItemsForFarm:[UserServices sharedInstance].currentUser.farm
                                                     type:type
                                             successBlock:^(NSArray *items) {
                                                 dispatch_async(dispatch_get_main_queue(), ^{
                                                     [weakSelf enableControls];
                                                     [weakSelf.activityIndicator stop];

                                                     weakSelf.itemsDictionary[type] = items;
                                                     weakSelf.items = weakSelf.itemsDictionary[type];

                                                     [weakSelf populateItemFields:items[0]];

                                                     UIPickerView *picker = (UIPickerView *) self.itemTextField.inputView;
                                                     [picker reloadComponent:0];
                                                 });
                                             }
                                             failureBlock:^(NSString *message) {
                                                 dispatch_async(dispatch_get_main_queue(), ^{
                                                     [weakSelf enableControls];
                                                     [weakSelf.activityIndicator stop];
                                                     DDLogError(@"ERROR: %s Problem getting items.", __PRETTY_FUNCTION__);
                                                     //[weakSelf displayFailureMessage:message];
                                                 });
                                             }];
    }
}

- (void)enableControls {
    self.addButton.enabled         = YES;
    self.itemTextField.enabled     = YES;
    self.quantityTextField.enabled = YES;

    self.commentTextView.userInteractionEnabled         = YES;
    self.typeTextField.inputView.userInteractionEnabled = YES;
}

- (void)disableControls {
    self.addButton.enabled         = NO;
    self.itemTextField.enabled     = NO;
    self.quantityTextField.enabled = NO;

    self.commentTextView.userInteractionEnabled         = NO;
    self.typeTextField.inputView.userInteractionEnabled = NO;
}

- (void)populateItemFields:(InventoryItem *)item {
    self.itemTextField.text = item.name;
    self.priceLabel.text = [NSString stringWithFormat:kPriceLabelFormatString, item.formattedPrice];

    NSString *inStock = @"yes";
    if (item.outOfStock == YES) {
        inStock = @"no";
    }
    self.stockLabel.text = [NSString stringWithFormat:kInStockLabelFormatString, inStock];
}

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

    self.commentTextView.delegate = self;

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

- (void)scrollViewUp:(NSDictionary *)info {
//    if (self.shouldScroll == NO) {
//        return;
//    }

    // Find the first responder, if it is one we are interested in, scroll up
    // otherwise ignore.
    for (UIView *view in self.view.subviews) {
        if ([view isKindOfClass:[UIScrollView class]]) {
            for (UIView *subview in view.subviews) {
                if (subview.isFirstResponder) {
                    if (![subview isEqual:self.commentTextView]) {
                        return;
                    }
                    break;
                }
            }
            break;
        }
    }

    CGSize  keyboardSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    CGPoint point;
    if (self.view.frame.size.height == 480) {
        point = CGPointMake(0, keyboardSize.height / 1.25);

    } else {
        point = CGPointMake(0, keyboardSize.height / 2);
    }

    [self.scrollView setContentOffset:point animated:YES];
}

- (void)scrollViewDown {
    [self.scrollView setContentSize:self.view.frame.size];
    [self.scrollView setContentOffset:CGPointZero animated:YES];
    //self.shouldScroll = NO;
}

@end
