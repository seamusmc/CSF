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

@property(nonatomic, strong, readonly) id <NetworkingServiceProtocol> networkingService;

@end

@implementation FarmDataService

+ (id <FarmDataServiceProtocol>)sharedInstance {
    static FarmDataService *sharedInstance = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        sharedInstance = [[FarmDataService alloc] init];
    });

    return sharedInstance;
}

- (NSArray *)farms {
    return @[@"hhaven", @"jubilee", @"yoder", @"farm2u"];
}

- (void)getItemTypesForFarm:(NSString *)farm
               successBlock:(void (^)(NSArray *types))successBlock
               failureBlock:(void (^)(NSString *message))failureBlock {
    if (!successBlock) {
        return;
    }

    NSString *uri = [NSString stringWithFormat:kGetItemTypesURI, farm];
    [self.networkingService getDataWithURI:uri
                              successBlock:^(id response){
        if (response) {
            NSArray *types = [response objectForKey:@"Types"];
            successBlock(types);
        }
    }
                              failureBlock:^(NSError *error){
        if (failureBlock) {
            failureBlock([error localizedDescription]);
        }
    }];
}

- (void)getItemsForFarm:(NSString *)farm
                   type:(NSString *)type
           successBlock:(void (^)(NSArray *items))successBlock
           failureBlock:(void (^)(NSString *message))failureBlock {
    if (!successBlock) {
        return;
    }

    NSString *uri = [NSString stringWithFormat:kGetItemsURI, farm, type];
    [self.networkingService getDataWithURI:uri
                              successBlock:^(id response){
        if (response) {
            NSArray        *items          = [response objectForKey:@"Items"];
            NSMutableArray *inventoryItems = [[NSMutableArray alloc] init];

            for (id item in items) {
                InventoryItem *inventoryItem = [[InventoryItem alloc] init];
                inventoryItem.name       = [item objectForKey:@"Name"];
                inventoryItem.outOfStock = [[item objectForKey:@"OutOfStock"] boolValue];
                inventoryItem.type       = type;

                NSString *price = [[item objectForKey:@"RetailPrice"] stringValue];
                inventoryItem.price = [NSDecimalNumber decimalNumberWithString:price];

                [inventoryItems addObject:inventoryItem];
            }

            successBlock(inventoryItems);
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