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
        _currencyFormatter.NumberStyle  = NSNumberFormatterCurrencyStyle;
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
                                      for (id        item in tempItems) {
                                          OrderItem *orderItem = [[OrderItem alloc] init];

                                          orderItem.type     = [item objectForKey:@"Type"];
                                          orderItem.name     = [item objectForKey:@"Item"];
                                          orderItem.quantity = [NSDecimalNumber decimalNumberWithString:[[item objectForKey:@"Qty"] stringValue]];
                                          orderItem.comment  = [item objectForKey:@"Comment"];

                                          [items addObject:orderItem];
                                      }

                                      Order *order = [[Order alloc] initWithLockedFlag:locked items:items total:formattedTotal];
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

//- (BOOL) deleteItemWithIndex:(int)index error:(NSError**)error
//{
//    Item* item = [self.items objectAtIndex:index];
//
//    return [self updateItem:item
//                 deleteFlag:YES error:error];
//}
//
//- (BOOL) updateItem:(Item*)item deleteFlag:(BOOL)deleteFlag error:(NSError**)error
//{
//    NSURLResponse* response;
//
//    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
//    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
//    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
//
//    NSString* comment;
//    if (item.comment == nil || [item.comment isEqualToString:@""])
//        comment = [NSString stringWithFormat:@"\"\""];
//    else
//        comment = item.comment;
//
//    NSString* uri = [NSString stringWithFormat:kUpdateOrderURI,
//                                               self.farmData.farm,
//                                               self.userToken.group,
//                                               self.userToken.firstname,
//                                               self.userToken.lastname,
//                                               [dateFormatter stringFromDate:self.date],
//                                               item.name,
//                                               item.quantity,
//                                               comment,
//                                               deleteFlag ? @"true" : @"false"];
//
//    uri = [uri stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//    NSURL* url = [NSURL URLWithString:uri];
//
//    NSURLRequest* request = [NSURLRequest requestWithURL:url];
//    NSData* data = [NSURLConnection sendSynchronousRequest:request
//                                         returningResponse:&response
//                                                     error:error];
//    if (!data)
//    {
//        return NO;
//    }
//
//    return YES;
//}

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