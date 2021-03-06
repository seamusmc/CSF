//
//  LoginViewController.m
//  CSF
//
//  Created by Seamus McGowan on 3/14/14.
//  Copyright (c) 2014 Seamus McGowan. All rights reserved.
//

#import "LoginViewController.h"
#import "ServiceLocator.h"
#import "UserServices.h"
#import "User.h"
#import "UITextField+Extended.h"
#import "FarmDataServiceProtocol.h"
#import "ThemeManager.h"
#import "SlideFromRightAnimationController.h"
#import "SlideToRightAnimationController.h"
#import "FBShimmeringView.h"
#import "FBShimmeringView+Extended.h"
#import "ActivityIndicator.h"

static const int PasswordMaxLength  = 20;
static const int FirstnameMaxLength = 15;
static const int LastnameMaxLength  = 15;

@interface LoginViewController () <UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, UINavigationControllerDelegate>

@property(nonatomic, weak) IBOutlet UITextField *firstNameField;
@property(nonatomic, weak) IBOutlet UITextField *lastNameField;
@property(nonatomic, weak) IBOutlet UITextField *passwordField;
@property(nonatomic, weak) IBOutlet UITextField *farmField;

@property(nonatomic, weak) IBOutlet UIButton *loginButton;
@property(nonatomic, weak) IBOutlet UISwitch *rememberMeSwitch;

@property(nonatomic, weak) IBOutlet UILabel *notificationLabel;
@property(nonatomic, weak) IBOutlet UILabel *firstNameLabel;
@property(nonatomic, weak) IBOutlet UILabel *lastNameLabel;
@property(nonatomic, weak) IBOutlet UILabel *passwordLabel;
@property(nonatomic, weak) IBOutlet UILabel *farmLabel;
@property(nonatomic, weak) IBOutlet UILabel *rememberMeLabel;

@property(nonatomic, weak) FBShimmeringView *activityIndicator;

@property(nonatomic, copy) NSArray *farms;
@property(nonatomic, copy) NSArray *fields;
@property(nonatomic, copy) NSArray *labels;

@property(nonatomic, assign) BOOL rememberMe;

@property(nonatomic, strong, readonly) id <UserServicesProtocol> userServices;

@property(nonatomic, strong) SlideFromRightAnimationController *slideFromRightAnimationController;
@property(nonatomic, strong) SlideToRightAnimationController   *slideToRightAnimationController;

@end

@implementation LoginViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor clearColor];

    self.rememberMeSwitch.onTintColor = [ThemeManager sharedInstance].tintColor;

    [self configureLoginButton];
    [self configureLabels];
    [self configureFields];
    [self fillUserData];
    [self configureFarmPicker];
    [self configureNotificationLabel];

    self.navigationController.delegate = self;

    [self configureTransparentNavigationBar];
}

- (id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                   animationControllerForOperation:(UINavigationControllerOperation)operation
                                                fromViewController:(UIViewController *)fromVC
                                                  toViewController:(UIViewController *)toVC {
    if (operation == UINavigationControllerOperationPush) {
        if (!self.slideFromRightAnimationController) {
            self.slideFromRightAnimationController = [SlideFromRightAnimationController new];
        }
        return self.slideFromRightAnimationController;
    } else {
        if (!self.slideToRightAnimationController) {
            self.slideToRightAnimationController = [SlideToRightAnimationController new];
        }
        return self.slideToRightAnimationController;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    // Setup this keyboard notification so that we know when the farms UIPickerView/inputView
    // is shown. We'll pre-select the appropriate farm as show in the farmsTextField. IOW, we want
    // to keep the farmsTextField in sync with the picker inputView.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(inputViewWillShowNotification:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [self.activityIndicator stop];
}

- (void)viewDidDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    [super viewDidDisappear:animated];
}

#pragma mark - Gesture Handling

- (IBAction)handleTapGesture:(UITapGestureRecognizer *)recognizer {
    [self.view endEditing:YES];
    [self resetNotificationState];
}

#pragma mark - UIButton Actions

- (IBAction)loginButtonTap:(UIButton *)sender {
    User *user = [[User alloc] initWithFirstname:self.firstNameField.text
                                        lastname:self.lastNameField.text
                                           group:nil
                                            farm:self.farmField.text];
    [self disableControls];
    [self resetNotificationState];
    [self.activityIndicator start];

    __typeof(self) __weak weakSelf = self;
    [self.userServices authenticateUser:user
                           withPassword:self.passwordField.text
                  withCompletionHandler:^(BOOL authenticated, NSString *message) {
                      dispatch_async(dispatch_get_main_queue(), ^{
                          [weakSelf enableControls];
                          [weakSelf.activityIndicator stop];

                          if (authenticated) {
                              if (weakSelf.rememberMe) {
                                  [weakSelf.userServices storeUser:user withPassword:weakSelf.passwordField.text];
                              }

                              if (weakSelf.notificationLabel.hidden == NO) {
                                  // Delay so that we don't see the notification label animating off the next page!
                                  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t) (0.25f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                      [weakSelf performSegueWithIdentifier:@"OrderSegue" sender:nil];
                                  });
                              } else {
                                  [weakSelf performSegueWithIdentifier:@"OrderSegue" sender:nil];
                              }
                          } else {
                              dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                                  [weakSelf handleInvalidLogin:message];
                              });
                          }
                      });

                  }];
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self enableOrDisableLoginButton];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    [self resetNotificationState];
    return YES;
}

// We implement this delegate method in order to enforce max lengths of text fields.
- (BOOL)            textField:(UITextField *)textField
shouldChangeCharactersInRange:(NSRange)range
            replacementString:(NSString *)string {
    BOOL returnValue = YES;

    NSString *newString = [textField.text stringByReplacingCharactersInRange:range
                                                                  withString:string];
    if (textField == self.passwordField) {
        returnValue = newString.length <= PasswordMaxLength;
    }
    else if (textField == self.firstNameField) {
        returnValue = newString.length <= FirstnameMaxLength;
    }
    else if (textField == self.lastNameField) {
        returnValue = newString.length <= LastnameMaxLength;
    }

    return returnValue;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    UITextField *next = textField.nextTextField;
    if (next) {
        [next becomeFirstResponder];
    }
    else {
        [textField resignFirstResponder];
    }

    return NO;
}

#pragma mark - UIPickerViewDelegate

- (UIView *)pickerView:(UIPickerView *)pickerView
            viewForRow:(NSInteger)row
          forComponent:(NSInteger)component
           reusingView:(UIView *)view {
    
    // Customization needs to occur here, TODO: determine why? TODO: move code to method/extension
    pickerView.backgroundColor = [UIColor clearColor];
    
    UIView *temp = pickerView.subviews[1];
    temp.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.5f];
    temp = pickerView.subviews[2];
    temp.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.5f];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, pickerView.frame.size.width, 44)];
    label.textColor     = [ThemeManager sharedInstance].normalFontColor;
    label.font          = [ThemeManager sharedInstance].normalFont;
    label.text          = self.farms[row];
    label.textAlignment = NSTextAlignmentCenter;

    return label;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.farmField.text = (NSString *) [self.farms objectAtIndex:row];
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [self.farms count];
}

#pragma mark - UISwitch Actions

- (IBAction)switchValueChanged:(UISwitch *)sender {
    self.rememberMe = sender.on;

    if (!sender.on) {
        [self.userServices storeUser:nil withPassword:nil];
    }
}

#pragma mark - Property Overrides

- (FBShimmeringView *)activityIndicator {
    if (_activityIndicator == nil) {
        _activityIndicator = [[ActivityIndicator sharedInstance] createActivityIndicator:self.view];
    }
    return _activityIndicator;
}

- (NSArray *)farms {
    return [ServiceLocator sharedInstance].farmDataService.farms;
}

- (id <UserServicesProtocol>)userServices {
    return [ServiceLocator sharedInstance].userServices;
}

- (BOOL)rememberMe {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"rememberMe"];
}

- (void)setRememberMe:(BOOL)rememberMe {
    [[NSUserDefaults standardUserDefaults] setBool:rememberMe forKey:@"rememberMe"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - Notifications

- (void)inputViewWillShowNotification:(NSNotification *)notification {
    // Only handle this notification if the farmsTextField inputView, a UIPickerView,
    // is being shown. We want to keep the picker and textField in sync.
    for (UIView *view in self.view.subviews) {
        if ([view.inputView isMemberOfClass:[UIPickerView class]]) {
            if ([view isFirstResponder]) {
                UIPickerView *pickerView = (UIPickerView *) view.inputView;

                NSInteger index = [self.farms indexOfObject:self.farmField.text];

                [pickerView selectRow:index inComponent:0 animated:NO];
            }

            break;
        }
    }
}

#pragma mark - Private Methods

- (void)setFieldsDefaultColor {
    for (UITextField *field in self.fields) {
        field.font      = [ThemeManager sharedInstance].normalFont;
        field.textColor = [ThemeManager sharedInstance].normalFontColor;
    }
}

- (void)setFieldsErrorColor {
    for (UITextField *field in self.fields) {
        field.font      = [ThemeManager sharedInstance].errorFont;
        field.textColor = [ThemeManager sharedInstance].errorFontColor;
    }
}

- (void)configureFarmPicker {
    CGRect     rect        = CGRectMake(0.0f, 0.0f, self.view.frame.size.width, 216.0f);
    UIPickerView *farmPicker = [[UIPickerView alloc] initWithFrame:rect];

    farmPicker.delegate                = self;
    farmPicker.dataSource              = self;
    farmPicker.showsSelectionIndicator = YES;

    self.farmField.inputView = farmPicker;
}

- (void)enableOrDisableLoginButton {
    self.loginButton.enabled = [self doAllFieldsHaveContent];
}

- (BOOL)doAllFieldsHaveContent {
    for (UITextField *field in self.fields) {
        NSString *text = [field.text stringByReplacingOccurrencesOfString:@" " withString:@""];
        if ([text length] == 0) {
            return NO;
        }
    }

    return YES;
}

- (void)fillUserData {
    if (self.rememberMe) {
        __typeof(self) __weak weakSelf = self;
        [self.userServices retrieveUserAndPasswordFromStoreWithCompletionHandler:^(User *user, NSString *password) {
            weakSelf.firstNameField.text = user.firstname;
            weakSelf.lastNameField.text  = user.lastname;
            weakSelf.passwordField.text  = password;
            weakSelf.farmField.text      = user.farm ? user.farm : @"yoder";
        }];

        self.rememberMeSwitch.on = self.rememberMe;
        [self enableOrDisableLoginButton];
    }
}

- (void)configureFields {
    // Set up 'Next' field order
    self.firstNameField.nextTextField = self.lastNameField;
    self.lastNameField.nextTextField  = self.passwordField;
    self.passwordField.nextTextField  = self.farmField;
    self.farmField.nextTextField      = nil;

    self.fields = @[self.firstNameField, self.lastNameField, self.passwordField, self.farmField];

    for (UITextField *field in self.fields) {
        field.font      = [ThemeManager sharedInstance].normalFont;
        field.textColor = [ThemeManager sharedInstance].normalFontColor;

        field.borderStyle     = UITextBorderStyleRoundedRect;
        field.backgroundColor = [ThemeManager sharedInstance].tintColor;

        field.layer.cornerRadius = 5.0f;
        field.layer.borderWidth  = 1.0f;
        field.layer.borderColor  = [ThemeManager sharedInstance].tintColor.CGColor;

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

- (void)configureLabels {
    self.labels = @[self.firstNameLabel, self.lastNameLabel, self.passwordLabel, self.farmLabel, self.rememberMeLabel];
    for (UILabel *label in self.labels) {
        label.font      = [ThemeManager sharedInstance].normalFont;
        label.textColor = [ThemeManager sharedInstance].normalFontColor;
    }
}

- (void)handleInvalidLogin:(NSString *)message {
    [self setNotificationLabelText:message];
    [self showNotification];

    // Only color the fields if the issue is a login failure, not a networking error.
    if ([self.notificationLabel.text isEqualToString:@"failed to login"]) {
        [self setFieldsErrorColor];
    }
}

- (void)showNotification {
    // Make sure initial position is correct:
    self.notificationLabel.hidden = YES;
    self.notificationLabel.frame  = CGRectMake(-self.notificationLabel.frame.size.width,
                                               self.notificationLabel.frame.origin.y,
                                               self.notificationLabel.frame.size.width,
                                               self.notificationLabel.frame.size.height);

    self.notificationLabel.hidden = NO;
    [UIView animateWithDuration:[ThemeManager sharedInstance].notificationDuration
                          delay:[ThemeManager sharedInstance].notificationDelay
         usingSpringWithDamping:[ThemeManager sharedInstance].notificationDamping
          initialSpringVelocity:[ThemeManager sharedInstance].notificationInitialVelocity
                        options:UIViewAnimationOptionTransitionNone
                     animations:^{
                         CGFloat x    = (self.notificationLabel.superview.frame.size.width / 2) - (self.notificationLabel.frame.size.width / 2);
                         CGFloat y    = self.notificationLabel.frame.origin.y;
                         CGRect  rect = CGRectMake(x, y, self.notificationLabel.frame.size.width, self.notificationLabel.frame.size.height);

                         self.notificationLabel.frame = rect;
                     }
                     completion:nil];
}

- (void)setNotificationLabelText:(NSString *)message {
    self.notificationLabel.text = [message lowercaseString];
    [self.notificationLabel sizeToFit];
}

- (void)configureNotificationLabel {
    self.notificationLabel.font      = [ThemeManager sharedInstance].errorFont;
    self.notificationLabel.textColor = [ThemeManager sharedInstance].errorFontColor;
}

- (void)enableControls {
    [self enableFields];
    self.rememberMeSwitch.enabled = YES;
    self.loginButton.enabled      = YES;
}

- (void)disableControls {
    [self disableFields];
    self.rememberMeSwitch.enabled = NO;

    self.loginButton.enabled = NO;
}

- (void)enableFields {
    for (UITextField *field in self.fields) {
        field.enabled = YES;
        field.alpha   = 1.0f;
    }
}

- (void)disableFields {
    for (UITextField *field in self.fields) {
        field.enabled = NO;
        field.alpha   = 0.5f;
    }
}

- (void)resetNotificationState {
    // If we're showing the notificationLabel then we know we
    // were dealing with an issue.
    if (self.notificationLabel.hidden == NO) {
        [self slideNotificationLabelToRightAndHide];

        [self setFieldsDefaultColor];
    }
}

- (void)slideNotificationLabelToRightAndHide {
    [UIView animateWithDuration:0.5
                     animations:^{
                         self.notificationLabel.frame = CGRectMake(self.view.frame.size.width + self.notificationLabel.frame.size.width,
                                                                   self.notificationLabel.frame.origin.y,
                                                                   self.notificationLabel.frame.size.width,
                                                                   self.notificationLabel.frame.size.height);
                     }
                     completion:^(BOOL finished) {
                         self.notificationLabel.hidden = YES;
                     }];
}

- (void)configureLoginButton {
    self.loginButton.titleLabel.font = [ThemeManager sharedInstance].normalFont;

    [self.loginButton setTitleColor:[ThemeManager sharedInstance].normalFontColor forState:UIControlStateNormal];
    [self.loginButton setTitleColor:[ThemeManager sharedInstance].disabledColor forState:UIControlStateDisabled];

    self.loginButton.layer.cornerRadius = 5.0f;
    self.loginButton.layer.borderWidth  = 1.0f;
    self.loginButton.layer.borderColor  = [ThemeManager sharedInstance].tintColor.CGColor;

    self.loginButton.backgroundColor = [ThemeManager sharedInstance].tintColor;
}

- (void)configureTransparentNavigationBar {
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
}

@end
