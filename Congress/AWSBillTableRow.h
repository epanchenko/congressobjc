//
//  AWSBillTableRow.h
//  Congress
//
//  Created by Eric Panchenko on 8/20/17.
//  Copyright © 2017 Eric Panchenko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AWSDynamoDB/AWSDynamoDB.h>

@interface AWSBillTableRow : AWSDynamoDBObjectModel <AWSDynamoDBModeling>

@property (nonatomic, strong) NSString *bill_id;
@property (nonatomic, strong) NSData *summary;
@property (nonatomic, strong) NSString *congress;
@property (nonatomic, strong) NSString *introduced_date;
@property (nonatomic, strong) NSString *latest_major_action_date;
@property (nonatomic, strong) NSString *text_url;
@property (nonatomic, strong) NSString *bill_title;

@property (nonatomic, strong) NSSet *committeeIDs;
@property (nonatomic, strong) NSSet *actions;
@property (nonatomic, strong) NSSet *amendments;

//Those properties should be ignored according to ignoreAttributes
@property (nonatomic, strong) NSString *internalName;
@property (nonatomic, strong) NSNumber *internalState;

@end
