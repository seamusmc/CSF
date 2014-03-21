//
//  OrderDataServiceTests.m
//  CSF
//
//  Created by Seamus McGowan on 3/20/14.
//  Copyright (c) 2014 Seamus McGowan. All rights reserved.
//

#define EXP_SHORTHAND

#import <XCTest/XCTest.h>
#import <Expecta/Expecta.h>
#import "OrderDataServiceProtocol.h"
#import "ServiceLocator.h"
#import "User.h"
#import "Order.h"
#import "TestConstants.h"

@interface OrderDataServiceTests : XCTestCase

@end

@implementation OrderDataServiceTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testGetOrderForUserForFarmForDateWithCompletionHandler
{
    id <OrderDataServiceProtocol> service = [ServiceLocator sharedInstance].orderDataService;

    __block Order *order;

    User *user = [[User alloc] initWithFirstname:TestFirstname lastname:TestLastname group:TestGroup];

    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setMonth:3];
    [components setDay:20];
    [components setYear:2014];

    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDate     *date  = [gregorian dateFromComponents:components];

    [service getOrderForUser:user
                     forFarm:TestFarm
                     forDate:date
       withCompletionHandler:^(Order *tempOrder)
       {
           order = tempOrder;
           NSLog(@"%@", order);
       }];

    expect(order.items.count).will.beGreaterThan(1);
}

@end