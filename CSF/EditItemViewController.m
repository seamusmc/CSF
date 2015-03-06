//
//  EditItemViewController.m
//  CSF
//
//  Created by Seamus McGowan on 3/3/15.
//  Copyright (c) 2015 Seamus McGowan. All rights reserved.
//

#import <Shimmer/FBShimmeringView.h>
#import "EditItemViewController.h"
#import "ThemeManager.h"

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

@end

@implementation EditItemViewController

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
}

- (void)viewDidLayoutSubviews {
    self.scrollView.contentSize = CGSizeMake(320, self.view.frame.size.height * 2);  // Basically two pages tall.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Gesture Handling

- (IBAction)handleTapGesture:(UITapGestureRecognizer *)sender {
    [self.view endEditing:YES];
    [self resetNotificationState];
}

#pragma mark - Private Methods

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

- (void)resetNotificationState {
    if (self.notificationLabel.hidden == NO) {
        [self slideLabelToRightAndHide:self.notificationLabel];
    }
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

@end
