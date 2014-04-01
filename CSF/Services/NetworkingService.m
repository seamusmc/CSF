//
// Created by Seamus McGowan on 3/20/14.
// Copyright (c) 2014 Seamus McGowan. All rights reserved.
//

#import "NetworkingService.h"

@implementation NetworkingService

- (void)getDataWithURI:(NSString *)uri withCompletionHandler:(void (^)(id responseObject))completionHandler
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];

    uri        = [uri stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:uri];

    NSURLSession         *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task    = [session dataTaskWithURL:url
                                           completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
                                           {
                                               [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

                                               NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                                               if (httpResponse.statusCode == 200 && !error)
                                               {
                                                   id responseObject  = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                                                   completionHandler(responseObject);
                                               }
                                               else
                                               {
                                                   NSString *class = NSStringFromClass([self class]);
                                                   NSLog(@"%@:%s Bad Status: %ld.", class, __PRETTY_FUNCTION__, (long)httpResponse.statusCode);

                                                   if (error)
                                                   {
                                                       NSLog(@"%@:%s Error: %@.", class, __PRETTY_FUNCTION__, error);
                                                   }

                                                   completionHandler(NULL);
                                               }
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