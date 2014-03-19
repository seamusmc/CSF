//
// Created by Seamus McGowan on 3/19/14.
// Copyright (c) 2014 Seamus McGowan. All rights reserved.
//

// URI's for the FOE web service.
#define BaseURI @"http://www.ohiorawmilk.info/mobileoerest/RestService.svc/foe/"

NSString *const GetItemTypesURI     = BaseURI "itemtypes/?farm=%@";
NSString *const GetItemsURI         = BaseURI "items/?farm=%@&type=%@";
NSString *const AuthenticationURI   = BaseURI "authenticate/?farm=%@&firstName=%@&lastName=%@&password=%@";
NSString *const GetOrderByUserURI   = BaseURI "ordersbyuser/?farm=%@&group=%@&firstName=%@&lastName=%@&orderdate=%@";
NSString *const UpdateOrderURI      = BaseURI "updateorderitem/?farm=%@&group=%@&firstName=%@&lastName=%@&orderdate=%@&item=%@&qty=%@&comment=%@&removeItem=%@";
NSString *const GetPreviousOrderURI = BaseURI "previousorders/?farm=%@&group=%@&firstName=%@&lastName=%@&orderdate=%@";