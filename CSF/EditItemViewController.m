//
//  EditItemViewController.m
//  CSF
//
//  Created by Seamus McGowan on 3/3/15.
//  Copyright (c) 2015 Seamus McGowan. All rights reserved.
//

#import <Shimmer/FBShimmeringView.h>
#import <CocoaLumberjack/DDLogMacros.h>
#import "EditItemViewController.h"
#import "ThemeManager.h"
#import "ActivityIndicator.h"
#import "Item.h"
#import "OrderItem.h"
#import "FBShimmeringView+Extended.h"
#import "UserServices.h"
#import "User.h"
#import "FarmDataService.h"
#import "InventoryItem.h"

static const int kKeyboardHeight = 216;
static const int kKeyboardHeightWithAccessory = 260;

static const int kCommentMaxLength   = 128;

static NSString *const kPriceLabelFormatString   = @"price %@";
static NSString *const kInStockLabelFormatString = @"in stock? %@";
static NSString *const kSuccessfullyAddedMessage = @"success";

@interface EditItemViewController () <UITextFieldDelegate, UITextViewDelegate>

@property(nonatomic, copy) NSArray *labels;
@property(nonatomic, copy) NSArray *fields;

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
@property(nonatomic, weak) IBOutlet UIButton   *editButton;
@property(nonatomic, weak) FBShimmeringView    *activityIndicator;

@property(nonatomic, strong, readonly) NSDateFormatter *dateFormatter;

@end

@implementation EditItemViewController {
    NSDateFormatter *_dateFormatter;
}

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor clearColor];
    [self configureLabels];
    [self configureFields];
    [self configureButton];
    [self configureCommentTextView];

    self.scrollView.scrollEnabled = NO;
    self.scrollView.bounds = self.scrollView.frame; // Not sure why this is not required in ItemViewController's ScrollView

    if (self.orderItem) {
        self.typeTextField.text     = self.orderItem.type;
        self.itemTextField.text     = self.orderItem.name;
        self.quantityTextField.text = [self.orderItem.quantity stringValue];
        self.commentTextView.text   = self.orderItem.comment;
        self.priceLabel.text        = [NSString stringWithFormat:kPriceLabelFormatString, self.orderItem.formattedPrice];

        if ([self.orderItem.quantity integerValue] > 0) {
            self.editButton.enabled = YES;
        }

        NSString *inStock          = @"yes";
        UIColor  *inStockFontColor = [ThemeManager sharedInstance].successFontColor;

        NSString      *string = [NSString stringWithFormat:kInStockLabelFormatString, inStock];
        unsigned long length  = [kInStockLabelFormatString length] - 2;
        NSRange       range   = NSMakeRange(length, [string length] - length);

        NSMutableAttributedString *stockString = [[NSMutableAttributedString alloc] initWithString:string];
        [stockString addAttribute:NSForegroundColorAttributeName value:inStockFontColor range:range];

        self.stockLabel.attributedText = stockString;

        [self getPriceForOrderItem:self.orderItem];
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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self registerForKeyboardNotifications];
}

- (void)viewDidDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    [super viewDidDisappear:animated];
}

#pragma mark - Notifications

- (void)registerForKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)keyboardWillBeHidden:(NSNotification*)notification {
    [self scrollViewDown];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

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
            [self enableOrDisableEditButtonBasedOnValue:value];

            return NO;
        } else {
            value = [newString doubleValue];
            [self enableOrDisableEditButtonBasedOnValue:value];

            return YES;
        }
    }

    return YES;
}

- (void)enableOrDisableEditButtonBasedOnValue:(double)value {
    if (value > 0) {
        self.editButton.enabled = YES;
    } else {
        self.editButton.enabled = NO;
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

- (void)disableControls {
    self.editButton.enabled        = NO;
    self.quantityTextField.enabled = NO;

    self.commentTextView.userInteractionEnabled = NO;
}

- (void)enableControls {
    double value = [self.quantityTextField.text doubleValue];
    if (value > 0) {
        self.editButton.enabled = YES;
    } else {
        self.editButton.enabled = NO;
    }

    self.quantityTextField.enabled = YES;

    self.commentTextView.userInteractionEnabled = YES;
}

- (void)getPriceForOrderItem:(OrderItem *)item {
    [self.activityIndicator start];
    [self disableControls];

    __typeof(self) __weak weakSelf = self;
    [[FarmDataService sharedInstance] getItemsForFarm:[UserServices sharedInstance].currentUser.farm
                                                 type:item.type
                                         successBlock:^(NSArray *items) {
                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                 [weakSelf enableControls];
                                                 [weakSelf.activityIndicator stop];

                                                 for (InventoryItem *inventoryItem in items) {
                                                     if ([inventoryItem.name isEqualToString:item.name]) {
                                                         weakSelf.priceLabel.text = [NSString stringWithFormat:kPriceLabelFormatString, inventoryItem.formattedPrice];
                                                         break;
                                                     }
                                                 }

                                                 UIPickerView *picker = (UIPickerView *) self.itemTextField.inputView;
                                                 [picker reloadComponent:0];
                                             });
                                         }
                                         failureBlock:^(NSString *message) {
                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                 [weakSelf.activityIndicator stop];
                                                 DDLogError(@"ERROR: %s Problem getting items.", __PRETTY_FUNCTION__);

                                                 [weakSelf enableControls];

                                                 UIColor  *priceFontColor = [ThemeManager sharedInstance].errorFontColor;
                                                 NSString *priceString    = [NSString stringWithFormat:kPriceLabelFormatString, @"n/a"];
                                                 unsigned long length = [kPriceLabelFormatString length] - 2;
                                                 NSRange range = NSMakeRange(length, [priceString length] - length);

                                                 NSMutableAttributedString *attribPriceString = [[NSMutableAttributedString alloc] initWithString:priceString];
                                                 [attribPriceString addAttribute:NSForegroundColorAttributeName value:priceFontColor range:range];

                                                 weakSelf.priceLabel.attributedText = attribPriceString;
                                             });
                                         }];
}

- (void)configureLabels {
    self.labels = @[self.typeLabel, self.itemLabel, self.priceLabel, self.stockLabel, self.quantityLabel, self.commentLabel];
    for (UILabel *label in self.labels) {
        label.font = [ThemeManager sharedInstance].normalFont;
        label.textColor = [ThemeManager sharedInstance].normalFontColor;
    }
}

- (void)configureFields {
    self.typeTextField.userInteractionEnabled = NO;
    self.itemTextField.userInteractionEnabled = NO;

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

- (void)configureButton {
    self.editButton.titleLabel.font = [ThemeManager sharedInstance].normalFont;

    [self.editButton setTitleColor:[ThemeManager sharedInstance].normalFontColor forState:UIControlStateNormal];
    [self.editButton setTitleColor:[ThemeManager sharedInstance].disabledColor forState:UIControlStateDisabled];

    self.editButton.layer.cornerRadius = 5.0f;
    self.editButton.layer.borderWidth  = 1.0f;
    self.editButton.layer.borderColor  = [ThemeManager sharedInstance].tintColor.CGColor;

    self.editButton.backgroundColor = [ThemeManager sharedInstance].tintColor;
    self.editButton.enabled = NO;
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

- (void)resetNotificationState {
    if (self.notificationLabel.hidden == NO) {
        [self slideLabelToRightAndHide:self.notificationLabel];
    }
}

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
