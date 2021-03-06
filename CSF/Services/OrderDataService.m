//
// Created by Seamus McGowan on 3/20/14.
// Copyright (c) 2014 Seamus McGowan. All rights reserved.
//

#import "OrderDataService.h"
#import "User.h"
#import "Order.h"
#import "ServiceConstants.h"
#import "NetworkingServiceProtocol.h"
#import "ServiceLocator.h"
#import "OrderItem.h"

@interface OrderDataService ()

@property(nonatomic, strong, readonly) id <NetworkingServiceProtocol> networkingService;

@end

@implementation OrderDataService {
    NSDateFormatter *_dateFormatter;
    NSNumberFormatter *_currencyFormatter;
}

- (NSNumberFormatter *)currencyFormatter {
    if (_currencyFormatter == nil) {
        _currencyFormatter = [[NSNumberFormatter alloc] init];
        _currencyFormatter.numberStyle  = NSNumberFormatterCurrencyStyle;
        _currencyFormatter.currencyCode = @"USD";
    }

    return _currencyFormatter;
}

- (id)init {
    self = [super init];
    if (self) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateStyle:NSDateFormatterShortStyle];
        [_dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    }

    return self;
}

+ (id <OrderDataServiceProtocol>)sharedInstance {
    static OrderDataService *sharedInstance = nil;
    static dispatch_once_t  onceToken;

    dispatch_once(&onceToken, ^{
        sharedInstance = [[OrderDataService alloc] init];
    });

    return sharedInstance;
}

- (void)removeItem:(OrderItem *)item
              user:(User *)user
              date:(NSDate *)date
      successBlock:(void (^)(void))successBlock
      failureBlock:(void (^)(NSString *message))failureBlock {

    if (!successBlock) {
        return;
    }

    NSString *comment;
    if (item.comment == nil || [item.comment isEqualToString:@""])
        comment = [NSString stringWithFormat:@"\"\""];
    else
        comment = item.comment;

    NSString *stringFromDate = [_dateFormatter stringFromDate:date];
    NSString *uri            = [NSString stringWithFormat:kUpdateOrderURI,
                                                          user.farm,
                                                          user.group,
                                                          user.firstname,
                                                          user.lastname,
                                                          stringFromDate,
                                                          item.name,
                                                          item.quantity,
                                                          comment,
                                                          @"true"];

    [self.networkingService postDataWithURLString:uri
                                     successBlock:^(id response) {
                                         successBlock();
                                     }
                                     failureBlock:^(NSError *error) {
                                         if (failureBlock) {
                                             failureBlock([error localizedDescription]);
                                         }
                                     }];
}

- (void)addItem:(OrderItem *)item
           user:(User *)user
           date:(NSDate *)date
   successBlock:(void (^)(void))successBlock
   failureBlock:(void (^)(NSString *message))failureBlock{

    if (!successBlock) {
        return;
    }

    NSString *comment;
    if (item.comment == nil || [item.comment isEqualToString:@""])
        comment = [NSString stringWithFormat:@"\"\""];
    else
        comment = item.comment;

    NSString *stringFromDate = [_dateFormatter stringFromDate:date];
    NSString *uri            = [NSString stringWithFormat:kUpdateOrderURI,
                                                          user.farm,
                                                          user.group,
                                                          user.firstname,
                                                          user.lastname,
                                                          stringFromDate,
                                                          [item.name capitalizedString],
                                                          item.quantity,
                                                          comment,
                                                          @"false"];

    [self.networkingService postDataWithURLString:uri
                                     successBlock:^(id response) {
                                         successBlock();
                                     }
                                     failureBlock:^(NSError *error) {
                                         if (failureBlock) {
                                             failureBlock([error localizedDescription]);
                                         }
                                     }];
}


- (void)getOrderForUser:(User *)user
                   date:(NSDate *)date
           successBlock:(void (^)(Order *order))successBlock
           failureBlock:(void (^)(NSString *message))failureBlock {

    if (!successBlock) {
        return;
    }

    NSString *stringFromDate = [_dateFormatter stringFromDate:date];
    NSString *uri            = [NSString stringWithFormat:kGetOrderByUserURI,
                                                          user.farm,
                                                          user.group,
                                                          user.firstname,
                                                          user.lastname,
                                                          stringFromDate];
    [self.networkingService getDataWithURI:uri
                              successBlock:^(id response) {
                                  if (response) {
                                      NSString *formattedTotal = [self getFormattedTotal:response];

                                      BOOL locked;
                                      locked = [[response objectForKey:@"Locked"] boolValue];

                                      NSMutableArray *items     = [NSMutableArray array];
                                      NSArray        *tempItems = [response objectForKey:@"Items"];
                                      for (id  item in tempItems) {
                                          OrderItem *orderItem = [[OrderItem alloc] init];

                                          orderItem.type     = [item objectForKey:@"Type"];
                                          orderItem.name     = [[item objectForKey:@"Item"] lowercaseString];
                                          orderItem.quantity = [NSDecimalNumber decimalNumberWithString:[[item objectForKey:@"Qty"] stringValue]];
                                          orderItem.comment  = [[item objectForKey:@"Comment"] lowercaseString];

                                          if ([orderItem.comment isEqualToString:@"\"\""]) {
                                              orderItem.comment = nil;
                                          }

                                          [items addObject:orderItem];
                                      }

                                      NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
                                      NSArray *sortedItems=[items sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];

                                      Order *order = [[Order alloc] initWithLockedFlag:locked items:sortedItems total:formattedTotal];
                                      successBlock(order);
                                  }
                              }
                              failureBlock:^(NSError *error) {
                                  if (failureBlock) {
                                      failureBlock([error localizedDescription]);
                                  }
                              }];
}

#pragma mark - Private

- (NSString *)getFormattedTotal:(id)response {
    NSString *total;
    total = [response objectForKey:@"Total"];

    NSString *formattedTotal;
    if (total != nil) {
        NSNumber *totalValue;
        totalValue = [[NSNumber alloc] initWithFloat:[total floatValue]];

        formattedTotal = [self.currencyFormatter stringFromNumber:totalValue];
    }

    return formattedTotal;
}

- (id <NetworkingServiceProtocol>)networkingService {
    return [ServiceLocator sharedInstance].networkingService;
}

@end