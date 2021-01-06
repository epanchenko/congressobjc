//
//  UIViewController+PartialDictionary.m
//  Congress
//
//  Created by Eric Panchenko on 9/6/15.
//  Copyright (c) 2015 Eric Panchenko. All rights reserved.
//

#import "UIViewController+PartialDictionary.h"
#import "Legislator.h"

@implementation UIViewController (PartialDictionary)

- (NSDictionary *)partialIndexOfLastNameInitialFromLegislators:(NSArray *)legislators {
    
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    NSArray *value;
    NSString *key;
    
    for (Legislator *legislator in legislators) {
        key = [legislator.last_name substringToIndex:1];
        value = result[key];
        
        if (value == nil) {
            result[key] = [NSArray arrayWithObject:legislator]; // Create new array
        } else {
            result[key] = [value arrayByAddingObject:legislator]; // Add to existing
        }
    }
    
    return [result copy]; // NSMutableDictionary * to NSDictionary *
}

@end
