//
//  AWSVoteTableRow.m
//  Congress
//
//  Created by Eric Panchenko on 8/11/17.
//  Copyright © 2017 Eric Panchenko. All rights reserved.
//

#import "AWSVoteTableRow.h"

@implementation AWSVoteTableRow

+ (NSString *)dynamoDBTableName {
    return @"Vote";
}

+ (NSString *)hashKeyAttribute {
    return @"roll_id";
}

+ (NSArray *)ignoreAttributes {
    return @[@"internalName",@"internalState"];
}

@end
