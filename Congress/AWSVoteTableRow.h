//
//  AWSVoteTableRow.h
//  Congress
//
//  Created by Eric Panchenko on 8/11/17.
//  Copyright © 2017 Eric Panchenko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AWSDynamoDB/AWSDynamoDB.h>

@interface AWSVoteTableRow : AWSDynamoDBObjectModel <AWSDynamoDBModeling>

@property (nonatomic, strong) NSString *roll_id;
@property (nonatomic, strong) NSString *bill_id;
@property (nonatomic, strong) NSString *nomination_id;
@property (nonatomic, strong) NSString *question;
@property (nonatomic, strong) NSString *bill_title;
@property (nonatomic, strong) NSString *result;
@property (nonatomic, strong) NSString *voted_at;
@property (nonatomic, strong) NSString *source;
@property (nonatomic, strong) NSString *chamber;

@property (nonatomic, strong) NSString *republicanVotes;
@property (nonatomic, strong) NSString *democraticVotes;
@property (nonatomic, strong) NSString *independentVotes;
@property (nonatomic, strong) NSSet *individualVotes;

//Those properties should be ignored according to ignoreAttributes
@property (nonatomic, strong) NSString *internalName;
@property (nonatomic, strong) NSNumber *internalState;
@end
