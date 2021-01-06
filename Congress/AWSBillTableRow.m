//
//  AWSBillTableRow.m
//  Congress
//
//  Created by Eric Panchenko on 8/20/17.
//  Copyright © 2017 Eric Panchenko. All rights reserved.
//

#import "AWSBillTableRow.h"

@implementation AWSBillTableRow

+ (NSString *)dynamoDBTableName {
    return @"Bill";
}

+ (NSString *)hashKeyAttribute {
    return @"bill_id";
}

+ (NSArray *)ignoreAttributes {
    return @[@"internalName",@"internalState"];
}
@end
