//
//  UserServiceTests.m
//  CSF
//
//  Created by Seamus McGowan on 3/26/14.
//  Copyright (c) 2014 Seamus McGowan. All rights reserved.
//

#define EXP_SHORTHAND

#import <XCTest/XCTest.h>
#import <Expecta/Expecta.h>
#import "TestConstants.h"
#import "ServiceLocator.h"
#import "UserServicesProtocol.h"
#import "User.h"

@interface UserServicesTests : XCTestCase

@end

@implementation UserServicesTests

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

- (void)testAuthenticateUserWithPassword
{
    User * user = [[User alloc] initWithFirstname:TestFirstname lastname:TestLastname group:TestGroup farm:TestFarm];

    __block BOOL authenticated = NO;
    [[ServiceLocator sharedInstance].userService authenticateUser:user withPassword:TestPassword withCompletionHandler:^(BOOL isAuthenticated)
    {
        authenticated = isAuthenticated;
        NSLog(@"%@", [ServiceLocator sharedInstance].userService.currentUser);
    }];

    expect(authenticated).will.beTruthy();
}

- (void)testAuthenticateUserWithBadPassword
{
    User * user = [[User alloc] initWithFirstname:TestFirstname lastname:TestLastname group:TestGroup farm:TestFarm];

    __block BOOL authenticated = YES;
    [[ServiceLocator sharedInstance].userService authenticateUser:user withPassword:@"4321" withCompletionHandler:^(BOOL isAuthenticated)
    {
        authenticated = isAuthenticated;
    }];

    expect(authenticated).willNot.beTruthy();
}


- (void)testAuthenticateUserWithBadFarm
{
    User * user = [[User alloc] initWithFirstname:TestFirstname lastname:TestLastname group:TestGroup farm:@"FOOL"];

    __block BOOL authenticated = YES;
    [[ServiceLocator sharedInstance].userService authenticateUser:user withPassword:TestPassword withCompletionHandler:^(BOOL isAuthenticated)
    {
        authenticated = isAuthenticated;
    }];

    expect(authenticated).willNot.beTruthy();
}

- (void)testAuthenticateUserWithBadName
{
    User * user = [[User alloc] initWithFirstname:@"NoOne" lastname:@"Special" group:TestGroup farm:TestFarm];

    __block BOOL authenticated = YES;
    [[ServiceLocator sharedInstance].userService authenticateUser:user withPassword:TestPassword withCompletionHandler:^(BOOL isAuthenticated)
    {
        authenticated = isAuthenticated;
    }];

    expect(authenticated).willNot.beTruthy();
}

@end
