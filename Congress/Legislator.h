//
//  Legislator.h
//  Congress
//
//  Created by Eric Panchenko on 8/29/15.
//  Copyright (c) 2015 Eric Panchenko. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Legislator : NSObject

@property (strong, nonatomic) NSString* first_name;
@property (strong, nonatomic) NSString* middle_name;
@property (strong, nonatomic) NSString* last_name;
@property (strong, nonatomic) NSString* bioguide_id;
@property (strong, nonatomic) NSString* date_of_birth;
@property (strong, nonatomic) NSString* phone;
@property (strong, nonatomic) NSString* url;
@property (strong, nonatomic) NSString* office;
@property (strong, nonatomic) NSString* fax;
@property (strong, nonatomic) NSString* twitter_account;
@property (strong, nonatomic) NSString* youtube_account;
@property (strong, nonatomic) NSString* facebook_account;
@property (strong, nonatomic) NSString* state;
@property (strong, nonatomic) NSString* state_name;
@property (strong, nonatomic) NSString* district;
@property (strong, nonatomic) NSString* party;
@property (strong, nonatomic) NSString* chamber;
@property (strong, nonatomic) NSString* next_election;
@property (strong, nonatomic) NSString* title;
@property (strong, nonatomic) NSArray* terms;
@property (strong, nonatomic) NSArray* committees;

@end
