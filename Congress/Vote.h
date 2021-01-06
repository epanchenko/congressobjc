//
//  Vote.h
//  Congress
//
//  Created by Eric Panchenko on 5/22/16.
//  Copyright © 2016 Eric Panchenko. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Vote : NSObject

@property (strong, nonatomic) NSString* question;
@property (strong, nonatomic) NSString* result;
@property (strong, nonatomic) NSString* roll_id;
@property (strong, nonatomic) NSString* bill_id;
@property (strong, nonatomic) NSString* bill_title;
@property (strong, nonatomic) NSString* voted_at;
@property (strong, nonatomic) NSString* voteCast;
@property (strong, nonatomic) NSString* nomination_id;
@property (strong, nonatomic) NSString* source;
@property (strong, nonatomic) NSString* chamber;
@property (strong, nonatomic) NSString* democraticVotes;
@property (strong, nonatomic) NSString* republicanVotes;
@property (strong, nonatomic) NSString* independentVotes;
@property (strong, nonatomic) NSString* totalVotes;
@property (strong, nonatomic) NSArray* individualVotes;

@end
