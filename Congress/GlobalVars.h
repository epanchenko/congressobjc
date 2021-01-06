//
//  GlobalVars.h
//  Congress
//
//  Created by Eric Panchenko on 8/12/17.
//  Copyright © 2017 Eric Panchenko. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GlobalVars : NSObject

+(GlobalVars *)sharedInstance;
-(void)clearVoteVars;
-(void)clearBillVars;
-(void)clearNominationVars;
-(void)setLegislators:(NSArray*)legislators;

@property(strong, nonatomic, readwrite) NSDictionary *voteLastKey;
@property(strong, nonatomic, readwrite) NSDictionary *legislatorVoteLastKey;
@property(strong, nonatomic, readwrite) NSDictionary *billVoteLastKey;
@property(strong, nonatomic, readwrite) NSDictionary *billLastKey;
@property(strong, nonatomic, readwrite) NSDictionary *nominationLastKey;
@property(strong, nonatomic, readonly) NSArray *legislators;

@end
