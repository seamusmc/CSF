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

@interface LoginViewController ()

@property (weak, nonatomic) IBOutlet UITextField *firstNameField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UITextField *farmField;

@end

@implementation LoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    NSDictionary *textAttributes = @{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue" size:19.0]};
    self.navigationController.navigationBar.titleTextAttributes = textAttributes;
}

- (IBAction)handleTapGesture:(UITapGestureRecognizer *)recognizer
{
    [self.view endEditing:YES];
}

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

@end
