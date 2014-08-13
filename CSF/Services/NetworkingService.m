//
// Created by Seamus McGowan on 3/20/14.
// Copyright (c) 2014 Seamus McGowan. All rights reserved.
//

#import "NetworkingService.h"
#import "GAIDictionaryBuilder.h"
#import "GAITracker.h"
#import "GAI.h"
#import "DDLogMacros.h"

static const double kNetworkingServiceTimeout = 5.0;

@interface NetworkingService ()

@property(nonatomic, strong, readonly) id <GAITracker> gaiTracker;

@end

@implementation NetworkingService

- (id <GAITracker>)gaiTracker {
    return [GAI sharedInstance].defaultTracker;;
}

- (NSError *)createErrorWithCode:(NSUInteger)code description:(NSString *)description {
    NSError *newError;

    NSDictionary *userInfo = @{NSLocalizedDescriptionKey : description};
    newError = [[NSError alloc] initWithDomain:kNetworkingServiceDomain code:code userInfo:userInfo];
    return newError;
}

- (void)postDataWithURLString:(NSString *)uri successBlock:(void (^)(id response))successBlock failureBlock:(void (^)(NSError *error))failureBlock {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];

    uri = [uri stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:uri];

    NSURLSession *session = [self createSession];

    __typeof(self) __weak weakSelf = self;
    NSURLSessionDataTask *task = [session dataTaskWithURL:url
                                            completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                                                [weakSelf handleResponse:successBlock failureBlock:failureBlock data:data response:response error:error];
                                            }];
    [task resume];
}

- (void)getDataWithURI:(NSString *)uri successBlock:(void (^)(id response))successBlock failureBlock:(void (^)(NSError *error))failureBlock {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];

    uri = [uri stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:uri];

    NSURLSession *session = [self createSession];

    __typeof(self) __weak weakSelf = self;
    NSURLSessionDataTask *task = [session dataTaskWithURL:url
                                        completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                                            [weakSelf handleResponse:successBlock failureBlock:failureBlock data:data response:response error:error];
                                        }];
    [task resume];
}

- (void)handleResponse:(void (^)(id))successBlock
          failureBlock:(void (^)(NSError *))failureBlock
                  data:(NSData *)data
              response:(NSURLResponse *)response
                 error:(NSError *)error {

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

            [self.gaiTracker send:[[GAIDictionaryBuilder createEventWithCategory:@"network"
                                                                          action:@"getData"
                                                                           label:@"bad request"
                                                                           value:@(httpResponse.statusCode)] build]];

            NSError *serviceError = [self createErrorWithCode:NetworkingServiceCodeBadRequest
                                                  description:@"Something has gone wrong"];
            failureBlock(serviceError);
            break;
        }
        case NetworkingServiceCodeServiceUnavailable: {
            DDLogWarn(@"WARN: %s Bad Status: %ld.", __PRETTY_FUNCTION__, (long) httpResponse.statusCode);

            [self.gaiTracker send:[[GAIDictionaryBuilder createEventWithCategory:@"network"
                                                                          action:@"getData"
                                                                           label:@"service unavailable"
                                                                           value:@(httpResponse.statusCode)] build]];

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
                        DDLogError(@"ERROR: %s Timeout: %@.", __PRETTY_FUNCTION__, [error localizedDescription]);

                        [self.gaiTracker send:[[GAIDictionaryBuilder createEventWithCategory:@"network"
                                                                                      action:@"getData"
                                                                                       label:@"timeout"
                                                                                       value:nil] build]];


                        NSError *serviceError = [self createErrorWithCode:NSURLErrorTimedOut description:@"Request timed out"];
                        failureBlock(serviceError);
                        break;
                    }
                    default: {
                        DDLogError(@"ERROR: %s Message: %@.", __PRETTY_FUNCTION__, error);

                        NSString *message = [NSString stringWithFormat:@"Error: %@", error];
                        [self.gaiTracker send:[[GAIDictionaryBuilder createEventWithCategory:@"network"
                                                                                      action:@"getData"
                                                                                       label:message
                                                                                       value:nil] build]];

                        NSError *serviceError = [self createErrorWithCode:NetworkingServiceCodeUnknown description:@"Something has gone wrong"];
                        failureBlock(serviceError);
                        break;
                    }
                }
            } else {
                DDLogError(@"ERROR: %s Message: %@.", __PRETTY_FUNCTION__, error);

                NSString *message = [NSString stringWithFormat:@"Error: %@", error];
                [self.gaiTracker send:[[GAIDictionaryBuilder createEventWithCategory:@"network"
                                                                              action:@"getData"
                                                                               label:message
                                                                               value:nil] build]];

                NSError *serviceError = [self createErrorWithCode:NetworkingServiceCodeUnknown description:@"Something has gone wrong"];
                failureBlock(serviceError);
                break;
            }
        }
    }
}

- (NSURLSession *)createSession {
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    [sessionConfig setHTTPAdditionalHeaders:@{@"Accept" : @"application/json"}];
    sessionConfig.timeoutIntervalForRequest  = kNetworkingServiceTimeout;
    sessionConfig.timeoutIntervalForResource = kNetworkingServiceTimeout;

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