//
//  ItemViewController.m
//  CSF
//
//  Created by Seamus McGowan on 8/15/14.
//  Copyright (c) 2014 Seamus McGowan. All rights reserved.
//

#import "FBShimmeringView.h"
#import "ItemViewController.h"
#import "ThemeManager.h"
#import "FarmDataService.h"
#import "UserServices.h"
#import "User.h"
#import "ActivityIndicator.h"
#import "FBShimmeringView+Extended.h"
#import "InventoryItem.h"
#import "NSDictionary+NSDictionary_Extended.h"
#import "OrderDataService.h"
#import "OrderItem.h"

static const int kItemsPickerViewTag = 10;
static const int kCommentMaxLength   = 128;

static NSString *const kPriceLabelFormatString   = @"price %@";
static NSString *const kInStockLabelFormatString = @"in stock? %@";
static NSString *const kSuccessfullyAddedMessage = @"success";

static NSString *const kGetItemsErrorMessage = @"request timed out";

@interface ItemViewController () <UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, UINavigationControllerDelegate, UITextViewDelegate>

@property(nonatomic, copy) NSArray *labels;
@property(nonatomic, copy) NSArray *fields;

@property(nonatomic, copy) NSArray               *items;                // The current list of items for the current type.
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

@property(weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property(nonatomic, weak) IBOutlet UITextView *commentTextView;
@property(nonatomic, weak) IBOutlet UIButton   *addButton;
@property(nonatomic, weak) FBShimmeringView    *activityIndicator;

@property(nonatomic, strong, readonly) NSDateFormatter *dateFormatter;

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

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];

    [self configureNotificationLabel];
    [self configureNotificationLabelForSuccess:kSuccessfullyAddedMessage];
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
                                             [weakSelf.activityIndicator stop];
                                             [weakSelf displaySuccessMessage];

                                             weakSelf.addedItem = YES;

                                             dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t) (1.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                                 [weakSelf slideLabelToRightAndHide:weakSelf.notificationLabel];
                                                 [weakSelf enableControls];
                                             });
                                         });
                                     }
                                     failureBlock:^(NSString *message) {
                                         dispatch_async(dispatch_get_main_queue(), ^{
                                             [weakSelf enableControls];
                                             [weakSelf.activityIndicator stop];
                                             [weakSelf displayErrorMessage:message];
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

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([textField isEqual:self.quantityTextField]) {
        if ([self.itemTextField.text isEqualToString:kGetItemsErrorMessage]) {
            return NO;
        }

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

        double value;
        if (numberOfMatches == 0) {
            value = [self.quantityTextField.text doubleValue];
            [self enableOrDisableAddButtonBasedOnValue:value];

            return NO;
        } else {
            value = [newString doubleValue];
            [self enableOrDisableAddButtonBasedOnValue:value];

            return YES;
        }
    }

    return YES;
}

- (void)enableOrDisableAddButtonBasedOnValue:(double)value {
    if (value > 0) {
        self.addButton.enabled = YES;
    } else {
        self.addButton.enabled = NO;
    }
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
        if ([view.inputView isMemberOfClass:[UIPickerView class]]) {
            if ([view isFirstResponder]) {
                UIPickerView *pickerView = (UIPickerView *) view.inputView;

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

- (UIView *)pickerView:(UIPickerView *)pickerView
            viewForRow:(NSInteger)row
          forComponent:(NSInteger)component
           reusingView:(UIView *)view {
    
    // Customization needs to occur here in this delegate method.
    pickerView.backgroundColor = [UIColor clearColor];
    
    UIView *temp = pickerView.subviews[1];
    temp.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.5f];
    temp = pickerView.subviews[2];
    temp.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.5f];


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
    self.quantityTextField.text = nil;
    self.commentTextView.text   = nil;
    NSString *temp = nil;
    NSString *name = nil;

    if (pickerView.tag == kItemsPickerViewTag) {
        if ([self.itemTextField.text isEqualToString:kGetItemsErrorMessage]) {
            return;
        }
        
        temp = self.itemTextField.text;
        name = ((Item *) self.items[row]).name;
        if (![temp isEqualToString:name]) {
            [self populateItemFields:self.items[row]];
        }
    } else {
        temp = self.typeTextField.text;
        if (![temp isEqualToString:(NSString *)self.types[row]]) {          // self.types is an array of strings!
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
    [self resetNotificationState];
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

- (void)displayErrorMessage:(NSString *)message {
    [self configureNotificationLabelForError:message];
    [self displayNotificationMessage];
}

- (void)displaySuccessMessage {
    [self configureNotificationLabelForSuccess:kSuccessfullyAddedMessage];
    [self displayNotificationMessage];
}

- (void)displayNotificationMessage {
    [UIView animateWithDuration:0.4f
                     animations:^{
                         if (self.notificationLabel.hidden == NO) {
                             [self slideLabelToRightAndHide:self.notificationLabel];
                         }
                     }
                     completion:^(BOOL finished) {
                         if (self.notificationLabel.hidden == NO) {
                             dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t) (0.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                 [self slideLabelFromRight:self.notificationLabel];
                             });
                         } else {
                             [self slideLabelFromRight:self.notificationLabel];
                         }
                     }];
}

- (void)slideLabelFromRight:(UILabel *)label {
    // Make sure initial position is correct:
    label.hidden = YES;
    label.frame  = CGRectMake(-label.frame.size.width,
                              label.frame.origin.y,
                              label.frame.size.width,
                              label.frame.size.height);

    label.hidden = NO;
    [UIView animateWithDuration:[ThemeManager sharedInstance].notificationDuration
                          delay:[ThemeManager sharedInstance].notificationDelay
         usingSpringWithDamping:[ThemeManager sharedInstance].notificationDamping
          initialSpringVelocity:[ThemeManager sharedInstance].notificationInitialVelocity
                        options:UIViewAnimationOptionTransitionNone
                     animations:^{
                         CGFloat x = (label.superview.frame.size.width / 2) - (label.frame.size.width / 2);
                         CGFloat y = label.frame.origin.y;

                         CGRect rect = CGRectMake(x, y, label.frame.size.width, label.frame.size.height);
                         label.frame = rect;
                     }
                     completion:nil];
}

- (void)slideLabelToRightAndHide:(UILabel *)label {
    [UIView animateWithDuration:0.5
                     animations:^{
                         label.frame = CGRectMake(self.view.frame.size.width + label.frame.size.width,
                                                  label.frame.origin.y,
                                                  label.frame.size.width,
                                                  label.frame.size.height);
                     }
                     completion:^(BOOL finished) {
                         label.hidden = YES;
                     }];
}

- (void)getItemsForType:(NSString *)type {
    self.itemTextField.textColor = [ThemeManager sharedInstance].normalFontColor;

    self.quantityTextField.text = nil;
    self.commentTextView.text   = nil;
    self.itemTextField.text     = nil;

    // We'll cache the items for each type selected in a dictionary, for the life of this VC.
    if ([self.itemsDictionary containsKey:type]) {
        [self enableControls];
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
                                                     [weakSelf.activityIndicator stop];
                                                     DDLogError(@"ERROR: %s Problem getting items.", __PRETTY_FUNCTION__);

                                                     // Only re-enable the type text field so the user can perform a 'retry' by
                                                     // selecting a type of product.
                                                     self.typeTextField.inputView.userInteractionEnabled = YES;

                                                     weakSelf.items = nil;

                                                     [self populateItemFieldsForFailure];

                                                     UIPickerView *picker = (UIPickerView *) weakSelf.itemTextField.inputView;
                                                     [picker reloadComponent:0];
                                                 });
                                             }];
    }
}

- (void)populateItemFieldsForFailure {
    self.itemTextField.textColor = [ThemeManager sharedInstance].errorFontColor;
    self.itemTextField.text      = kGetItemsErrorMessage;

    UIColor  *priceFontColor = [ThemeManager sharedInstance].errorFontColor;
    NSString *priceString    = [NSString stringWithFormat:kPriceLabelFormatString, @"n/a"];
    unsigned long length = [kPriceLabelFormatString length] - 2;
    NSRange range = NSMakeRange(length, [priceString length] - length);

    NSMutableAttributedString *attribPriceString = [[NSMutableAttributedString alloc] initWithString:priceString];
    [attribPriceString addAttribute:NSForegroundColorAttributeName value:priceFontColor range:range];

    self.priceLabel.attributedText = attribPriceString;

    UIColor *inStockFontColor = [ThemeManager sharedInstance].errorFontColor;
    NSString *string = [NSString stringWithFormat:kInStockLabelFormatString, @"n/a"];
    length = [kInStockLabelFormatString length] - 2;
    range = NSMakeRange(length, [string length] - length);

    NSMutableAttributedString *stockString = [[NSMutableAttributedString alloc] initWithString:string];
    [stockString addAttribute:NSForegroundColorAttributeName value:inStockFontColor range:range];

    self.stockLabel.attributedText = stockString;
}

- (void)resetNotificationState {
    if (self.notificationLabel.hidden == NO) {
        [self slideLabelToRightAndHide:self.notificationLabel];
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
    UIColor *inStockFontColor = [ThemeManager sharedInstance].successFontColor;
    if (item.outOfStock == YES) {
        inStock = @"no";
        inStockFontColor = [ThemeManager sharedInstance].errorFontColor;
    }

    NSString *string = [NSString stringWithFormat:kInStockLabelFormatString, inStock];
    unsigned long length = [kInStockLabelFormatString length] - 2;
    NSRange range = NSMakeRange(length, [string length] - length);

    NSMutableAttributedString *stockString = [[NSMutableAttributedString alloc] initWithString:string];
    [stockString addAttribute:NSForegroundColorAttributeName value:inStockFontColor range:range];

    self.stockLabel.attributedText = stockString;
}

- (void)configureNotificationLabel {
    CGFloat commentBottomY = self.commentTextView.frame.origin.y + self.commentTextView.frame.size.height;

    CGFloat notificationMidY = self.notificationLabel.frame.size.height / 2.0f;
    CGFloat midY = commentBottomY + (((self.scrollView.frame.size.height - commentBottomY) / 2.0f) - notificationMidY) + 4.0f;

    CGRect frame = CGRectMake(self.notificationLabel.frame.origin.x, midY, self.notificationLabel.frame.size.width, self.notificationLabel.frame.size.height);
    self.notificationLabel.frame = frame;
}

- (void)configureNotificationLabelForSuccess:(NSString *)message {
    self.notificationLabel.font      = [ThemeManager sharedInstance].successFont;
    self.notificationLabel.textColor = [ThemeManager sharedInstance].successFontColor;
    self.notificationLabel.hidden    = YES;

    self.notificationLabel.text = [message lowercaseString];
    [self.notificationLabel sizeToFit];
}

- (void)configureNotificationLabelForError:(NSString *)message {
    self.notificationLabel.font      = [ThemeManager sharedInstance].errorFont;
    self.notificationLabel.textColor = [ThemeManager sharedInstance].errorFontColor;
    self.notificationLabel.hidden    = YES;

    self.notificationLabel.text = [message lowercaseString];
    [self.notificationLabel sizeToFit];
}

- (void)configureTypesPicker {
    
    UIPickerView *typesPicker = [[UIPickerView alloc] init];
    typesPicker.delegate                = self;
    typesPicker.dataSource              = self;
    typesPicker.showsSelectionIndicator = YES;

    self.typeTextField.inputView = typesPicker;
}

- (void)configureItemsPicker {
    
    UIPickerView *itemsPicker = [[UIPickerView alloc] init];
    itemsPicker.delegate                = self;
    itemsPicker.dataSource              = self;
    itemsPicker.showsSelectionIndicator = YES;
    itemsPicker.tag                     = kItemsPickerViewTag;

    self.itemTextField.inputView = itemsPicker;
}

- (void)configureCommentTextView {
    self.commentTextView.font            = [ThemeManager sharedInstance].normalFont;
    self.commentTextView.textColor       = [ThemeManager sharedInstance].normalFontColor;
    self.commentTextView.backgroundColor = [ThemeManager sharedInstance].tintColor;

    self.commentTextView.textContainerInset = UIEdgeInsetsMake(5, 5, 5, 5);

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
