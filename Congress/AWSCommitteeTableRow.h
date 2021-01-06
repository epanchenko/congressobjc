//
//  AWSCommitteeTableRow.h
//  Congress
//
//  Created by Eric Panchenko on 8/5/17.
//  Copyright © 2017 Eric Panchenko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AWSDynamoDB/AWSDynamoDB.h>

@interface AWSCommitteeTableRow : AWSDynamoDBObjectModel <AWSDynamoDBModeling>

@property (nonatomic, strong) NSString *committee_id;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *subcommittee;

@property (nonatomic, strong) NSSet *subcommittees;
@property (nonatomic, strong) NSSet *currentMembers;

//Those properties should be ignored according to ignoreAttributes
@property (nonatomic, strong) NSString *internalName;
@property (nonatomic, strong) NSNumber *internalState;
@end
