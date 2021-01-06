//
//  NSMutableDictionary+MutableDeepCopy.m
//  Congress
//
//  Created by Eric Panchenko on 6/5/17.
//  Copyright © 2017 Eric Panchenko. All rights reserved.
//

#import "NSMutableDictionary+MutableDeepCopy.h"

@implementation NSMutableDictionary (MutableDeepCopy)

- (NSMutableDictionary *) mutableDeepCopy {
    NSMutableDictionary * returnDict = [[NSMutableDictionary alloc] initWithCapacity:self.count];
    NSArray * keys = [self allKeys];
    
    for(id key in keys) {
        id oneValue = [self objectForKey:key];
        id oneCopy = nil;
        
        if([oneValue respondsToSelector:@selector(mutableDeepCopy)]) {
            oneCopy = [oneValue mutableDeepCopy];
        }
        else if([oneValue conformsToProtocol:@protocol(NSMutableCopying)]) {
            oneCopy = [oneValue mutableCopy];
        }
        else if([oneValue conformsToProtocol:@protocol(NSCopying)]){
            oneCopy = [oneValue copy];
        }
        else {
            oneCopy = oneValue;
        }
        [returnDict setValue:oneCopy forKey:key];
    }
    
    return returnDict;
}

@end
