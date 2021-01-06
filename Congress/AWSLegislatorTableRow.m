//
//  AWSLegislatorTableRow.m
//  Congress
//
//  Created by Eric Panchenko on 7/30/17.
//  Copyright © 2017 Eric Panchenko. All rights reserved.
//

#import "AWSLegislatorTableRow.h"

@implementation AWSLegislatorTableRow

+ (NSString *)dynamoDBTableName {
    return @"Legislator";
}

+ (NSString *)hashKeyAttribute {
    return @"bioguide_id";
}

+ (NSArray *)ignoreAttributes {
    return @[@"internalName",@"internalState"];
}

@end
