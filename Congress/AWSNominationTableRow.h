//
//  AWSNominationTableRow.h
//  Congress
//
//  Created by Eric Panchenko on 9/22/17.
//  Copyright © 2017 Eric Panchenko. All rights reserved.
//

#import <AWSDynamoDB/AWSDynamoDB.h>

@interface AWSNominationTableRow : AWSDynamoDBObjectModel

@property (nonatomic, strong) NSString *nomination_id;
@property (nonatomic, strong) NSString *latest_action_date;
@property (nonatomic, strong) NSString *date_received;
@property (nonatomic, strong) NSData *nominee_description;
@property (nonatomic, strong) NSString *committee_id;
@property (nonatomic, strong) NSString *congress;
@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSSet *actions;

//Those properties should be ignored according to ignoreAttributes
@property (nonatomic, strong) NSString *internalName;
@property (nonatomic, strong) NSNumber *internalState;

@end
