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

@interface LoginViewController ()  <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *firstNameField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UITextField *farmField;

@property (weak, nonatomic) IBOutlet UIButton *loginButton;

@end

@implementation LoginViewController

- (void) enableOrDisableLoginButton
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

    // Set up 'Next' field order
    self.firstNameField.nextTextField = self.lastNameField;
    self.lastNameField.nextTextField = self.passwordField;
    self.passwordField.nextTextField = self.farmField;
    self.farmField.nextTextField = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    NSDictionary *textAttributes = @{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue" size:19.0]};
    self.navigationController.navigationBar.titleTextAttributes = textAttributes;
}

#pragma mark - Gesture Handling

- (IBAction)handleTapGesture:(UITapGestureRecognizer *)recognizer
{
    [self enableOrDisableLoginButton];
    [self.view endEditing:YES];
}

#pragma mark - Event Handlers

- (IBAction)loginButtonTap:(UIButton *)sender
{
    User *user = [[User alloc] initWithFirstname:self.firstNameField.text lastname:self.lastNameField.text group:@"SMITH" farm:self.farmField.text];

    [[ServiceLocator sharedInstance].userServices authenticateUser:user
                                                      withPassword:@"1234"
                                             withCompletionHandler:^(BOOL authenticated)
                                             {
                                                 if (authenticated)
                                                 {
                                                     NSLog(@"Successfully logged in.");
                                                 }
                                                 else
                                                 {
                                                     NSLog(@"Did not successfully log in.");
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

@end
