//
//  AWSLegislatorTableRow.m
//  Congress
//
//  Created by Eric Panchenko on 7/30/17.
//  Copyright © 2017 Eric Panchenko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AWSDynamoDB/AWSDynamoDB.h>

@interface AWSLegislatorTableRow : AWSDynamoDBObjectModel <AWSDynamoDBModeling>

@property (nonatomic, strong) NSString *bioguide_id;
@property (nonatomic, strong) NSString *date_of_birth;
@property (nonatomic, strong) NSString *facebook_account;
@property (nonatomic, strong) NSString *youtube_account;
@property (nonatomic, strong) NSString *twitter_account;
@property (nonatomic, strong) NSString *fax;
@property (nonatomic, strong) NSString *first_name;
@property (nonatomic, strong) NSString *middle_name;
@property (nonatomic, strong) NSString *last_name;
@property (nonatomic, strong) NSString *next_election;
@property (nonatomic, strong) NSString *district;
@property (nonatomic, strong) NSString *office;
@property (nonatomic, strong) NSString *party;
@property (nonatomic, strong) NSString *phone;
@property (nonatomic, strong) NSString *state;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *chamber;
@property (nonatomic, strong) NSSet *committees;
@property (nonatomic, strong) NSSet *terms;

//Those properties should be ignored according to ignoreAttributes
@property (nonatomic, strong) NSString *internalName;
@property (nonatomic, strong) NSNumber *internalState;

@end
