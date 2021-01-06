//
//  Nomination.h
//  Congress
//
//  Created by ERIC on 8/9/16.
//  Copyright © 2016 Eric Panchenko. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Nomination : NSObject

@property (nonatomic, strong) NSString *nomination_id;
@property (nonatomic, strong) NSString *latest_action_date;
@property (nonatomic, strong) NSString *date_received;
@property (nonatomic, strong) NSString *nominee_description;
@property (nonatomic, strong) NSString *committee_id;
@property (nonatomic, strong) NSString *congress;
@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSArray *actions;

@end
