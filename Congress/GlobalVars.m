//
//  GlobalVars.m
//  Congress
//
//  Created by Eric Panchenko on 8/12/17.
//  Copyright © 2017 Eric Panchenko. All rights reserved.
//

#import "GlobalVars.h"

@implementation GlobalVars

+ (GlobalVars *)sharedInstance {
    static dispatch_once_t onceToken;
    static GlobalVars *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[GlobalVars alloc] init];
    });
    return instance;
}

- (void)clearVoteVars {
    _voteLastKey = [[NSDictionary alloc] init];
    _legislatorVoteLastKey = [[NSDictionary alloc] init];
    _billVoteLastKey = [[NSDictionary alloc] init];
    _nominationLastKey = [[NSDictionary alloc] init];
}

- (void)clearBillVars {
    _billLastKey = [[NSDictionary alloc] init];
}

- (void)clearNominationVars {
    _nominationLastKey = [[NSDictionary alloc] init];
}

-(void)setLegislators:(NSArray*)legislators {
    _legislators = legislators;
}

- (id)init {
    self = [super init];
    if (self) {
        _voteLastKey = [[NSDictionary alloc] init];
        _legislatorVoteLastKey = [[NSDictionary alloc] init];
        _billVoteLastKey = [[NSDictionary alloc] init];
        _billLastKey = [[NSDictionary alloc] init];
        _nominationLastKey = [[NSDictionary alloc] init];
        _legislators = [[NSArray alloc] init];
    }
    
    return self;
}

@end
