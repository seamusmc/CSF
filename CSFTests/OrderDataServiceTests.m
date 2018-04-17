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

@implementation OrderDataServiceTests {
    NSDate *_date;
}

- (void)setUp {
    [super setUp];

    // Put setup code here. This method is called before the invocation of each test method in the class.
    [Expecta setAsynchronousTestTimeout:5];

    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setMonth:3];
    [components setDay:20];
    [components setYear:2014];

    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    _date = [gregorian dateFromComponents:components];
}

- (void)tearDown {
    // Put tear down code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testGetOrderForUserDateSuccessBlockFailureBlock {
    id <OrderDataServiceProtocol> service = [ServiceLocator sharedInstance].orderDataService;

    __block Order *order;

    User *user = [[User alloc] initWithFirstname:TestFirstname lastname:TestLastname group:TestGroup farm:TestFarm];
    [service getOrderForUser:user
                        date:_date
                successBlock:^(Order *tempOrder) {
        order = tempOrder;
        NSLog(@"%@", order);
    }
                failureBlock:nil];

    expect(order.items.count).will.beGreaterThan(1);
}

- (void)testGetOrderForNilUserDateSuccessBlockFailureBlock {
    id <OrderDataServiceProtocol> service = [ServiceLocator sharedInstance].orderDataService;

    __block NSString *message;

    [service getOrderForUser:nil
                        date:_date
                successBlock:^(Order *tempOrder){
        NSLog(@"Should not reach this!");
    }
                failureBlock:^(NSString *tempMessage){
        message = tempMessage;
        NSLog(@"Message: %@", tempMessage);
    }];

    expect(message).will.equal(@"oops! something went wrong");
}

- (void)testGetOrderForBadUserForDateWithCompletionHandler {
    id <OrderDataServiceProtocol> service = [ServiceLocator sharedInstance].orderDataService;

    __block Order *order;

    User *user = [[User alloc] initWithFirstname:@"NoOne" lastname:@"Special" group:TestGroup farm:TestFarm];
    [service getOrderForUser:user
                        date:_date
                successBlock:^(Order *tempOrder){
        order = tempOrder;
    }
                failureBlock:^(NSString *message){

        NSLog(@"Should not reach this!");
    }];

    expect(order.items.count).will.equal(0);
}

- (void)testGetOrderForUserForDateWithBadFarmWithCompletionHandler {
    id <OrderDataServiceProtocol> service = [ServiceLocator sharedInstance].orderDataService;

    __block NSString *message;

    User *user = [[User alloc] initWithFirstname:TestFirstname lastname:TestLastname group:TestGroup farm:@"FOO"];
    [service getOrderForUser:user
                        date:_date
                successBlock:^(Order *tempOrder){
        NSLog(@"Should not reach this!");
    }
                failureBlock:^(NSString *tempMessage){
        message = tempMessage;
        NSLog(@"Message: %@", tempMessage);
    }];

    expect(message).will.equal(@"oops! something went wrong");
}

@end
