//
// Created by Seamus McGowan on 3/19/14.
// Copyright (c) 2014 Seamus McGowan. All rights reserved.
//

#import "FarmDataService.h"
#import "ServiceConstants.h"

@interface FarmDataService ()

// Declaring these properties, defined by FarmDatServiceProtocol,
// so that the ivar, getter and setter are generated
@property (nonatomic, strong) NSArray *farms;

@end

@implementation FarmDataService
{

}

- (id)init
{
    self = [super init];
    if (self)
    {
        _farms = @[@"FARM2U", @"HHAVEN", @"JUBILEE", @"YODER"];
    }

    return self;
}

+ (id <FarmDataServiceProtocol>)sharedInstance
{
    static FarmDataService *sharedInstance = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^
    {
        sharedInstance = [[FarmDataService alloc] init];
    });

    return sharedInstance;
}

- (void)getItemTypesForFarm:(NSString *)farm withCompletionHandler:(void (^)(NSArray *types))completionHandler
{
    NSString *uri = [NSString stringWithFormat:GetItemTypesURI, farm];
    uri = [uri stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:uri];

    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithURL:url
                                        completionHandler:^(NSData *data, NSURLResponse *response, NSError *error){
                                            if (data)
                                            {
                                                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                                                NSArray *types = [json objectForKey:@"Types"];

                                                completionHandler(types);
                                            }
                                        }];
    [task resume];
}

@end