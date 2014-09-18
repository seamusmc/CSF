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
#import "OrderDataService.h"
#import "OrderItem.h"

static const int kItemsPickerViewTag = 10;
static const int kCommentMaxLength = 128;

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
@property(nonatomic, weak) IBOutlet UILabel *notificationLabel;

@property(nonatomic, weak) IBOutlet UITextField *typeTextField;
@property(nonatomic, weak) IBOutlet UITextField *itemTextField;
@property(nonatomic, weak) IBOutlet UITextField *quantityTextField;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property(nonatomic, weak) IBOutlet UITextView *commentTextView;
@property(nonatomic, weak) IBOutlet UIButton   *addButton;
@property(nonatomic, weak) FBShimmeringView    *activityIndicator;

@property (nonatomic, strong, readonly) NSDateFormatter* dateFormatter;

@property(nonatomic, assign) BOOL addedItem;

@end

@implementation ItemViewController {
    NSDateFormatter *_dateFormatter;
}

#pragma mark - Lifecycle

- (void)willMoveToParentViewController:(UIViewController *)parent {
    [super didMoveToParentViewController:parent];

    if (self.delegate != nil) {
        if (self.addedItem == YES) {
            [self.delegate itemAdded];
        }
    }
}

- (void)viewDidLayoutSubviews {
    self.scrollView.contentSize = CGSizeMake(320, self.view.frame.size.height * 2);  // Basically two pages tall.
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.itemsDictionary = [[NSMutableDictionary alloc] init];

    self.view.backgroundColor = [UIColor clearColor];
    [self configureLabels];
    [self configureFields];
    [self configureCommentTextView];
    [self configureButton];
    [self configureTypesPicker];
    [self configureItemsPicker];
    [self configureNotificationLabelForErrors];

    self.scrollView.scrollEnabled = NO;
    self.addedItem = NO;

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

#pragma mark - Actions

- (IBAction)addButtonHandler {
    [self.activityIndicator start];
    [self disableControls];

    OrderItem *orderItem = [[OrderItem alloc] initWithName:self.itemTextField.text
                                                      type:self.typeTextField.text
                                                     price:[NSDecimalNumber decimalNumberWithString:self.priceLabel.text]
                                                  quantity:[NSDecimalNumber decimalNumberWithString:self.quantityTextField.text]
                                                   comment:self.commentTextView.text];

    NSDate *date = [self.dateFormatter dateFromString:self.orderDate];

    __typeof(self) __weak weakSelf = self;
    [[OrderDataService sharedInstance] addItem:orderItem
                                             user:[UserServices sharedInstance].currentUser
                                             date:date
                                     successBlock:^{
                                         // Not necessary to stop the activity indicator, call to refresh order will do it for us.
                                         dispatch_async(dispatch_get_main_queue(), ^{
                                             [weakSelf enableControls];
                                             [weakSelf.activityIndicator stop];

                                             // Indicate successful addition
                                             NSLog(@"Successfully added item.");

                                             self.addedItem = YES;
                                         });
                                     }
                                     failureBlock:^(NSString *message) {
                                         dispatch_async(dispatch_get_main_queue(), ^{
                                             [weakSelf enableControls];
                                             [weakSelf.activityIndicator stop];

                                             // Display issue message
                                             NSLog(@"Encountered error adding item: %@", message);
                                         });
                                     }];
}


#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }

    NSUInteger newLength = (textView.text.length - range.length) + text.length;
    return newLength <= kCommentMaxLength;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    CGFloat keyboardHeight;
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_7_1){
        keyboardHeight = kKeyboardHeightWithAccessory;
    } else {
        keyboardHeight = kKeyboardHeight;
    }

    [self scrollViewUp:keyboardHeight];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    self.commentTextView.text = [self.commentTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [self scrollViewDown];
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [self scrollViewDown];
}

- (BOOL) textFieldShouldReturn:(UITextField*)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if ([textField isEqual:self.quantityTextField]) {
        double value = [textField.text doubleValue];

        if (value > 0) {
            self.addButton.enabled = YES;
        } else {
            self.addButton.enabled = NO;
        }
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([textField isEqual:self.quantityTextField]) {
        NSString *newString  = [textField.text stringByReplacingCharactersInRange:range withString:string];
        NSString *expression = @"^([0-9]+)?(\\.([0-9]{1,2})?)?$";

        // Would love to use the Fractions field on item to allow or disallow decimal values, but it
        // doesn't seem to be used. Have to default to allowing fractions, the item will be 'truncated'
        // if its not supposed to have a fractional count. Could be due to test data not being populated
        // correctly.

        // Fractions flag is not populated!
//        if (self.currentItem.fractions == YES)
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
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
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

#pragma mark - Property Overrides

- (FBShimmeringView *)activityIndicator {
    if (_activityIndicator == nil) {
        _activityIndicator = [[ActivityIndicator sharedInstance] createActivityIndicator:self.view];
    }

    return _activityIndicator;
}

- (NSDateFormatter *)dateFormatter {
    if (_dateFormatter == nil) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateStyle:NSDateFormatterShortStyle];
        [_dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    }

    return _dateFormatter;
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
    double value = [self.quantityTextField.text doubleValue];
    if (value > 0) {
        self.addButton.enabled = YES;
    } else {
        self.addButton.enabled = NO;
    }

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

- (void)configureNotificationLabelForSuccess {
    self.notificationLabel.font      = [ThemeManager sharedInstance].successFont;
    self.notificationLabel.textColor = [ThemeManager sharedInstance].successFontColor;
    self.notificationLabel.hidden    = YES;
}

- (void)configureNotificationLabelForErrors {
    self.notificationLabel.font      = [ThemeManager sharedInstance].errorFont;
    self.notificationLabel.textColor = [ThemeManager sharedInstance].errorFontColor;
    self.notificationLabel.hidden    = YES;
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
    self.commentTextView.returnKeyType      = UIReturnKeyDone;
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
    self.addButton.enabled = NO;
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

- (UIView *)findFirstResponderInScrollView {
    for (UIView *view in self.scrollView.subviews) {
        if (view.isFirstResponder) {
            return view;
        }
    }

    return nil;
}

- (void)scrollViewUp:(CGFloat)height {
    UIView *firstResponder = [self findFirstResponderInScrollView];
    if (![firstResponder isEqual:self.commentTextView]) {
        return;
    }

    self.scrollView.scrollEnabled = YES;

    CGPoint point;
    if (self.view.frame.size.height == 480) {
        point = CGPointMake(0, height / 1.3f);
    } else {
        point = CGPointMake(0, height / 2.35f);
    }

    [self.scrollView setContentOffset:point animated:YES];
}

- (void)scrollViewDown {
    [self.scrollView setContentOffset:CGPointZero animated:YES];
    self.scrollView.scrollEnabled = NO;
}

@end
