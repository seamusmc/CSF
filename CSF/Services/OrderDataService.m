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

@implementation OrderDataService
{
    id <NetworkingServiceProtocol> _networkingService;
    NSDateFormatter                *_dateFormatter;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        _networkingService = [[ServiceLocator sharedInstance] networkingService];

        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateStyle:NSDateFormatterShortStyle];
        [_dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    }

    return self;
}

+ (id <OrderDataServiceProtocol>)sharedInstance
{
    static OrderDataService *sharedInstance = nil;
    static dispatch_once_t  onceToken;

    dispatch_once(&onceToken, ^
    {
        sharedInstance = [[OrderDataService alloc] init];
    });

    return sharedInstance;
}

- (void)getOrderForUser:(User *)user forDate:(NSDate *)date withCompletionHandler:(void (^)(Order *order))completionHandler
{
    NSString *stringFromDate = [_dateFormatter stringFromDate:date];
    NSString *uri            = [NSString stringWithFormat:GetOrderByUserURI, user.farm, user.group, user.firstname, user.lastname, stringFromDate];

    [_networkingService getDataWithURI:uri withCompletionHandler:^(id responseObject)
    {
        if (responseObject)
        {
            NSMutableArray *items = [NSMutableArray array];
            BOOL           locked;

            NSLog(@"Order JSON: %@", responseObject);

            locked = [[responseObject objectForKey:@"Locked"] boolValue];

            NSArray *tempItems = [responseObject objectForKey:@"Items"];
            for (id item in tempItems)
            {
                OrderItem *orderItem = [[OrderItem alloc] init];

                orderItem.type     = [item objectForKey:@"Type"];
                orderItem.name     = [item objectForKey:@"Item"];
                orderItem.quantity = [NSDecimalNumber decimalNumberWithString:[[item objectForKey:@"Qty"] stringValue]];
                orderItem.comment  = [item objectForKey:@"Comment"];

/*
                Item* farmItem = [self findItemWithFarmData:farmData andOrderItem:orderItem];

                orderItem.price = farmItem.price;
                orderItem.outOfStock = farmItem.outOfStock;
                orderItem.fractions = farmItem.fractions;*/

                [items addObject:orderItem];
            }

            Order *order = [[Order alloc] initWithLocked:locked items:items];
            completionHandler(order);
        }
        else
        {
            completionHandler(NULL);
        }
    }];
}

@end