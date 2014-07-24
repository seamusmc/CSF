//
//  OrderViewController.m
//  CSF
//
//  Created by Seamus McGowan on 4/2/14.
//  Copyright (c) 2014 Seamus McGowan. All rights reserved.
//

#import "OrderViewController.h"
#import "ThemeManager.h"

@interface OrderViewController () <UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource>

@property(nonatomic, weak) IBOutlet UILabel     *dateLabel;
@property(nonatomic, weak) IBOutlet UITextField *dateField;
@property(nonatomic, weak) IBOutlet UITableView *orderItemsTableView;
@property(nonatomic, weak) IBOutlet UILabel     *totalLabel;

@property (nonatomic, strong, readonly) NSDateFormatter* dateFormatter;

@property(nonatomic, copy) NSArray *labels;

@end

@implementation OrderViewController {
    NSDateFormatter *_dateFormatter;
}

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor clearColor];

    [self configureNavigationBarItems];
    [self configureFields];
    [self configureLabels];

    [self configureOrderItemsTableView];
}

#pragma mark - Property Overrides

- (NSDateFormatter *)dateFormatter {
    if (_dateFormatter == nil) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateStyle:NSDateFormatterShortStyle];
        [_dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    }

    return _dateFormatter;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    return nil;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

}


#pragma mark - Gesture Handling

- (IBAction)handleTapGesture:(UITapGestureRecognizer *)sender {
    [self.view endEditing:YES];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

#pragma mark - Private

- (void)configureNavigationBarItems {
    UIBarButtonItem *removeItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:nil];
    UIBarButtonItem *addItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:nil];

    NSArray *actionButtonItems = @[addItem, removeItem];
    self.navigationItem.rightBarButtonItems = actionButtonItems;
}

- (void)configureFields {
    self.dateField.delegate = self;

    self.dateField.font      = [ThemeManager sharedInstance].normalFont;
    self.dateField.textColor = [ThemeManager sharedInstance].normalFontColor;

    self.dateField.borderStyle     = UITextBorderStyleRoundedRect;
    self.dateField.backgroundColor = [ThemeManager sharedInstance].tintColor;

    self.dateField.layer.cornerRadius = 5.0f;
    self.dateField.layer.borderWidth  = 1.0f;
    self.dateField.layer.borderColor  = [ThemeManager sharedInstance].tintColor.CGColor;
    self.dateField.keyboardAppearance = UIKeyboardAppearanceAlert;

    UIColor  *color       = [ThemeManager sharedInstance].placeHolderFontColor;
    UIFont   *font        = [ThemeManager sharedInstance].placeHolderFont;
    NSString *placeholder = self.dateField.placeholder;
    if (placeholder) {
        self.dateField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:placeholder
                                                                           attributes:@{NSForegroundColorAttributeName : color,
                                                                                        NSFontAttributeName            : font}];
    }

    self.dateField.text = [self.dateFormatter stringFromDate:[NSDate date]];
    self.dateField.inputView = [self createDatePicker];
}

- (UIDatePicker *)createDatePicker {
    UIDatePicker *datePicker = [[UIDatePicker alloc] init];
    datePicker.datePickerMode = UIDatePickerModeDate;
    [datePicker addTarget:self action:nil forControlEvents:UIControlEventValueChanged];
    datePicker.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.80f];

    return datePicker;
}

- (void)configureLabels {
    self.labels = @[self.dateLabel, self.totalLabel];
    for (UILabel *label in self.labels) {
        label.font = [ThemeManager sharedInstance].normalFont;
        label.textColor = [ThemeManager sharedInstance].normalFontColor;
    }
}

- (void)configureOrderItemsTableView {
    self.orderItemsTableView.backgroundColor = [UIColor clearColor];

    self.orderItemsTableView.dataSource = self;
    self.orderItemsTableView.delegate = self;

//    [self.orderItemsTableView registerClass:<#(Class)cellClass#> forCellReuseIdentifier:<#(NSString *)identifier#>];
//    [self.tipTableView registerClass:[CLTipTableViewCell class] forCellReuseIdentifier:kTipCellIdentifier];
}

@end
