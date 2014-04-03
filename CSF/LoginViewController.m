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

static const int PasswordMaxLength  = 20;
static const int FirstnameMaxLength = 15;
static const int LastnameMaxLength  = 15;

@interface LoginViewController () <UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *firstNameField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UITextField *farmField;

@property (weak, nonatomic) IBOutlet UILabel  *notificationLabel;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UISwitch *rememberMeSwitch;

@property (strong, nonatomic, readonly) NSArray *farms;

@property (assign, nonatomic) BOOL rememberMe;

@property (strong, nonatomic, readonly) id <UserServicesProtocol> userServices;

@end

@implementation LoginViewController

- (void)enableOrDisableLoginButton
{
    if ([self.firstNameField.text stringByReplacingOccurrencesOfString:@" " withString:@""].length > 0)
    {
        if ([self.lastNameField.text stringByReplacingOccurrencesOfString:@" " withString:@""].length > 0)
        {
            if ([self.passwordField.text stringByReplacingOccurrencesOfString:@" " withString:@""].length > 0)
            {
                if ([self.farmField.text stringByReplacingOccurrencesOfString:@" " withString:@""].length > 0)
                {
                    self.loginButton.enabled = YES;
                    return;
                }
            }
        }
    }

    self.loginButton.enabled = NO;
}

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"logout" style:UIBarButtonItemStylePlain target:nil action:nil];

    // Set up 'Next' field order
    self.firstNameField.nextTextField = self.lastNameField;
    self.lastNameField.nextTextField  = self.passwordField;
    self.passwordField.nextTextField  = self.farmField;
    self.farmField.nextTextField      = nil;

    if (self.rememberMe)
    {
        __typeof (self) __weak weakSelf = self;
        [self.userServices retrieveUserAndPasswordFromStoreWithCompletionHandler:^(User *user, NSString *password)
        {
            weakSelf.firstNameField.text = user.firstname;
            weakSelf.lastNameField.text  = user.lastname;
            weakSelf.passwordField.text  = password;
            weakSelf.farmField.text      = user.farm;
        }];

        self.rememberMeSwitch.on = self.rememberMe;
        [self enableOrDisableLoginButton];
    }

    // Create and set the input view for the farmTextField
    UIPickerView *farmPicker = [[UIPickerView alloc] initWithFrame:CGRectZero];
    farmPicker.delegate   = self;
    farmPicker.dataSource = self;
    [farmPicker setShowsSelectionIndicator:YES];

    //farmPicker.backgroundColor = [UIColor whiteColor];
    farmPicker.backgroundColor = [UIColor colorWithRed:0.09 green:0.34 blue:0.58 alpha:1];

    self.farmField.inputView = farmPicker;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    // Setup this keyboard notification so that we know when the farms UIPickerView/inputView
    // is shown. We'll pre-select the appropriate farm as show in the farmsTextField. IOW, we want
    // to keep the farmsTextField in sync with the picker inputView.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(inputViewWillShowNotification:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];

    // This message indicates a failed authentication.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleInvalidLogin:)
                                                 name:FailedAuthentication
                                               object:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    [super viewDidDisappear:animated];
}


#pragma mark - Gesture Handling

- (IBAction)handleTapGesture:(UITapGestureRecognizer *)recognizer
{
    [self enableOrDisableLoginButton];
    [self.view endEditing:YES];
}

#pragma mark - UIButton Actions

- (IBAction)loginButtonTap:(UIButton *)sender
{
    User *user = [[User alloc] initWithFirstname:self.firstNameField.text lastname:self.lastNameField.text group:@"SMITH" farm:self.farmField.text];

    __typeof (self) __weak weakSelf = self;
    [self.userServices authenticateUser:user withPassword:self.passwordField.text withCompletionHandler:^(BOOL authenticated)
    {
        if (authenticated)
        {
            if (weakSelf.rememberMe)
            {
                [weakSelf.userServices storeUser:user withPassword:weakSelf.passwordField.text];
            }

            dispatch_async(dispatch_get_main_queue(), ^
                                                      {
                                                          [weakSelf performSegueWithIdentifier:@"CreateOrderSegue" sender:nil];
                                                      });
        }
    }];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    // Save the current frame
    CGRect frame = self.notificationLabel.frame;
    [UIView animateWithDuration:1.0
                     animations:^
                     {
                         self.notificationLabel.frame = CGRectMake(-self.notificationLabel.frame.size.width,
                                                                   self.notificationLabel.frame.origin.y,
                                                                   self.notificationLabel.frame.size.width,
                                                                   self.notificationLabel.frame.size.height);

                     }
                     completion:^(BOOL finished)
                     {
                         self.notificationLabel.hidden = YES;
                         self.notificationLabel.frame  = frame;
                     }];


    // self.notificationLabel.hidden = YES;

    UIColor *textColor = [UIColor colorWithRed:0.09 green:0.34 blue:0.58 alpha:1];
    self.firstNameField.textColor = textColor;
    self.lastNameField.textColor  = textColor;
    self.passwordField.textColor  = textColor;
    self.farmField.textColor      = textColor;

    return YES;
}

// We implement this delegate method in order to enforce max lengths of text fields.
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    BOOL returnValue = YES;

    NSString *newString = [textField.text stringByReplacingCharactersInRange:range
                                                                  withString:string];
    if (textField == self.passwordField)
    {
        returnValue = newString.length <= PasswordMaxLength;
    }
    else if (textField == self.firstNameField)
    {
        returnValue = newString.length <= FirstnameMaxLength;
    }
    else if (textField == self.lastNameField)
    {
        returnValue = newString.length <= LastnameMaxLength;
    }

    return returnValue;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    UITextField *next = textField.nextTextField;
    if (next)
    {
        [next becomeFirstResponder];
    }
    else
    {
        [textField resignFirstResponder];
    }

    [self enableOrDisableLoginButton];
    return NO;
}

#pragma mark - UIPickerViewDelegate

- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    //UIColor *foregroundColor   = [UIColor colorWithRed:0.09 green:0.34 blue:0.58 alpha:1];
    UIColor *foregroundColor = [UIColor whiteColor];

    NSAttributedString *string = [[NSAttributedString alloc] initWithString:[self.farms objectAtIndex:row]
                                                                 attributes:@{NSForegroundColorAttributeName : foregroundColor}];
    return string;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    self.farmField.text = (NSString *) [self.farms objectAtIndex:row];
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [self.farms count];
}

#pragma mark - UISwitch Actions

- (IBAction)switchValueChanged:(UISwitch *)sender
{
    self.rememberMe = sender.on;

    if (!sender.on)
    {
        [self.userServices storeUser:nil withPassword:nil];
    }
}

#pragma mark - Property Overrides

- (NSArray *)farms
{
    return [ServiceLocator sharedInstance].farmDataService.farms;
}

- (id <UserServicesProtocol>)userServices
{
    return [ServiceLocator sharedInstance].userServices;
}

- (BOOL)rememberMe
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"rememberMe"];
}

- (void)setRememberMe:(BOOL)rememberMe
{
    [[NSUserDefaults standardUserDefaults] setBool:rememberMe forKey:@"rememberMe"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - Notifications

- (void)inputViewWillShowNotification:(NSNotification *)notification
{
    // Only handle this notification if the farmsTextField inputView, a UIPickerView,
    // is being shown. We want to keep the picker and textField in sync.
    for (UIView *view in self.view.subviews)
    {
        if ([view.inputView isMemberOfClass:[UIPickerView class]])
        {
            if ([view isFirstResponder])
            {
                UIPickerView *pickerView = (UIPickerView *) view.inputView;

                NSInteger index = [self.farms indexOfObject:self.farmField.text];

                [pickerView selectRow:index inComponent:0 animated:NO];
            }

            break;
        }
    }
}

- (void)handleInvalidLogin:(NSNotification *)notification
{
    // Save the current frame
    CGRect frame = self.notificationLabel.frame;
    self.notificationLabel.frame = CGRectMake(-self.notificationLabel.frame.size.width,
                                              self.notificationLabel.frame.origin.y,
                                              self.notificationLabel.frame.size.width,
                                              self.notificationLabel.frame.size.height);
    [UIView animateWithDuration:1.0
                     animations:^
                     {
                         self.notificationLabel.hidden = NO;
                         self.notificationLabel.frame  = frame;
                     }];

    self.firstNameField.textColor = [UIColor redColor];
    self.lastNameField.textColor  = [UIColor redColor];
    self.passwordField.textColor  = [UIColor redColor];
    self.farmField.textColor      = [UIColor redColor];
}

@end
