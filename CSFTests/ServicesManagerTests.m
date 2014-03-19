//
//  ServicesManagerTests.m
//  CSF
//
//  Created by Seamus McGowan on 3/19/14.
//  Copyright (c) 2014 Seamus McGowan. All rights reserved.
//
#define EXP_SHORTHAND

#import <XCTest/XCTest.h>
#import <Expecta/Expecta.h>
#import "ServicesManager.h"

@interface ServicesManagerTests : XCTestCase

@end

@implementation ServicesManagerTests

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
    expect([ServicesManager sharedInstance]).to.conformTo(@protocol(ServicesManagerProtocol));
}


@end
