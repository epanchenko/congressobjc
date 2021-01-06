//
//  Committee.h
//  Congress
//
//  Created by ERIC on 9/26/15.
//  Copyright © 2015 Eric Panchenko. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Committee : NSObject

@property (nonatomic,strong) NSString *name;
@property (nonatomic,strong) NSString *committee_id;
@property (nonatomic,strong) NSString *url;
@property (nonatomic,strong) NSString *subcommittee;
@property (nonatomic,strong) NSArray *currentMembers;
@property (nonatomic,strong) NSArray *subcommittees;

@end
