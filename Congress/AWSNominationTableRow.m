//
//  AWSNominationTableRow.m
//  Congress
//
//  Created by Eric Panchenko on 9/22/17.
//  Copyright © 2017 Eric Panchenko. All rights reserved.
//

#import "AWSNominationTableRow.h"

@implementation AWSNominationTableRow

+ (NSString *)dynamoDBTableName {
    return @"Nomination";
}

+ (NSString *)hashKeyAttribute {
    return @"nomination_id";
}

+ (NSArray *)ignoreAttributes {
    return @[@"internalName",@"internalState"];
}

@end
