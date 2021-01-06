//
//  Amendment.h
//  Congress
//
//  Created by Eric Panchenko on 6/11/17.
//  Copyright © 2017 Eric Panchenko. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Amendment : NSObject

@property (nonatomic, strong) NSNumber* number;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *introduced_date;
@property (nonatomic, strong) NSString *sponsor;
@property (nonatomic, strong) NSString *latestAction;
@property (nonatomic, strong) NSString *latestActionDate;
@property (nonatomic, strong) NSString *url;

@end
