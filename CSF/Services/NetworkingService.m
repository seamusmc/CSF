//
// Created by Seamus McGowan on 3/20/14.
// Copyright (c) 2014 Seamus McGowan. All rights reserved.
//

#import "NetworkingService.h"

@implementation NetworkingService

- (NSError *)createErrorWithCode:(NSUInteger)code description:(NSString *)description {
    NSError *newError;

    NSDictionary *userInfo = @{NSLocalizedDescriptionKey : description};
    newError = [[NSError alloc] initWithDomain:kNetworkingServiceDomain code:code userInfo:userInfo];
    return newError;
}

- (void)getDataWithURI:(NSString *)uri
          successBlock:(void (^)(id response))successBlock
          failureBlock:(void (^)(NSError *error))failureBlock {
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
                        DDLogInfo(@"INFO: %s Response JSON: %@", __PRETTY_FUNCTION__, responseObject);
                        successBlock(responseObject);
                        break;
                    }
                    case NetworkingServiceCodeBadRequest: {
                        NSString *description = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                        DDLogError(@"ERROR: %s Bad Status: %ld Message: %@", __PRETTY_FUNCTION__, (long) httpResponse.statusCode, description);

                        NSError *serviceError = [self createErrorWithCode:NetworkingServiceCodeBadRequest
                                                              description:@"Something has gone wrong"];
                        failureBlock(serviceError);
                        break;
                    }
                    case NetworkingServiceCodeServiceUnavailable: {
                        DDLogWarn(@"WARN: %s Bad Status: %ld.", __PRETTY_FUNCTION__, (long) httpResponse.statusCode);
                        NSError *serviceError = [self createErrorWithCode:NetworkingServiceCodeServiceUnavailable
                                                              description:@"The service is unavailable"];
                        failureBlock(serviceError);
                        break;
                    }
                    default: {
                        DDLogWarn(@"WARN: %s Bad Status: %ld.", __PRETTY_FUNCTION__, (long) httpResponse.statusCode);
                        if (error) {
                            switch (error.code) {
                                case NSURLErrorTimedOut: {
                                    DDLogError(@"ERROR: %s Timeout: %@.",
                                               __PRETTY_FUNCTION__,
                                               [error localizedDescription]);
                                    NSError *serviceError = [self createErrorWithCode:NSURLErrorTimedOut
                                                                          description:@"Request timed out"];
                                    failureBlock(serviceError);
                                    break;
                                }
                                default: {
                                    DDLogError(@"ERROR: %s Message: %@.", __PRETTY_FUNCTION__, error);
                                    NSError *serviceError = [self createErrorWithCode:NetworkingServiceCodeUnknown
                                                                          description:@"Something has gone wrong"];
                                    failureBlock(serviceError);
                                    break;
                                }
                            }
                        } else {
                            DDLogError(@"ERROR: %s Message: %@.", __PRETTY_FUNCTION__, error);
                            NSError *serviceError = [self createErrorWithCode:NetworkingServiceCodeUnknown
                                                                  description:@"Something has gone wrong"];
                            failureBlock(serviceError);
                            break;
                        }
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