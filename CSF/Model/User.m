//
// Created by Seamus McGowan on 3/20/14.
// Copyright (c) 2014 Seamus McGowan. All rights reserved.
//

#import "User.h"

@implementation User

- (instancetype)initWithFirstname:(NSString *)firstname lastname:(NSString *)lastname group:(NSString *)group farm:(NSString *)farm
{
    self = [super init];
    if (self)
    {
        _firstname = firstname;
        _lastname  = lastname;
        _group = group;
        _farm = farm;
    }

    return self;
}

- (NSString *)description
{
    NSMutableString *description = [NSMutableString stringWithFormat:@"<%@: Firstname: %@ Lastname: %@ Group: %@ Farm: %@",
                                                    NSStringFromClass([self class]),
                                                    self.firstname,
                                                    self.lastname,
                                                    self.group,
                                                    self.farm];
    [description appendString:@">"];
    return description;
}

@end