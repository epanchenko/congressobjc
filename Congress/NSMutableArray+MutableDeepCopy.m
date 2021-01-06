//
//  NSMutableArray+MutableDeepCopy.m
//  Congress
//
//  Created by Eric Panchenko on 6/5/17.
//  Copyright © 2017 Eric Panchenko. All rights reserved.
//

#import "NSMutableArray+MutableDeepCopy.h"

@implementation NSMutableArray (MutableDeepCopy)

- (NSMutableArray *)mutableDeepCopy
{
    NSMutableArray *returnArray = [[NSMutableArray alloc] initWithCapacity:self.count];
    
    for(id oneValue in self) {
        id oneCopy = nil;
        
        if([oneValue respondsToSelector:@selector(mutableDeepCopy)]) {
            oneCopy = [oneValue mutableDeepCopy];
        } else if([oneValue conformsToProtocol:@protocol(NSMutableCopying)]) {
            oneCopy = [oneValue mutableCopy];
        } else if([oneValue conformsToProtocol:@protocol(NSCopying)]){
            oneCopy = [oneValue copy];
        } else {
            oneCopy = oneValue;
        }
        
        [returnArray addObject:oneCopy];
    }
    
    return returnArray;
}
@end
