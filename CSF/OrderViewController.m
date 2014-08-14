//
//  OrderViewController.m
//  CSF
//
//  Created by Seamus McGowan on 4/2/14.
//  Copyright (c) 2014 Seamus McGowan. All rights reserved.
//

#import "OrderViewController.h"
#import "ThemeManager.h"
#import "OrderItemTableViewCell.h"
#import "Order.h"
#import "OrderDataService.h"
#import "UserServices.h"
#import "OrderItem.h"
#import "FBShimmeringView.h"
#import "FBShimmeringView+Extended.h"
#import "DatePicker.h"
#import "ActivityIndicator.h"

@interface OrderViewController () <UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, SWTableViewCellDelegate>

@property(nonatomic, weak) IBOutlet UITextField *dateField;
@property(nonatomic, weak) IBOutlet UITableView *orderItemsTableView;
@property(nonatomic, weak) IBOutlet UILabel     *totalLabel;

@property (nonatomic, strong, readonly) NSDateFormatter* dateFormatter;

@property(nonatomic, weak) FBShimmeringView *activityIndicator;

@property(nonatomic, copy) NSArray    *labels;
@property(nonatomic, strong) Order    *order;
@property(nonatomic, strong) NSString *currentDate;

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

    self.currentDate = self.dateField.text;
    [self refreshOrderWithCurrentDate];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
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

#pragma mark - Keyboard notifications

- (void)keyboardWillHide:(NSNotification *)notification {
    if ([self.currentDate isEqualToString:self.dateField.text] == NO) {
        [self refreshOrderWithCurrentDate];
    }
}

- (void)keyboardWillShow:(NSNotification *)notification {
    self.currentDate = self.dateField.text;
}

#pragma mark - SWTableViewCellDelegate
const int kEditButtonIndex = 0;
const int kDeleteButtonIndex = 1;

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index {
    switch (index) {
        case kEditButtonIndex: {
            NSLog(@"Seque to the edit page.");
            break;
        }
        case kDeleteButtonIndex: {
            [self.activityIndicator start];

            __typeof(self) __weak weakSelf = self;
            NSIndexPath *cellIndexPath = [self.orderItemsTableView indexPathForCell:cell];
            NSDate      *date          = [self.dateFormatter dateFromString:self.currentDate];
            [[OrderDataService sharedInstance] removeItem:self.order.items[cellIndexPath.row]
                                                     user:[UserServices sharedInstance].currentUser
                                                     date:date
                                             successBlock:^{
                                                 // Not necessary to stop the activity indicator, call to refresh order will do it for us.
                                                 dispatch_async(dispatch_get_main_queue(), ^{
                                                     [weakSelf refreshOrderWithCurrentDate];
                                                 });
                                             }
                                             failureBlock:^(NSString *message) {
                                                 [weakSelf.activityIndicator stop];
                                                 // Boo, show message.
                                             }];
            break;
        }
    }
}

#pragma mark - UITableViewDataSource

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleNone;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.order.items count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    OrderItem *item = self.order.items[indexPath.row];

    OrderItemTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kOrderItemCellIdentifier forIndexPath:indexPath];

    // Add utility buttons
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];

    [rightUtilityButtons sw_addUtilityButtonWithColor:[ThemeManager sharedInstance].tintColor title:@"edit"];
    [rightUtilityButtons sw_addUtilityButtonWithColor:[ThemeManager sharedInstance].tintColor title:@"delete"];

    cell.rightUtilityButtons = rightUtilityButtons;
    cell.delegate = self;

    cell.name = item.name;
    cell.quantity = [NSString stringWithFormat:@"qty ~ %@", item.quantity];
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 52.0f;
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

#pragma mark - Date Picker Actions

- (void)dateChanged:(id)sender {
    if ([sender isKindOfClass:[UIDatePicker class]]) {
        UIDatePicker *datePicker = sender;
        self.dateField.text = [self.dateFormatter stringFromDate:datePicker.date];
    }
}

#pragma mark - Private

- (void)refreshOrderWithDate:(NSDate *)date {
    [self.activityIndicator start];

    self.order = nil;
    [self.orderItemsTableView reloadData];

    __typeof(self) __weak weakSelf = self;
    [[OrderDataService sharedInstance] getOrderForUser:[UserServices sharedInstance].currentUser
                                                  date:date
                                          successBlock:^(Order *tempOrder) {
                                              self.order = tempOrder;
                                              dispatch_async(dispatch_get_main_queue(), ^{
                                                  [weakSelf.activityIndicator stop];

                                                  weakSelf.totalLabel.text = [NSString stringWithFormat:@"total ~ %@", weakSelf.order.total];

                                                  NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
                                                  for (int index = 0; index < [weakSelf.order.items count]; ++index) {
                                                      indexPaths[index] = [NSIndexPath indexPathForRow:index inSection:0];
                                                  }

                                                  [weakSelf.orderItemsTableView insertRowsAtIndexPaths:indexPaths
                                                                                      withRowAnimation:UITableViewRowAnimationTop];
                                              });
                                          }
                                          failureBlock:^(NSString *message) {
                                              [weakSelf.activityIndicator stop];
                                              // Show an alert view.
                                          }];
}

- (void)configureNavigationBarItems {
    UIBarButtonItem *refreshOrder = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                                  target:self
                                                                                  action:@selector(refreshOrderWithCurrentDate)];

    UIBarButtonItem *addItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:nil];

    NSArray *actionButtonItems = @[addItem, refreshOrder];
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
    self.dateField.inputView = [self createDateFieldInputView];

    CGFloat height = self.view.frame.size.height - self.dateField.inputView.frame.size.height;
    self.dateField.inputAccessoryView = [self createDateFieldInputAccessoryViewWithHeight:height];
}

// Kind of a hack, the purpose of this view is to allow the user to tap outside
// the inputView to dismiss it. The order table view was interfering with this
// behavior.
- (UIView *)createDateFieldInputAccessoryViewWithHeight:(CGFloat)height {
    CGRect rect =CGRectMake(0, 0, self.view.frame.size.width, height);

    UIView *view = [[UIView alloc] initWithFrame:rect];
    view.backgroundColor = [UIColor clearColor];

    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    [view addGestureRecognizer:gestureRecognizer];

    return view;
}

- (UIDatePicker *)createDateFieldInputView {
    UIDatePicker *datePicker;
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_7_1){
        datePicker = [[UIDatePicker alloc] init];
        datePicker.backgroundColor = [UIColor clearColor];
    } else {
        datePicker = [[DatePicker alloc] init];
    }

    datePicker.datePickerMode = UIDatePickerModeDate;
    datePicker.minimumDate = [NSDate date];
    [datePicker addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
    return datePicker;
}

- (void)configureLabels {
    self.labels = @[self.totalLabel];
    for (UILabel *label in self.labels) {
        label.font = [ThemeManager sharedInstance].normalFont;
        label.textColor = [ThemeManager sharedInstance].normalFontColor;
    }
}

- (void)configureOrderItemsTableView {
    self.orderItemsTableView.backgroundColor = [UIColor clearColor];
    self.orderItemsTableView.alwaysBounceVertical = NO;

    self.orderItemsTableView.dataSource = self;
    self.orderItemsTableView.delegate = self;

    // Register the table cell here so we don't need to do it in the delegate method.
    [self.orderItemsTableView registerClass:[OrderItemTableViewCell class] forCellReuseIdentifier:kOrderItemCellIdentifier];
}

- (void)refreshOrderWithCurrentDate {
    self.currentDate = self.dateField.text;
    NSDate *date = [self.dateFormatter dateFromString:self.currentDate];
    [self refreshOrderWithDate:date];
}

@end
