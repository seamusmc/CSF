//
// Created by Seamus McGowan on 3/19/14.
// Copyright (c) 2014 Seamus McGowan. All rights reserved.
//

// URI's for the FOE web service.
#define BaseURI @"http://www.ohiorawmilk.info/mobileoerest/RestService.svc/foe/"

NSString *const kGetItemTypesURI = BaseURI "itemtypes/?farm=%@";
NSString *const kGetItemsURI = BaseURI "items/?farm=%@&type=%@";
NSString *const kAuthenticationURI = BaseURI "authenticate/?farm=%@&firstName=%@&lastName=%@&password=%@";
NSString *const kGetOrderByUserURI = BaseURI "ordersbyuser/?farm=%@&group=%@&firstName=%@&lastName=%@&orderdate=%@";
NSString *const kUpdateOrderURI = BaseURI "updateorderitem/?farm=%@&group=%@&firstName=%@&lastName=%@&orderdate=%@&item=%@&qty=%@&comment=%@&removeItem=%@";
NSString *const kGetPreviousOrderURI = BaseURI "previousorders/?farm=%@&group=%@&firstName=%@&lastName=%@&orderdate=%@";