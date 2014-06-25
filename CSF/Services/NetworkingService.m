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
                        // Bad request, should never be seen except during development
                        completionHandler(NULL);
                        break;
                    }
                    case NetworkingServiceCodeServiceUnavailable: {
                        DDLogWarn(@"WARN: %s Bad Status: %ld.", __PRETTY_FUNCTION__, (long) httpResponse.statusCode);
                        // Service is down try again later
                        completionHandler(NULL);
                        break;
                    }
                    default: {
                        DDLogWarn(@"WARN: %s Bad Status: %ld.", __PRETTY_FUNCTION__, (long) httpResponse.statusCode);
                        if (error) {
                            switch (error.code) {
                                case NSURLErrorTimedOut: {
                                    DDLogError(@"ERROR: %s Timeout: %@.", __PRETTY_FUNCTION__,
                                               [error localizedDescription]);
                                    // Request timed out, make sure you are connected
                                    break;
                                }
                                default: {
                                    DDLogError(@"ERROR: %s Message: %@.", __PRETTY_FUNCTION__, error);
                                    break;
                                }
                            }
                        }
                        completionHandler(NULL);
                        break;
                    }
                }
            }];

    [task resume];
}

- (NSError *)createError:(NSError *)error code:(NSUInteger)code description:(NSString *)description {
    NSError *newError;

    NSDictionary *userInfo = @{NSUnderlyingErrorKey : error, NSLocalizedDescriptionKey : description};
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
                        successBlock(responseObject);
                        break;
                    }
                    case NetworkingServiceCodeBadRequest: {
                        NSString *description = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                        DDLogError(@"ERROR: %s Bad Status: %ld Message: %@", __PRETTY_FUNCTION__, (long) httpResponse.statusCode, description);

                        NSError *serviceError = [self createError:error
                                                      code:NetworkingServiceCodeBadRequest
                                               description:@"An error occured with the service. Please try again later."];
                        failureBlock(serviceError);
                        break;
                    }
                    case NetworkingServiceCodeServiceUnavailable: {
                        NSError *serviceError = [self createError:error
                                                             code:NetworkingServiceCodeServiceUnavailable
                                                      description:@"The service is unavailable. Please try again later."];
                        failureBlock(serviceError);
                        break;
                    }
                    default: {
                        DDLogWarn(@"WARN: %s Bad Status: %ld.", __PRETTY_FUNCTION__, (long) httpResponse.statusCode);
                        if (error) {
                            switch (error.code) {
                                case NSURLErrorTimedOut: {
                                    DDLogError(@"ERROR: %s Timeout: %@.", __PRETTY_FUNCTION__, [error localizedDescription]);
                                    NSError *serviceError = [self createError:error
                                                                         code:NSURLErrorTimedOut
                                                                  description:@"Request timed out. Please make sure you are connected to the internet."];
                                    failureBlock(serviceError);
                                    break;
                                }
                                default: {
                                    DDLogError(@"ERROR: %s Message: %@.", __PRETTY_FUNCTION__, error);
                                    break;
                                }
                            }
                        }

                        NSError *serviceError = [self createError:error
                                                             code:NetworkingServiceCodeUnknown
                                                      description:@"Something has gone wrong. Please try again later."];
                        failureBlock(serviceError);
                        break;
                    }
                }
            }];

    [task resume];
}

- (void)postDataWithURI:(NSString *)uri
         withParameters:(NSDictionary *)parameters
           successBlock:(void (^)(id response))successBlock
           failureBlock:(void (^)(NSError *error))failureBlock {

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