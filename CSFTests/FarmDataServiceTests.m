//
//  FarmDataServiceTests.m
//  FarmDataServiceTests
//
//  Created by Seamus McGowan on 3/14/14.
//  Copyright (c) 2014 Seamus McGowan. All rights reserved.
//

#define EXP_SHORTHAND

#import <XCTest/XCTest.h>
#import "Expecta.h"
#import "FarmDataServiceProtocol.h"
#import "ServiceLocator.h"
#import "TestConstants.h"

@interface FarmDataServiceTests : XCTestCase

@end

@implementation FarmDataServiceTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.

    [Expecta setAsynchronousTestTimeout:5];
}

- (void)tearDown
{
    // Put tear down code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testConformance
{
    id <FarmDataServiceProtocol> service = [ServiceLocator sharedInstance].farmDataService;
    expect(service).to.conformTo(@protocol(FarmDataServiceProtocol));
}

- (void)testFarmsProperty
{
    id <FarmDataServiceProtocol> service = [ServiceLocator sharedInstance].farmDataService;
    NSArray                      *farms  = service.farms;

    NSArray *list = @[@"farm2u", @"hhaven", @"jubilee", @"yoder"];
    expect(farms).to.beSupersetOf(list);
}

- (void)testGetItemTypesForFarm
{
    id <FarmDataServiceProtocol> service = [ServiceLocator sharedInstance].farmDataService;

    __block NSArray *types;
    [service getItemTypesForFarm:TestFarm withCompletionHandler:^(NSArray *typeList)
    {
        types = typeList;
        NSLog(@"Types: %@", types);
    }];

    expect(types).willNot.beNil();
}

- (void)testGetItemsForFarmForType
{
    id <FarmDataServiceProtocol> service = [ServiceLocator sharedInstance].farmDataService;

    __block NSArray *items;
    [service getItemsForFarm:TestFarm forType:TestType withCompletionHandler:^(NSArray *itemList)
    {
        items = itemList;
        NSLog(@"Items: %@", items);
    }];

    expect(items).willNot.beNil();
}

@end
