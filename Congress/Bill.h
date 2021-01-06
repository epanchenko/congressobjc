//
//  Bill.h
//  Congress
//
//  Created by ERIC on 7/23/16.
//  Copyright © 2016 Eric Panchenko. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Bill : NSObject

@property (nonatomic, strong) NSString *bill_id;
@property (nonatomic, strong) NSString *summary;
@property (nonatomic, strong) NSArray *committee_ids;
@property (nonatomic, strong) NSArray *actions;
@property (nonatomic, strong) NSArray *amendments;
@property (nonatomic, strong) NSString *congress;
@property (nonatomic, strong) NSString *introduced_date;
@property (nonatomic, strong) NSString *latest_major_action_date;
@property (nonatomic, strong) NSString *text_url;
@property (nonatomic, strong) NSString *official_title;

@end
