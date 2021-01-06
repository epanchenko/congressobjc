//
//  RollCall.h
//  Congress
//
//  Created by ERIC on 7/10/16.
//  Copyright © 2016 Eric Panchenko. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RollCall : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *stateLabel;
@property (nonatomic, strong) NSString *vote;
@property (nonatomic, strong) NSString *district;
@property (nonatomic, strong) NSString *party;
@property (nonatomic, strong) NSString *bioguide_id;

- (NSComparisonResult)rollCallCompare:(RollCall *)otherObject;

@end
