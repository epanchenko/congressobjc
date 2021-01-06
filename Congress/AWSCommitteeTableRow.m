//
//  AWSCommitteeTableRow.m
//  Congress
//
//  Created by Eric Panchenko on 8/5/17.
//  Copyright © 2017 Eric Panchenko. All rights reserved.
//

#import "AWSCommitteeTableRow.h"

@implementation AWSCommitteeTableRow

+ (NSString *)dynamoDBTableName {
    return @"Committee";
}

+ (NSString *)hashKeyAttribute {
    return @"committee_id";
}

+ (NSArray *)ignoreAttributes {
    return @[@"internalName",@"internalState"];
}

@end
