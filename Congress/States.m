//
//  States.m
//  Congress
//
//  Created by Eric Panchenko on 7/3/17.
//  Copyright © 2017 Eric Panchenko. All rights reserved.
//

#import "States.h"

@implementation States

+ (States*)sharedInstance {
    
    static States *_sharedInstance;
    if(!_sharedInstance) {
        static dispatch_once_t oncePredicate;
        dispatch_once(&oncePredicate, ^{
            _sharedInstance = [[super allocWithZone:nil] init];
        });
    }
    
    return _sharedInstance;
}

- (id)init
{
    self = [super init];
    if (self != nil)
    {
        _terrDict = @{@"AS":@"American Samoa",
                      @"DC":@"District of Columbia",
                      @"FM":@"Federated States of Micronesia",
                      @"GU":@"Guam",
                      @"MH":@"Marshall Islands",
                      @"MP":@"Northern Mariana Islands",
                      @"PW":@"Palau",
                      @"PR":@"Puerto Rico",
                      @"VI":@"U.S. Virgin Islands"
                      };
        
        _stateDict = @{@"AL":@"Alabama",
                      @"AK":@"Alaska",
                      @"AS":@"American Samoa",
                      @"AZ":@"Arizona",
                      @"AR":@"Arkansas",
                      @"CA":@"California",
                      @"CO":@"Colorado",
                      @"CT":@"Connecticut",
                      @"DC":@"District of Columbia",
                      @"DE":@"Delaware",
                      @"FL":@"Florida",
                      @"FM":@"Federated States of Micronesia",
                      @"GA":@"Georgia",
                      @"GU":@"Guam",
                      @"HI":@"Hawaii",
                      @"ID":@"Idaho",
                      @"IL":@"Illinois",
                      @"IN":@"Indiana",
                      @"IA":@"Iowa",
                      @"KS":@"Kansas",
                      @"KY":@"Kentucky",
                      @"LA":@"Louisiana",
                      @"ME":@"Maine",
                      @"MD":@"Maryland",
                      @"MA":@"Massachusetts",
                      @"MH":@"Marshall Islands",
                      @"MI":@"Michigan",
                      @"MN":@"Minnesota",
                      @"MS":@"Mississippi",
                      @"MO":@"Missouri",
                      @"MP":@"Northern Mariana Islands",
                      @"MT":@"Montana",
                      @"NE":@"Nebraska",
                      @"NV":@"Nevada",
                      @"NH":@"New Hampshire",
                      @"NJ":@"New Jersey",
                      @"NM":@"New Mexico",
                      @"NY":@"New York",
                      @"NC":@"North Carolina",
                      @"ND":@"North Dakota",
                      @"OH":@"Ohio",
                      @"OK":@"Oklahoma",
                      @"OR":@"Oregon",
                      @"PA":@"Pennsylvania",
                      @"PR":@"Puerto Rico",
                      @"PW":@"Palau",
                      @"RI":@"Rhode Island",
                      @"SC":@"South Carolina",
                      @"SD":@"South Dakota",
                      @"TN":@"Tennessee",
                      @"TX":@"Texas",
                      @"UT":@"Utah",
                      @"VI":@"U.S. Virgin Islands",
                      @"VT":@"Vermont",
                      @"VA":@"Virginia",
                      @"WA":@"Washington",
                      @"WV":@"West Virginia",
                      @"WI":@"Wisconsin",
                      @"WY":@"Wyoming"};
    }
    return self;
}

@end
