//
//  EditItemViewController.m
//  CSF
//
//  Created by Seamus McGowan on 3/3/15.
//  Copyright (c) 2015 Seamus McGowan. All rights reserved.
//

#import <Shimmer/FBShimmeringView.h>
#import "EditItemViewController.h"
#import "ThemeManager.h"

@interface EditItemViewController ()

@property(nonatomic, copy) NSArray *labels;

@property(nonatomic, weak) IBOutlet UILabel *typeLabel;
@property(nonatomic, weak) IBOutlet UILabel *itemLabel;
@property(nonatomic, weak) IBOutlet UILabel *priceLabel;
@property(nonatomic, weak) IBOutlet UILabel *stockLabel;
@property(nonatomic, weak) IBOutlet UILabel *quantityLabel;
@property(nonatomic, weak) IBOutlet UILabel *commentLabel;
@property(nonatomic, weak) IBOutlet UILabel *notificationLabel;

@property(weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property(nonatomic, weak) IBOutlet UITextView *commentTextView;
@property(nonatomic, weak) IBOutlet UIButton   *editButton;
@property(nonatomic, weak) FBShimmeringView    *activityIndicator;

@end

@implementation EditItemViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor clearColor];
    [self configureLabels];
    [self configureButton];

    self.scrollView.scrollEnabled = NO;
    self.scrollView.bounds = self.scrollView.frame; // Not sure why this is not required in ItemViewController's ScrollView
}

- (void)viewDidLayoutSubviews {
    self.scrollView.contentSize = CGSizeMake(320, self.view.frame.size.height * 2);  // Basically two pages tall.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Private Methods
- (void)configureLabels {
    self.labels = @[self.typeLabel, self.itemLabel, self.priceLabel, self.stockLabel, self.quantityLabel, self.commentLabel];
    for (UILabel *label in self.labels) {
        label.font = [ThemeManager sharedInstance].normalFont;
        label.textColor = [ThemeManager sharedInstance].normalFontColor;
    }
}

- (void)configureButton {
    self.editButton.titleLabel.font = [ThemeManager sharedInstance].normalFont;

    [self.editButton setTitleColor:[ThemeManager sharedInstance].normalFontColor forState:UIControlStateNormal];
    [self.editButton setTitleColor:[ThemeManager sharedInstance].disabledColor forState:UIControlStateDisabled];

    self.editButton.layer.cornerRadius = 5.0f;
    self.editButton.layer.borderWidth  = 1.0f;
    self.editButton.layer.borderColor  = [ThemeManager sharedInstance].tintColor.CGColor;

    self.editButton.backgroundColor = [ThemeManager sharedInstance].tintColor;
    self.editButton.enabled = NO;
}

@end
