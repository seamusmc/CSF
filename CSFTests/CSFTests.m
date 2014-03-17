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

- (void)testGetItemTypes
{
    NSArray *types = [self getItemTypes:nil];
    expect(types).will.beNil();
}

NSString* const kGetItemTypesURI = @"http://www.ohiorawmilk.info/mobileoerest/RestService.svc/foe/itemtypes/?farm=%@";
- (NSArray*) getItemTypes:(NSError**)error
{
    NSURLResponse* response;

    NSString* uri = [NSString stringWithFormat:kGetItemTypesURI, @"FARM2U"];
    uri = [uri stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    NSURL* url = [NSURL URLWithString:uri];

    NSURLRequest* request = [NSURLRequest requestWithURL:url];
    NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:error];
    NSArray* types;
    if (data)
    {
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        types = [json objectForKey:@"Types"];
    }

    return types;
}

@end
