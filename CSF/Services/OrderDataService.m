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
                              successBlock:^(id response){
        if (response) {
            NSString *total;
            total = [response objectForKey:@"Total"];

            BOOL locked;
            locked = [[response objectForKey:@"Locked"] boolValue];

            NSMutableArray *items     = [NSMutableArray array];
            NSArray        *tempItems = [response objectForKey:@"Items"];
            for (id item in tempItems) {
                OrderItem *orderItem = [[OrderItem alloc] init];

                orderItem.type     = [item objectForKey:@"Type"];
                orderItem.name     = [item objectForKey:@"Item"];
                orderItem.quantity = [NSDecimalNumber decimalNumberWithString:[[item objectForKey:@"Qty"] stringValue]];
                orderItem.comment  = [item objectForKey:@"Comment"];

                [items addObject:orderItem];
            }

            Order *order = [[Order alloc] initWithLockedFlag:locked items:items total:total];
            successBlock(order);
        }
    }
                              failureBlock:^(NSError *error){
        if (failureBlock) {
            failureBlock([error localizedDescription]);
        }
    }];
}


- (id <NetworkingServiceProtocol>)networkingService {
    return [ServiceLocator sharedInstance].networkingService;
}

@end