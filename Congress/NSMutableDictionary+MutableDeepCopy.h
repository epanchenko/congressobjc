//
//  NSMutableDictionary+MutableDeepCopy.h
//  Congress
//
//  Created by Eric Panchenko on 6/5/17.
//  Copyright © 2017 Eric Panchenko. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableDictionary (MutableDeepCopy)

- (NSMutableDictionary *) mutableDeepCopy;

@end
