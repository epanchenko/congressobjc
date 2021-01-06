//
//  DataManager.h
//  Congress
//
//  Created by Eric Panchenko on 8/5/17.
//  Copyright © 2017 Eric Panchenko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AWSDynamoDB/AWSDynamoDB.h>
#import "AWSBillTableRow.h"
#import "AWSCommitteeTableRow.h"
#import "AWSLegislatorTableRow.h"
#import "AWSNominationTableRow.h"
#import "AWSVoteTableRow.h"
#import "TVCMethods.h"
#import "Legislator.h"
#import "Term.h"
#import "RealmFunctions.h"
#import "Committee.h"
#import "RealmString.h"
#import "Vote.h"
#import "GlobalVars.h"
#import "NSData+GZIP.h"
#import "Bill.h"
#import "Amendment.h"
#import "Nomination.h"

@interface DataManager : NSObject

+(void)fetchBillID:(NSString*)bill_id block:(void(^)(Bill* bill, NSError *error))handler;
+(void)fetchBills:(void(^)(NSArray *scanResult, NSError *error))handler;
+(void)fetchCommittees:(NSArray*)committees all:(BOOL)allMode block:(void(^)(NSArray *scanResult, NSError *error))handler;
+(void)fetchLegislators:(NSArray*)legislators all:(BOOL)allMode chamber:(NSString*)chamber block:(void(^)(NSArray *scanResult, NSError *error))handler;
+(void)fetchLegislatorVotesChamber:(NSString*)chamber legislatorID:(NSString*)legislatorID block:(void(^)(NSArray *scanResult, NSError *error))handler;
+(void)fetchNominationID:(NSString*)nomination_id block:(void(^)(Nomination* nomination, NSError *error))handler;
+(void)fetchNominations:(void(^)(NSArray *scanResult, NSError *error))handler;
+(void)fetchVotes:(void(^)(NSArray *scanResult, NSError *error))handler;
+(void)fetchVotesForBillID:(NSString*)bill_id block:(void(^)(NSArray *scanResult, NSError *error))handler;
+(void)fetchVotesForNominationID:(NSString*)nomination_id block:(void(^)(NSArray *scanResult, NSError *error))handler;
+(void)votesExistForBillID:(NSString*)bill_id block:(void(^)(BOOL votesExist))handler;
+(void)votesExistForNominationID:(NSString*)nomination_id block:(void(^)(BOOL votesExist))handler;
@end
