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
#import "FXKeychain.h"

@interface UserServicesTests : XCTestCase

@end

@implementation UserServicesTests

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

- (void)testStoreUserWithPassword
{
    User *user = [[User alloc] initWithFirstname:TestFirstname lastname:TestLastname group:TestGroup farm:TestFarm];
    [[ServiceLocator sharedInstance].userServices storeUser:user withPassword:TestPassword];

    FXKeychain *keychain = [FXKeychain defaultKeychain];

    User *usr = [[User alloc] initWithFirstname:keychain[@"firstname"]
                                       lastname:keychain[@"lastname"]
                                          group:keychain[@"group"]
                                           farm:keychain[@"farm"]];

    NSLog(@"User: %@", usr);

    expect(usr.firstname).to.equal(user.firstname);
    expect(usr.lastname).to.equal(user.lastname);
    expect(usr.group).to.equal(user.group);
    expect(usr.farm).to.equal(user.farm);
    expect(keychain[@"password"]).to.equal(TestPassword);
}

- (void)testRetrieveUserAndPasswordFromStoreWithCompletionHandler
{
    FXKeychain *keychain = [FXKeychain defaultKeychain];

    keychain[@"firstname"] = TestFirstname;
    keychain[@"lastname"]  = TestLastname;
    keychain[@"group"]     = TestGroup;
    keychain[@"farm"]      = TestFarm;
    keychain[@"password"]  = TestPassword;

    __block User *user;
    __block NSString *password;

    [[ServiceLocator sharedInstance].userServices retrieveUserAndPasswordFromStoreWithCompletionHandler:^(User *usr, NSString *pword)
    {
        user = usr;
        password = pword;
    }];

    expect(user.firstname).to.equal(TestFirstname);
    expect(user.lastname).to.equal(TestLastname);
    expect(user.group).to.equal(TestGroup);
    expect(user.farm).to.equal(TestFarm);
    expect(password).to.equal(TestPassword);
}

- (void)testNegativeRetrieveUserAndPasswordFromStoreWithCompletionHandler
{
    FXKeychain *keychain = [FXKeychain defaultKeychain];

    keychain[@"firstname"] = TestFirstname;
    keychain[@"lastname"]  = TestLastname;
    keychain[@"group"]     = TestGroup;
    keychain[@"farm"]      = TestFarm;
    keychain[@"password"]  = TestPassword;

    __block User *user;
    __block NSString *password;

    [[ServiceLocator sharedInstance].userServices retrieveUserAndPasswordFromStoreWithCompletionHandler:^(User *usr, NSString *pword)
    {
        user = usr;
        password = pword;
    }];

    expect(user.firstname).toNot.equal(@"Firstname");
    expect(user.lastname).toNot.equal(@"Lastname");
    expect(user.group).toNot.equal(@"Groupe");
    expect(user.farm).toNot.equal(@"Farm");
    expect(password).toNot.equal(@"Password");
}

- (void)testAuthenticateUserWithPassword
{
    User *user = [[User alloc] initWithFirstname:TestFirstname lastname:TestLastname group:TestGroup farm:TestFarm];

    __block BOOL authenticated = NO;
    [[ServiceLocator sharedInstance].userServices authenticateUser:user withPassword:TestPassword withCompletionHandler:^(BOOL isAuthenticated)
    {
        authenticated = isAuthenticated;
        NSLog(@"%@", [ServiceLocator sharedInstance].userServices.currentUser);
    }];

    expect(authenticated).will.beTruthy();
}

- (void)testAuthenticateUserWithBadPassword
{
    User *user = [[User alloc] initWithFirstname:TestFirstname lastname:TestLastname group:TestGroup farm:TestFarm];

    __block BOOL authenticated = YES;
    [[ServiceLocator sharedInstance].userServices authenticateUser:user withPassword:@"4321" withCompletionHandler:^(BOOL isAuthenticated)
    {
        authenticated = isAuthenticated;
    }];

    expect(authenticated).willNot.beTruthy();
}

- (void)testAuthenticateUserWithBadFarm
{
    User *user = [[User alloc] initWithFirstname:TestFirstname lastname:TestLastname group:TestGroup farm:@"FOOL"];

    __block BOOL authenticated = YES;
    [[ServiceLocator sharedInstance].userServices authenticateUser:user withPassword:TestPassword withCompletionHandler:^(BOOL isAuthenticated)
    {
        authenticated = isAuthenticated;
    }];

    expect(authenticated).willNot.beTruthy();
}

- (void)testAuthenticateUserWithBadName
{
    User *user = [[User alloc] initWithFirstname:@"NoOne" lastname:@"Special" group:TestGroup farm:TestFarm];

    __block BOOL authenticated = YES;
    [[ServiceLocator sharedInstance].userServices authenticateUser:user withPassword:TestPassword withCompletionHandler:^(BOOL isAuthenticated)
    {
        authenticated = isAuthenticated;
    }];

    expect(authenticated).willNot.beTruthy();
}

@end
