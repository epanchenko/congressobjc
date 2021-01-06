//
//  RollCall.m
//  Congress
//
//  Created by ERIC on 7/10/16.
//  Copyright © 2016 Eric Panchenko. All rights reserved.
//

#import "RollCall.h"

@implementation RollCall

- (NSComparisonResult)rollCallCompare:(RollCall *)otherObject {
    
    NSArray *fields1 = [self.name componentsSeparatedByString:@" "];
    NSArray *fields2 = [otherObject.name componentsSeparatedByString:@" "];
    
    NSString *lastName1 = @"", *lastName2 = @"", *firstName1 = @"", *firstName2 = @"";
    
    if ([fields1 count] > 0)
        lastName1 = fields1[0];
    if ([fields2 count] > 0)
        lastName2 = fields2[0];
    
    if ([lastName1 isEqualToString:lastName2]) {
        if ([fields1 count] > 1)
            firstName1 = fields1[1];
        if ([fields2 count] > 1)
            firstName2 = fields2[1];
        
        return [firstName1 compare:firstName2];
    }
        
    return [lastName1 compare:lastName2];
}
@end
