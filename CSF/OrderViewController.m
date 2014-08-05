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
#import "UIColor+Extended.h"
#import "UIImageView+Extended.h"

@interface OrderViewController () <UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource>

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
    [self requestOrderWithDate:[NSDate date]];

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
        _activityIndicator = [self createActivityIndicator];
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
        NSDate *date = [self.dateFormatter dateFromString:self.dateField.text];
        [self requestOrderWithDate:date];
    }
}

- (void)keyboardWillShow:(NSNotification *)notification {
    self.currentDate = self.dateField.text;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.order.items count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    OrderItem *item = self.order.items[indexPath.row];

    OrderItemTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kOrderItemCellIdentifier forIndexPath:indexPath];
    cell.name = item.name;
    cell.quantity = [NSString stringWithFormat:@"qty ~ %@", item.quantity];
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 52.0f;
}

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

#pragma mark - Date Picker Actions

- (void)dateChanged:(id)sender {
    if ([sender isKindOfClass:[UIDatePicker class]]) {
        UIDatePicker *datePicker = sender;
        self.dateField.text = [self.dateFormatter stringFromDate:datePicker.date];
    }
}

#pragma mark - Private

- (FBShimmeringView *)createActivityIndicator {
    CGRect frame = CGRectMake(0, 0, self.view.bounds.size.width, 1.0f);
    FBShimmeringView *shimmeringView = [[FBShimmeringView alloc] initWithFrame:frame];

    shimmeringView.hidden                      = YES;
    shimmeringView.shimmeringSpeed             = [ThemeManager sharedInstance].shimmerSpeed;
    shimmeringView.shimmeringBeginFadeDuration = [ThemeManager sharedInstance].shimmeringBeginFadeDuration;
    shimmeringView.shimmeringEndFadeDuration   = [ThemeManager sharedInstance].shimmeringEndFadeDuration;
    shimmeringView.shimmeringOpacity           = [ThemeManager sharedInstance].shimmeringOpacity;

    [self.view addSubview:shimmeringView];

    UIView *progressView = [[UIView alloc] initWithFrame:shimmeringView.bounds];
    progressView.backgroundColor = [ThemeManager sharedInstance].shimmeringColor;
    shimmeringView.contentView = progressView;

    return shimmeringView;
}

- (void)requestOrderWithDate:(NSDate *)date {
    [self.activityIndicator start];

    __typeof(self) __weak weakSelf = self;
    [[OrderDataService sharedInstance] getOrderForUser:[UserServices sharedInstance].currentUser
                                                  date:date
                                          successBlock:^(Order *tempOrder) {
        self.order = tempOrder;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.activityIndicator stop];

            self.totalLabel.text = [NSString stringWithFormat:@"total ~ %@", self.order.total];
            [self.orderItemsTableView reloadData];
        });
    }
                                          failureBlock:^(NSString *message){
        [weakSelf.activityIndicator stop];
    }];
}

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
    [datePicker addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];

    [self configurePicker:datePicker];

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

- (void)configurePicker:(UIDatePicker *)picker {
    UIView *pickerView = picker.subviews[0];

    // Make the selection indicators white with an alpha so that they are visible.
    UIView *temp = pickerView.subviews[1];
    temp.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.5f];

    temp = pickerView.subviews[2];
    temp.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.5f];

    // All we need is the bottom of the background image.
    UIImage *backgroundImage = [UIImage imageNamed:@"farm"];
    CGRect  rect             = CGRectMake(0,
                                          backgroundImage.size.height - pickerView.bounds.size.height,
                                          pickerView.bounds.size.width,
                                          pickerView.bounds.size.height);

    UIImage *croppedImage = [self getSubImageFrom:backgroundImage
                                         WithRect:rect];

    UIImageView *imageView = [[UIImageView alloc] initWithImage:croppedImage];
    imageView.bounds      = picker.bounds;
    imageView.contentMode = UIViewContentModeBottom | UIViewContentModeRedraw;
    [imageView tintWithColor:[UIColor colorWithRGBHex:0x000000 alpha:0.5f]];

    [pickerView insertSubview:imageView atIndex:0];

    // Use the UIToolbar as an overlay, it still can give us the blurred or translucent effect we are after.
    UIToolbar *overlayHack = [[UIToolbar alloc] initWithFrame:picker.bounds];
    overlayHack.barStyle    = UIBarStyleBlackTranslucent;
    overlayHack.translucent = YES;

    [pickerView insertSubview:overlayHack atIndex:1];
}

- (UIImage *)getSubImageFrom:(UIImage *)img WithRect:(CGRect)rect {
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();

    // Translated rectangle for drawing sub image
    CGRect drawRect = CGRectMake(-rect.origin.x, -rect.origin.y, img.size.width, img.size.height);

    // Clip to the bounds of the image context
    // not strictly necessary as it will get clipped anyway?
    CGContextClipToRect(context, CGRectMake(0, 0, rect.size.width, rect.size.height));

    // Draw image
    [img drawInRect:drawRect];

    // Grab image
    UIImage *subImage = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();

    return subImage;
}


@end
