//
// Created by Seamus McGowan on 3/20/14.
// Copyright (c) 2014 Seamus McGowan. All rights reserved.
//

#import "NetworkingService.h"

@implementation NetworkingService

- (void)getDataWithURI:(NSString *)uri withCompletionHandler:(void (^)(id responseObject))completionHandler {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];

    uri = [uri stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:uri];

    NSURLSession *session = [self createSession];

    NSURLSessionDataTask *task = [session dataTaskWithURL:url
                                        completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                switch (httpResponse.statusCode) {
                    case NetworkingServiceCodeSuccess: {
                        id responseObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                        completionHandler(responseObject);
                        break;
                    }
                    case NetworkingServiceCodeBadRequest: {
                        NSString *description = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                        DDLogWarn(@"WARN: %s Bad Status: %ld Message: %@", __PRETTY_FUNCTION__, (long) httpResponse.statusCode, description);
                        break;
                    }

                    default: {
                        DDLogWarn(@"WARN: %s Bad Status: %ld.", __PRETTY_FUNCTION__, (long) httpResponse.statusCode);
                        if (error) {
                            DDLogError(@"ERROR: %s Message: %@.", __PRETTY_FUNCTION__, error);
                        }
                        completionHandler(NULL);
                        break;
                    }
                }
            }];

    [task resume];
}

- (NSURLSession *)createSession {
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    [sessionConfig setHTTPAdditionalHeaders:@{@"Accept" : @"application/json"}];
    sessionConfig.timeoutIntervalForRequest  = 10.0;
    sessionConfig.timeoutIntervalForResource = 10.0;

    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfig];
    return session;
}

+ (id <NetworkingServiceProtocol>)sharedInstance {
    static NetworkingService *sharedInstance = nil;
    static dispatch_once_t   onceToken;

    dispatch_once(&onceToken, ^{
        sharedInstance = [[NetworkingService alloc] init];
    });

    return sharedInstance;
}

@end