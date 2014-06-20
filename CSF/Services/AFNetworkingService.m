//
// Created by Seamus McGowan on 3/28/14.
// Copyright (c) 2014 Seamus McGowan. All rights reserved.
//

#import "AFNetworkingService.h"
#import "AFHTTPRequestOperation.h"

@implementation AFNetworkingService
{

}
- (void)getDataWithURI:(NSString *)uri withCompletionHandler:(void (^)(id responseObject))completionHandler
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];

    uri        = [uri stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:uri];

    NSURLRequest *request = [NSURLRequest requestWithURL:url
                                             cachePolicy:NSURLRequestUseProtocolCachePolicy
                                         timeoutInterval:10.0];

    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];

    op.responseSerializer = [AFJSONResponseSerializer serializer];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
    {
        NSLog(@"JSON: %@", responseObject);

        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        completionHandler(responseObject);
    }
    failure:^(AFHTTPRequestOperation *operation, NSError *error)
    {
      NSLog(@"Error: %@", error);

      [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
      completionHandler(NULL);
    }];

    [op start];
}

+ (id <NetworkingServiceProtocol>)sharedInstance
{
    static AFNetworkingService *sharedInstance = nil;
    static dispatch_once_t     onceToken;

    dispatch_once(&onceToken, ^
    {
        sharedInstance = [[AFNetworkingService alloc] init];
    });

    return sharedInstance;
}

@end