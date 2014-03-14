//
//  CSFTests.m
//  CSFTests
//
//  Created by Seamus McGowan on 3/14/14.
//  Copyright (c) 2014 Seamus McGowan. All rights reserved.
//

#define EXP_SHORTHAND

#import <XCTest/XCTest.h>
#import "Expecta.h"

@interface CSFTests : XCTestCase

@end

@implementation CSFTests

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

- (void)testExample
{
    expect(@"foo").to.equal(@"foo");
    // XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

@end
