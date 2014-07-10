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

@property(nonatomic, weak) IBOutlet UIActivityIndicatorView *spinner;

@property(nonatomic, copy) NSArray *farms;
@property(nonatomic, copy) NSArray *fields;
@property(nonatomic, copy) NSArray *labels;

@property(nonatomic, assign) BOOL rememberMe;

@property(nonatomic, strong, readonly) id <UserServicesProtocol> userServices;

@property(nonatomic, strong) UIDynamicAnimator *dynamicAnimator;

@property(nonatomic, strong) SlideFromRightAnimationController *slideFromRightAnimationController;
@property(nonatomic, strong) SlideToRightAnimationController   *slideToRightAnimationController;

@end

@implementation LoginViewController

#pragma mark - Lifecycle

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UIViewController *toVC = segue.destinationViewController;
    toVC.transitioningDelegate = self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor clearColor];

    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"logout"
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:nil
                                                                            action:nil];

    self.rememberMeSwitch.onTintColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.10f];

    [self.loginButton setTitleColor:[ThemeManager sharedInstance].fontColor forState:UIControlStateNormal];
    [self.loginButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];

    [self configureLabels];
    [self configureFields];
    [self fillUserData];
    [self configureFarmPicker];

    self.dynamicAnimator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];

    self.navigationController.delegate = self;

    [self configureTransparentNavigationBar];
}

- (void)configureTransparentNavigationBar {
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
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
    [self.spinner stopAnimating];
}

- (void)viewDidDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    [super viewDidDisappear:animated];
}


#pragma mark - Gesture Handling

- (IBAction)handleTapGesture:(UITapGestureRecognizer *)recognizer {
    [self.view endEditing:YES];
}

#pragma mark - UIButton Actions

- (IBAction)loginButtonTap:(UIButton *)sender {
    [self.dynamicAnimator removeAllBehaviors];

    User *user = [[User alloc] initWithFirstname:self.firstNameField.text
                                        lastname:self.lastNameField.text
                                           group:nil
                                            farm:self.farmField.text];
    [self disableControls];

    [self.spinner startAnimating];

    __typeof(self) __weak weakSelf = self;
    [self.userServices authenticateUser:user
                           withPassword:self.passwordField.text
                  withCompletionHandler:^(BOOL authenticated, NSString *message)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self enableControls];
                    [weakSelf.spinner stopAnimating];
                });

                if (authenticated) {
                    if (weakSelf.rememberMe) {
                        [weakSelf.userServices storeUser:user withPassword:weakSelf.passwordField.text];
                    }

                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf resetView];
                        [weakSelf performSegueWithIdentifier:@"OrderSegue" sender:nil];
                    });
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf handleInvalidLogin:message];
                    });
                }
            }];
}

- (void)enableControls {
    [self enableFields];
    self.rememberMeSwitch.enabled = YES;
    self.loginButton.enabled = YES;
}

- (void)disableControls {
    [self disableFields];
    self.rememberMeSwitch.enabled = NO;

    self.loginButton.enabled = NO;
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self enableOrDisableLoginButton];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    [self resetView];
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

- (NSAttributedString *)pickerView:(UIPickerView *)pickerView
             attributedTitleForRow:(NSInteger)row
                      forComponent:(NSInteger)component {
    UIColor *foregroundColor = [UIColor whiteColor];

    NSAttributedString *string = [[NSAttributedString alloc] initWithString:[self.farms objectAtIndex:row]
                                                                 attributes:@{NSForegroundColorAttributeName : foregroundColor,
                                                                              NSFontAttributeName            : [[ThemeManager sharedInstance] fontWithSize:18.0f]}];
    return string;
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
    UIColor *textColor = [ThemeManager sharedInstance].fontColor;
    for (UITextField *field in self.fields) {
        field.textColor = textColor;
    }
}

- (void)setFieldsErrorColor {
    UIColor *textColor = [ThemeManager sharedInstance].fontErrorColor;
    for (UITextField *field in self.fields) {
        field.textColor = textColor;
    }
}

- (void)configureFarmPicker {
    UIPickerView *farmPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0.0f,
                                                                              0.0f,
                                                                              self.view.frame.size.width,
                                                                              178.0f)];
    farmPicker.delegate                = self;
    farmPicker.dataSource              = self;
    farmPicker.showsSelectionIndicator = YES;

    farmPicker.backgroundColor = [ThemeManager sharedInstance].tintColor;

    self.farmField.inputView = farmPicker;

    UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, 44.0f)];
    toolBar.barStyle     = UIBarStyleBlack;
    toolBar.translucent  = NO;
    toolBar.barTintColor = [ThemeManager sharedInstance].tintColor;

    // Making my own because the system ones are not centering vertically????
    UIButton *button = [[UIButton alloc] init];
    button.tintColor       = [UIColor whiteColor];
    button.titleLabel.font = [[ThemeManager sharedInstance] fontWithSize:19.0f];
    [button setTitle:@"Done" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(pickerDoneAction) forControlEvents:UIControlEventTouchUpInside];
    [button sizeToFit];

    UILabel *title = [[UILabel alloc] init];
    title.text = @"Select a Farm";            // Need the spaces for the title to center horizontally?
    title.font = [[ThemeManager sharedInstance] fontWithSize:19.0f];
    [title sizeToFit];
    title.textColor = [UIColor whiteColor];

    UIBarButtonItem *flexible     = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                  target:nil
                                                                                  action:nil];
    UIBarButtonItem *toolBarTitle = [[UIBarButtonItem alloc] initWithCustomView:title];
    UIBarButtonItem *doneButton   = [[UIBarButtonItem alloc] initWithCustomView:button];

    // the middle button is to make the Done button align to right
    [toolBar setItems:[NSArray arrayWithObjects:flexible,
                                                toolBarTitle,
                                                flexible,
                                                doneButton,
                                                nil]];
    self.farmField.inputAccessoryView = toolBar;
}

- (void)pickerDoneAction {
    [self.farmField resignFirstResponder];
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
        [self.userServices retrieveUserAndPasswordFromStoreWithCompletionHandler:^(User *user, NSString *password)
                {
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
        field.textColor = [ThemeManager sharedInstance].fontColor;
    }
}

- (void)configureLabels {
    self.labels = @[self.firstNameLabel, self.lastNameLabel, self.passwordLabel, self.farmLabel, self.rememberMeLabel];
    for (UILabel *label in self.labels) {
        label.textColor = [ThemeManager sharedInstance].fontColor;
    }
}

- (void)handleInvalidLogin:(NSString *)message {
    [self configureNotificationLabel:message];
    [self configureNotificationLabelAnimation];

    // Only color the fields red if the issue is a login failure.
    if ([self.notificationLabel.text isEqualToString:@"failed to login"]) {
        [self setFieldsErrorColor];
    }
}

- (void)configureNotificationLabelAnimation {
    UIPushBehavior      *pushBehavior;
    UICollisionBehavior *collisionBehavior;

    collisionBehavior = [[UICollisionBehavior alloc] initWithItems:@[self.notificationLabel]];

    float x = self.view.frame.size.width / 2 + self.notificationLabel.frame.size.width / 2;

    [collisionBehavior addBoundaryWithIdentifier:@"barrier"
                                       fromPoint:CGPointMake(x, 0)
                                         toPoint:CGPointMake(x, self.view.frame.size.height)];

    [self.dynamicAnimator addBehavior:collisionBehavior];

    pushBehavior = [[UIPushBehavior alloc] initWithItems:@[self.notificationLabel] mode:UIPushBehaviorModeContinuous];
    pushBehavior.angle     = 0;
    pushBehavior.magnitude = 5;

    [self.dynamicAnimator addBehavior:pushBehavior];
}

- (void)configureNotificationLabel:(NSString *)message {
    self.notificationLabel.frame = CGRectMake(-self.notificationLabel.frame.size.width,
                                              self.notificationLabel.frame.origin.y,
                                              self.notificationLabel.frame.size.width,
                                              self.notificationLabel.frame.size.height);
    self.notificationLabel.text  = [message lowercaseString];
    [self.notificationLabel sizeToFit];
    self.notificationLabel.hidden = NO;
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

- (void)resetView {
    [self.dynamicAnimator removeAllBehaviors];

    // Save the current frame
    CGRect frame = self.notificationLabel.frame;
    [UIView animateWithDuration:0.5
                     animations:^            {
        self.notificationLabel.frame = CGRectMake(-self.notificationLabel.frame.size.width,
                                                  self.notificationLabel.frame.origin.y,
                                                  self.notificationLabel.frame.size.width,
                                                  self.notificationLabel.frame.size.height);
    }
                     completion:^(BOOL finished)            {
        self.notificationLabel.hidden = YES;
        self.notificationLabel.frame  = frame;
    }];

    [self setFieldsDefaultColor];
}

@end