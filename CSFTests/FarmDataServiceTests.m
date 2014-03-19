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
#import "FarmDataService.h"

@interface FarmDataServiceTests : XCTestCase

@end

@implementation FarmDataServiceTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put tear down code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testConformance
{
    expect([FarmDataService sharedInstance]).to.conformTo(@protocol(FarmDataServiceProtocol));
}

- (void)testFarmsProperty
{
    id <FarmDataServiceProtocol> service = [FarmDataService sharedInstance];
    NSArray *farms = service.farms;

    NSArray *list = @[@"FARM2U", @"HHAVEN", @"JUBILEE", @"YODER"];
    expect(farms).to.beSupersetOf(list);
}

- (void)testGetItemTypes
{
    id <FarmDataServiceProtocol> service = [FarmDataService sharedInstance];

    __block NSArray *types;
    [service getItemTypesForFarm:@"FARM2U" withCompletionHandler:^(NSArray *typeList){
        types = typeList;
    }];

    expect([types count]).will.beGreaterThan(0);
}

@end
