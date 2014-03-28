//
// Created by Seamus McGowan on 3/19/14.
// Copyright (c) 2014 Seamus McGowan. All rights reserved.
//

#import "FarmDataService.h"
#import "ServiceConstants.h"
#import "NetworkingServiceProtocol.h"
#import "ServiceLocator.h"
#import "InventoryItem.h"

@interface FarmDataService ()

// Declaring these properties, defined by FarmDatServiceProtocol,
// so that the ivar, getter and setter are generated
@property (nonatomic, strong) NSArray *farms;

@end

@implementation FarmDataService
{
    id <NetworkingServiceProtocol> _networkingService;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        _farms             = @[@"FARM2U", @"HHAVEN", @"JUBILEE", @"YODER"];
        _networkingService = [[ServiceLocator sharedInstance] networkingService];
    }

    return self;
}

+ (id <FarmDataServiceProtocol>)sharedInstance
{
    static FarmDataService *sharedInstance = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^
    {
        sharedInstance = [[FarmDataService alloc] init];
    });

    return sharedInstance;
}

- (void)getItemTypesForFarm:(NSString *)farm withCompletionHandler:(void (^)(NSArray *types))completionHandler
{
    NSString *uri = [NSString stringWithFormat:GetItemTypesURI, farm];
    [_networkingService getDataWithURI:uri withCompletionHandler:^(id responseObject)
    {
        if (responseObject)
        {
            NSArray *types = [responseObject objectForKey:@"Types"];
            completionHandler(types);
        }
    }];
}

- (void)getItemsForFarm:(NSString *)farm forType:(NSString *)type withCompletionHandler:(void (^)(NSArray *items))completionHandler
{
    NSString *uri = [NSString stringWithFormat:GetItemsURI, farm, type];

    [_networkingService getDataWithURI:uri withCompletionHandler:^(id responseObject)
    {
        if (responseObject)
        {
            NSLog(@"Order JSON: %@", responseObject);

            NSArray        *items          = [responseObject objectForKey:@"Items"];
            NSMutableArray *inventoryItems = [[NSMutableArray alloc] init];

            for (id item in items)
            {
                InventoryItem *inventoryItem = [[InventoryItem alloc] init];
                inventoryItem.name       = [item objectForKey:@"Name"];
                inventoryItem.outOfStock = [[item objectForKey:@"OutOfStock"] boolValue];
                inventoryItem.type       = type;

                NSString *price = [[item objectForKey:@"RetailPrice"] stringValue];
                inventoryItem.price = [NSDecimalNumber decimalNumberWithString:price];

                [inventoryItems addObject:inventoryItem];
            }

            completionHandler(inventoryItems);
        }
    }];
}

@end