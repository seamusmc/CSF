//
//  TweaksService.h
//  Charge
//
//  Created by Seamus McGowan on 6/16/14.
//  Copyright (c) 2014 Clover. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TweaksServiceProtocol.h"

@interface TweaksService : NSObject <TweaksServiceProtocol>

+ (id<TweaksServiceProtocol>)sharedInstance;

@end
