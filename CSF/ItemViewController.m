//
//  ItemViewController.m
//  CSF
//
//  Created by Seamus McGowan on 8/15/14.
//  Copyright (c) 2014 Seamus McGowan. All rights reserved.
//

#import "ItemViewController.h"
#import "ThemeManager.h"
#import "UITextField+Extended.h"

@interface ItemViewController ()

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
}

#pragma mark - Private Methods

- (void)configureCommentTextView {
    self.commentTextView.font      = [ThemeManager sharedInstance].normalFont;
    self.commentTextView.textColor = [ThemeManager sharedInstance].normalFontColor;

    self.commentTextView.backgroundColor = [ThemeManager sharedInstance].tintColor;

    [self.commentTextView  setTextContainerInset:UIEdgeInsetsMake(5, 10, 10, 10)];

    self.commentTextView.layer.cornerRadius = 5.0f;
    self.commentTextView.layer.borderWidth  = 1.0f;
    self.commentTextView.layer.borderColor  = [ThemeManager sharedInstance].tintColor.CGColor;

    //if (![field isEqual:self.farmField]) {
    self.commentTextView.keyboardAppearance = UIKeyboardAppearanceAlert;
    //}
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
    // Set up 'Next' field order
    self.typeTextField.nextTextField = self.itemTextField;
    self.itemTextField.nextTextField  = self.quantityTextField;
    self.quantityTextField.nextTextField  = self.commentTextView;

    self.fields = @[self.typeTextField, self.itemTextField, self.quantityTextField];

    //self.commentTextView

    for (UITextField *field in self.fields) {
        field.font      = [ThemeManager sharedInstance].normalFont;
        field.textColor = [ThemeManager sharedInstance].normalFontColor;

        field.borderStyle     = UITextBorderStyleRoundedRect;
        field.backgroundColor = [ThemeManager sharedInstance].tintColor;

        field.layer.cornerRadius = 5.0f;
        field.layer.borderWidth  = 1.0f;
        field.layer.borderColor  = [ThemeManager sharedInstance].tintColor.CGColor;

        //if (![field isEqual:self.farmField]) {
            field.keyboardAppearance = UIKeyboardAppearanceAlert;
        //}

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
