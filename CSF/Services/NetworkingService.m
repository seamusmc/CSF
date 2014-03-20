//
// Created by Seamus McGowan on 3/20/14.
// Copyright (c) 2014 Seamus McGowan. All rights reserved.
//

#import "NetworkingService.h"

@implementation NetworkingService

- (void)getDataWithURI:(NSString *)uri withCompletionHandler:(void (^)(NSData *data))completionHandler
{
    uri        = [uri stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:uri];

    NSURLSession         *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task    = [session dataTaskWithURL:url
                                           completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
                                           {
                                               completionHandler(data);
                                           }];
    [task resume];
}

+ (id <NetworkingServiceProtocol>)sharedInstance
{
    static NetworkingService *sharedInstance = nil;
    static dispatch_once_t   onceToken;

    dispatch_once(&onceToken, ^
    {
        sharedInstance = [[NetworkingService alloc] init];
    });

    return sharedInstance;
}

@end