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

@interface LoginViewController () <UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *firstNameField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UITextField *farmField;

@property (weak, nonatomic) IBOutlet UIButton   *loginButton;
@property (weak, nonatomic) IBOutlet UISwitch   *rememberMeSwitch;
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

    // Customize the nav bar title font
    NSDictionary *textAttributes = @{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue" size:20.0]};
    self.navigationController.navigationBar.titleTextAttributes = textAttributes;

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

@end
