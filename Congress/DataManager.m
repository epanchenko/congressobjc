//
//  DataManager.m
//  Congress
//
//  Created by Eric Panchenko on 8/5/17.
//  Copyright © 2017 Eric Panchenko. All rights reserved.
//

#import "DataManager.h"

@implementation DataManager

+(void)fetchBillID:(NSString*)bill_id block:(void(^)(Bill* bill, NSError *error))handler {
    
    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    AWSDynamoDBQueryExpression *queryExpression = [AWSDynamoDBQueryExpression new];
    
    queryExpression.keyConditionExpression = @"bill_id = :bill_id";
    queryExpression.expressionAttributeValues = @{@":bill_id":bill_id};
    queryExpression.limit = @1;
    
    [[dynamoDBObjectMapper query:[AWSBillTableRow class]
                      expression:queryExpression]
     continueWithBlock:^id(AWSTask *task) {
         
         if (task.error) {
             if (handler != nil) {
                 handler(nil,task.error);
             }
         }
         else {
             AWSDynamoDBPaginatedOutput *paginatedOutput = task.result;
             
             Bill *bill = [[Bill alloc] init];
             NSMutableArray *actionsArray;
             NSMutableArray *amendmentsArray;
             NSArray *actionsArray2, *amendmentsArray2, *fields;
             Amendment *amendment;
             
             if ([paginatedOutput.items count] > 0) {
                 AWSBillTableRow *item = paginatedOutput.items[0];
                 
                 bill.bill_id = item.bill_id;
                 bill.summary = [[NSString alloc] initWithData:[item.summary gunzippedData] encoding:NSUTF8StringEncoding];
                 bill.congress = item.congress;
                 bill.introduced_date = item.introduced_date;
                 bill.latest_major_action_date = item.latest_major_action_date;
                 bill.text_url = item.text_url;
                 bill.official_title = [item.bill_title stringByReplacingOccurrencesOfString:@" \\" withString:@" "];
                 bill.official_title = [bill.official_title stringByReplacingOccurrencesOfString:@"\\ " withString:@""];
                 bill.official_title = [bill.official_title stringByReplacingOccurrencesOfString:@"\\." withString:@"."];
                 bill.committee_ids = [item.committeeIDs allObjects];
                 
                 actionsArray2 = [item.actions allObjects];
                 amendmentsArray2 = [item.amendments allObjects];
                 actionsArray = [[NSMutableArray alloc] init];
                 amendmentsArray = [[NSMutableArray alloc] init];
                 
                 for (int i = 0; i < [actionsArray2 count]; i++) {
                     [actionsArray addObject:[[NSString alloc] initWithData:[actionsArray2[i] gunzippedData] encoding:NSUTF8StringEncoding]];
                 }
                 
                 for (int i = 0; i < [amendmentsArray2 count]; i++) {
                     
                     amendment = [[Amendment alloc] init];
                     
                     fields = [[[NSString alloc] initWithData:[amendmentsArray2[i] gunzippedData] encoding:NSUTF8StringEncoding] componentsSeparatedByString:@"@"];
                     
                     amendment.number = fields[0];
                     amendment.introduced_date = fields[1];
                     amendment.title = fields[2];
                     amendment.url = fields[3];
                     amendment.latestActionDate = fields[4];
                     amendment.latestAction = fields[5];
                     amendment.sponsor = fields[6];
                     [amendmentsArray addObject:amendment];
                 }
                 
                 bill.actions = [actionsArray copy];
                 bill.amendments = [amendmentsArray copy];
                 
                 if (handler != nil) {
                     handler(bill,nil);
                 }
             }
             else if (handler != nil) {
                handler(nil,[[NSError alloc] initWithDomain:@"NotFound" code:1 userInfo:nil]);
             }
             
         }
         return nil;
     }];
}

+(void)fetchBills:(void(^)(NSArray *scanResult, NSError *error))handler {
    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    AWSDynamoDBQueryExpression *queryExpression = [AWSDynamoDBQueryExpression new];
    queryExpression.indexName = @"blank-latest_major_action_date-index";
    queryExpression.keyConditionExpression = @"blank = :blank";
    queryExpression.expressionAttributeValues = @{@":blank":@" "};
    queryExpression.scanIndexForward = @NO;
    queryExpression.limit = @20;
    
    GlobalVars *globals = [GlobalVars sharedInstance];
    
    if ([globals.billLastKey count] > 0) {
        queryExpression.exclusiveStartKey = globals.billLastKey;
    }
    
    [[dynamoDBObjectMapper query:[AWSBillTableRow class]
                      expression:queryExpression]
     continueWithBlock:^id(AWSTask *task) {
         
         if (task.error) {
             if (handler != nil) {
                 handler(nil,task.error);
             }
         }
         else {
             AWSDynamoDBPaginatedOutput *paginatedOutput = task.result;
             
             if ([paginatedOutput.items count] > 0) {
                 globals.billLastKey = paginatedOutput.lastEvaluatedKey;
             }
             
             Bill *bill;
             NSMutableArray *billsMutableArray = [[NSMutableArray alloc] init], *actionsArray, *amendmentsArray;
             NSArray *actionsArray2, *amendmentsArray2, *fields;
             Amendment *amendment;
             
             for (AWSBillTableRow *item in paginatedOutput.items) {
                 bill = [[Bill alloc] init];
                 
                 bill.bill_id = item.bill_id;
                 bill.summary = [[NSString alloc] initWithData:[item.summary gunzippedData] encoding:NSUTF8StringEncoding];
                 bill.congress = item.congress;
                 bill.introduced_date = item.introduced_date;
                 bill.latest_major_action_date = item.latest_major_action_date;
                 bill.text_url = item.text_url;
                 bill.official_title = [item.bill_title stringByReplacingOccurrencesOfString:@" \\" withString:@" "];
                 bill.official_title = [bill.official_title stringByReplacingOccurrencesOfString:@"\\ " withString:@""];
                 bill.official_title = [bill.official_title stringByReplacingOccurrencesOfString:@"\\." withString:@"."];
                 bill.committee_ids = [item.committeeIDs allObjects];
                 actionsArray2 = [item.actions allObjects];
                 amendmentsArray2 = [item.amendments allObjects];
                 actionsArray = [[NSMutableArray alloc] init];
                 amendmentsArray = [[NSMutableArray alloc] init];
                 
                 
                 for (int i = 0; i < [actionsArray2 count]; i++) {
                     [actionsArray addObject:[[NSString alloc] initWithData:[actionsArray2[i] gunzippedData] encoding:NSUTF8StringEncoding]];
                 }
                 
                 for (int i = 0; i < [amendmentsArray2 count]; i++) {
                     
                     amendment = [[Amendment alloc] init];
                     
                     fields = [[[NSString alloc] initWithData:[amendmentsArray2[i] gunzippedData] encoding:NSUTF8StringEncoding] componentsSeparatedByString:@"@"];
                     
                     amendment.number = fields[0];
                     amendment.introduced_date = fields[1];
                     amendment.title = fields[2];
                     amendment.url = fields[3];
                     amendment.latestActionDate = fields[4];
                     amendment.latestAction = fields[5];
                     amendment.sponsor = fields[6];
                     [amendmentsArray addObject:amendment];
                 }
                 
                 bill.actions = [actionsArray copy];
                 bill.amendments = [amendmentsArray copy];
                 
                 [billsMutableArray addObject:bill];
             }
             
             if (handler != nil && [billsMutableArray count] > 0) {
                 handler([billsMutableArray copy],nil);
             }
             else if (handler != nil) {
                 handler(nil,[[NSError alloc] initWithDomain:@"NotFound" code:1 userInfo:nil]);
             }
         }
         return nil;
     }];
}

+(void)fetchCommittees:(NSArray*)committees all:(BOOL)allMode block:(void(^)(NSArray *scanResult, NSError *error))handler {

    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    AWSDynamoDBScanExpression *scanExpression = [AWSDynamoDBScanExpression new];
    
    scanExpression.limit = @200; //my case committees table is not even 1 MB, get them all...
    
    NSMutableArray *committeesMutableArray = [[NSMutableArray alloc] init];
    
    [[dynamoDBObjectMapper scan:[AWSCommitteeTableRow class]
                     expression:scanExpression]
     continueWithBlock:^id(AWSTask *task) {
         
         if (task.error) {
             if (handler != nil) {
                handler(nil,task.error);
             }
         }
         else {
             AWSDynamoDBPaginatedOutput *paginatedOutput = task.result;
             NSArray *currentMembersArray;
             NSArray *subcommitteesArray;
             NSMutableArray *currentMembers2Array;
             NSMutableArray *subcommittees2Array;
             Committee *committee;
             
             for (AWSCommitteeTableRow *item in paginatedOutput.items) {
                 committee = [[Committee alloc] init];
                 committee.committee_id = item.committee_id;
                 committee.name = item.name;
                 committee.url = item.url;
                 committee.subcommittee = item.subcommittee;
                 
                 currentMembersArray = [item.currentMembers allObjects];
                 subcommitteesArray = [item.subcommittees allObjects];
                 
                 currentMembers2Array = [[NSMutableArray alloc] init];
                 subcommittees2Array = [[NSMutableArray alloc] init];
                 
                 for (int i = 0; i < [currentMembersArray count]; i++) {
                     [currentMembers2Array addObject:[currentMembersArray objectAtIndex:i]];
                 }
                 
                 for (int i = 0; i < [subcommitteesArray count]; i++) {
                     [subcommittees2Array addObject:[subcommitteesArray objectAtIndex:i]];
                 }
                 
                 committee.currentMembers = [currentMembers2Array copy];
                 committee.subcommittees = [subcommittees2Array copy];
                 
                 if (allMode) {
                     [committeesMutableArray addObject:committee];
                 }
                 else if ([committees containsObject:committee.committee_id]) {
                     [committeesMutableArray addObject:committee];
                 }
             }
             
             if (handler != nil && [committeesMutableArray count] > 0) {
                 handler([committeesMutableArray copy],nil);
             }
             else if (handler != nil) {
                 handler(nil,nil);
             }
         }
         
         return nil;

     }];
}

+(void)fetchLegislators:(NSArray*)legislators all:(BOOL)allMode chamber:(NSString*)chamber block:(void(^)(NSArray *scanResult, NSError *error))handler {
    
    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    AWSDynamoDBScanExpression *scanExpression = [AWSDynamoDBScanExpression new];
    
    scanExpression.limit = @1000;
    
    NSMutableArray *legislatorsMutableArray = [[NSMutableArray alloc] init];
    NSArray *filteredArray, *tempLegislators = [[GlobalVars sharedInstance] legislators];
    BOOL refresh = false;
    
    if (!allMode) {
        for (int i = 0; i < [legislators count]; i++) {
            filteredArray = [tempLegislators filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"bioguide_id == %@", legislators[i]]];
            
            if (filteredArray.count == 0) {
                legislatorsMutableArray = [[NSMutableArray alloc] init];
                refresh = YES;
                break;
            }
            else {
                [legislatorsMutableArray addObject:filteredArray[0]];
            }
        }
        
        if (!refresh) {
            if (handler != nil) {
                [[GlobalVars sharedInstance] setLegislators:legislatorsMutableArray];
                handler([legislatorsMutableArray copy],nil);
            }
        }
    }
    else refresh = YES;
    
    if (refresh)
    [[dynamoDBObjectMapper scan:[AWSLegislatorTableRow class]
                     expression:scanExpression]
     continueWithBlock:^id(AWSTask *task) {
         
         if (task.error) {
             if (handler != nil) {
                 handler(nil,task.error);
             }
         }
         else {
             AWSDynamoDBPaginatedOutput *paginatedOutput = task.result;
             
             Legislator *legislator;
             NSArray *termsArray, *committeesArray;
             NSMutableArray *terms2Array, *committees2Array;
             NSArray *fields;
             Term *term;
             
             NSSortDescriptor *valueDescriptor = [[NSSortDescriptor alloc] initWithKey:@"startDate" ascending:NO];
             NSArray *descriptors = [NSArray arrayWithObject:valueDescriptor];
             
             for (AWSLegislatorTableRow *item in paginatedOutput.items) {
                 
                 if (([chamber isEqualToString:@"All"] || [item.chamber caseInsensitiveCompare:chamber] == NSOrderedSame)) {
             
                     legislator = [[Legislator alloc] init];
                     legislator.bioguide_id = item.bioguide_id;
                     legislator.first_name = item.first_name;
                     legislator.middle_name = item.middle_name;
                     legislator.last_name = item.last_name;
                     legislator.district = item.district;
                     legislator.party = item.party;
                     legislator.state = item.state;
                     legislator.next_election = item.next_election;
                     legislator.twitter_account = item.twitter_account;
                     legislator.youtube_account = item.youtube_account;
                     legislator.facebook_account = item.facebook_account;
                     legislator.url = item.url;
                     legislator.office = item.office;
                     legislator.phone = item.phone;
                     legislator.state_name = [TVCMethods getStateName:legislator.state];
                     legislator.chamber = item.chamber;
                     legislator.fax = item.fax;
                     
                     termsArray = [item.terms allObjects];
                     committeesArray = [item.committees allObjects];
                     committees2Array = [[NSMutableArray alloc] init];
                     terms2Array = [[NSMutableArray alloc] init];
                     
                     for (int i = 0; i < [termsArray count]; i++) {
                         fields = [[termsArray objectAtIndex:i] componentsSeparatedByString:@"@"];
                         term = [[Term alloc] init];
                         term.startDate = fields[0];
                         term.endDate = fields[1];
                         term.title = fields[2];
                         [terms2Array addObject:term];
                     }
                     
                     for (int i = 0; i < [committeesArray count]; i++) {
                         [committees2Array addObject:committeesArray[i]];
                     }
                     
                     legislator.terms = [[terms2Array copy] sortedArrayUsingDescriptors:descriptors];
                     legislator.committees = [committees2Array copy];
                     
                     if ([legislator.chamber caseInsensitiveCompare:@"House"] == NSOrderedSame) {
                         legislator.title = [TVCMethods getTitle:legislator.state];
                     }
                     else {
                         legislator.title = @"Sen";
                     }
                     
                     if (allMode) {
                         [legislatorsMutableArray addObject:legislator];
                     }
                     else {
                         if ([legislators containsObject:legislator.bioguide_id]) {
                             [legislatorsMutableArray addObject:legislator];
                         }
                     }
                 }
             }
             
             if (handler != nil && [legislatorsMutableArray count] > 0) {
                 [[GlobalVars sharedInstance] setLegislators:legislatorsMutableArray];
                 handler([legislatorsMutableArray copy],nil);
             }
             else if (handler != nil) {
                 handler(nil,nil);
             }
         }
         return nil;
     }];
}

+(void)fetchLegislatorVotesChamber:(NSString*)chamber legislatorID:(NSString*)legislatorID block:(void(^)(NSArray *scanResult, NSError *error))handler {
    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    AWSDynamoDBQueryExpression *queryExpression = [AWSDynamoDBQueryExpression new];
    queryExpression.indexName = @"chamber-voted_at-index";
    queryExpression.keyConditionExpression = @"chamber = :chamber";
    queryExpression.expressionAttributeValues = @{@":chamber":[chamber lowercaseString]};
    queryExpression.scanIndexForward = @NO;
    queryExpression.limit = @20;
    
    GlobalVars *globals = [GlobalVars sharedInstance];
    
    if ([globals.legislatorVoteLastKey count] > 0) {
        queryExpression.exclusiveStartKey = globals.legislatorVoteLastKey;
    }
    
    [[dynamoDBObjectMapper query:[AWSVoteTableRow class]
                      expression:queryExpression]
     continueWithBlock:^id(AWSTask *task) {
         
         if (task.error) {
             
             if (handler != nil) {
                 handler(nil,task.error);
             }
         }
         else {
             AWSDynamoDBPaginatedOutput *paginatedOutput = task.result;
             
             if ([paginatedOutput.items count] > 0) {
                 globals.legislatorVoteLastKey = paginatedOutput.lastEvaluatedKey;
             }
             
             Vote *vote;
             NSMutableArray *votesMutableArray = [[NSMutableArray alloc] init];
             NSArray *fields;
             int voteYesCount, voteNoCount, votePresentCount, voteNotVotingCount;
             
             NSArray *indVotes;
             bool legislatorFound;
             NSString *voteCast;
             
             for (AWSVoteTableRow *item in paginatedOutput.items) {
                 
                 legislatorFound = NO;
                 
                 indVotes = [item.individualVotes allObjects];
                 
                 for (NSString* string in indVotes) {
                     fields = [string componentsSeparatedByString:@"@"];
                     
                     if ([fields count] > 0 && [fields[0] isEqualToString:legislatorID]) {
                         legislatorFound = YES;

                         if ([fields[4] isEqualToString:@"Y"])
                             voteCast = @"Yea";
                         else if ([fields[4] isEqualToString:@"N"])
                             voteCast = @"Nay";
                         else if ([fields[4] isEqualToString:@"P"])
                             voteCast = @"Present";
                         else if ([fields[4] isEqualToString:@"X"])
                             voteCast = @"No Vote";
                         
                         break;
                     }
                 }

                 if (legislatorFound) {
                     vote = [[Vote alloc] init];
                     vote.individualVotes = [item.individualVotes allObjects];
                     vote.roll_id = item.roll_id;
                     vote.bill_id = item.bill_id;
                     vote.nomination_id = item.nomination_id;
                     vote.question = item.question;
                     vote.bill_title = item.bill_title;
                     vote.result = item.result;
                     vote.source = item.source;
                     vote.chamber = item.chamber;
                     vote.voted_at = [item.voted_at substringToIndex:10];
                     vote.republicanVotes = item.republicanVotes;
                     vote.democraticVotes = item.democraticVotes;
                     vote.independentVotes = item.independentVotes;
                     vote.voteCast = voteCast;
                     
                     voteYesCount = 0;
                     voteNoCount = 0;
                     votePresentCount = 0;
                     voteNotVotingCount = 0;
                     
                     fields = [vote.republicanVotes componentsSeparatedByString:@"@"];
                     
                     for (int i = 0; i < 4; i++) {
                         
                         switch (i) {
                             case 1:
                                 voteYesCount += [fields[i] intValue];
                                 break;
                             case 2:
                                 voteNoCount += [fields[i] intValue];
                                 break;
                             case 3:
                                 voteNotVotingCount += [fields[i] intValue];
                                 break;
                             case 4:
                                 votePresentCount += [fields[i] intValue];
                                 break;
                         }
                     }
                     
                     fields = [vote.democraticVotes componentsSeparatedByString:@"@"];
                     
                     for (int i = 0; i < 4; i++) {
                         
                         switch (i) {
                             case 1:
                                 voteYesCount += [fields[i] intValue];
                                 break;
                             case 2:
                                 voteNoCount += [fields[i] intValue];
                                 break;
                             case 3:
                                 voteNotVotingCount += [fields[i] intValue];
                                 break;
                             case 4:
                                 votePresentCount += [fields[i] intValue];
                                 break;
                         }
                     }
                     
                     
                     fields = [vote.independentVotes componentsSeparatedByString:@"@"];
                     
                     for (int i = 0; i < 4; i++) {
                         
                         switch (i) {
                             case 1:
                                 voteYesCount += [fields[i] intValue];
                                 break;
                             case 2:
                                 voteNoCount += [fields[i] intValue];
                                 break;
                             case 3:
                                 voteNotVotingCount += [fields[i] intValue];
                                 break;
                             case 4:
                                 votePresentCount += [fields[i] intValue];
                                 break;
                         }
                     }
                     
                     NSMutableString *totalString = [[NSMutableString alloc] init];
                     
                     for (int i = 0; i < 4; i++) {
                         switch (i) {
                             case 1:
                                 [totalString appendString:[NSString stringWithFormat:@"%d",voteYesCount]];
                                 [totalString appendString:@"@"];
                                 break;
                             case 2:
                                 [totalString appendString:[NSString stringWithFormat:@"%d",voteNoCount]];
                                 [totalString appendString:@"@"];
                                 break;
                             case 3:
                                 [totalString appendString:[NSString stringWithFormat:@"%d",voteNotVotingCount]];
                                 [totalString appendString:@"@"];
                                 break;
                             case 4:
                                 [totalString appendString:[NSString stringWithFormat:@"%d",votePresentCount]];
                                 break;
                         }
                     }
                     
                     vote.totalVotes = totalString;
                     
                     [votesMutableArray addObject:vote];
                 }
             }

             if (handler != nil && [votesMutableArray count] > 0) {
                 handler([votesMutableArray copy],nil);
             }
             else if (handler != nil) {
                 handler(nil,nil);
             }
             
         }
         return nil;
     }];
}

+(void)fetchNominationID:(NSString*)nomination_id block:(void(^)(Nomination* nomination, NSError *error))handler {
    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    AWSDynamoDBQueryExpression *queryExpression = [AWSDynamoDBQueryExpression new];
    
    queryExpression.keyConditionExpression = @"nomination_id = :nomination_id";
    queryExpression.expressionAttributeValues = @{@":nomination_id":nomination_id};
    queryExpression.limit = @1;
    
    [[dynamoDBObjectMapper query:[AWSNominationTableRow class]
                      expression:queryExpression]
     continueWithBlock:^id(AWSTask *task) {
         
         if (task.error) {
             if (handler != nil) {
                 handler(nil,task.error);
             }
         }
         else {
             AWSDynamoDBPaginatedOutput *paginatedOutput = task.result;
             
             Nomination *nomination = [[Nomination alloc] init];
             NSMutableArray *actionsArray;
             NSArray *actionsArray2;
             
             if ([paginatedOutput.items count] > 0) {
                 AWSNominationTableRow *item = paginatedOutput.items[0];
                 
                 nomination = [[Nomination alloc] init];
                 
                 nomination.nomination_id = item.nomination_id;
                 nomination.nominee_description = [[NSString alloc] initWithData:[item.nominee_description gunzippedData] encoding:NSUTF8StringEncoding];
                 nomination.date_received = item.date_received;
                 nomination.latest_action_date = item.latest_action_date;
                 nomination.committee_id = item.committee_id;
                 nomination.congress = item.congress;
                 nomination.status = item.status;
                 
                 actionsArray2 = [item.actions allObjects];
                 actionsArray = [[NSMutableArray alloc] init];
                 
                 for (int i = 0; i < [actionsArray2 count]; i++) {
                     [actionsArray addObject:[[NSString alloc] initWithData:[actionsArray2[i] gunzippedData] encoding:NSUTF8StringEncoding]];
                 }

                 nomination.actions = [actionsArray copy];
                 
                 if (handler != nil) {
                     handler(nomination,nil);
                 }
             }
             else if (handler != nil) {
                 handler(nil,nil);
             }
             
         }
         return nil;
     }];
}

+(void)fetchNominations:(void(^)(NSArray *scanResult, NSError *error))handler {
    
    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    AWSDynamoDBQueryExpression *queryExpression = [AWSDynamoDBQueryExpression new];
    queryExpression.indexName = @"blank-latest_action_date-index";
    queryExpression.keyConditionExpression = @"blank = :blank";
    queryExpression.expressionAttributeValues = @{@":blank":@" "};
    queryExpression.scanIndexForward = @NO;
    queryExpression.limit = @20;
    
    GlobalVars *globals = [GlobalVars sharedInstance];
    
    if ([globals.nominationLastKey count] > 0) {
        queryExpression.exclusiveStartKey = globals.nominationLastKey;
    }
    
    [[dynamoDBObjectMapper query:[AWSNominationTableRow class]
                      expression:queryExpression]
     continueWithBlock:^id(AWSTask *task) {
         
         if (task.error) {
             if (handler != nil) {
                 handler(nil,task.error);
             }
         }
         else {
             AWSDynamoDBPaginatedOutput *paginatedOutput = task.result;
             
             if ([paginatedOutput.items count] > 0) {
                 globals.nominationLastKey = paginatedOutput.lastEvaluatedKey;
             }
             
             Nomination *nomination;
             NSMutableArray *nominationsMutableArray = [[NSMutableArray alloc] init];
             NSMutableArray *actionsArray;
             NSArray *actionsArray2;
             
             for (AWSNominationTableRow *item in paginatedOutput.items) {
                 nomination = [[Nomination alloc] init];
                 
                 nomination.nomination_id = item.nomination_id;
                 nomination.nominee_description = [[NSString alloc] initWithData:[item.nominee_description gunzippedData] encoding:NSUTF8StringEncoding];
                 nomination.date_received = item.date_received;
                 nomination.latest_action_date = item.latest_action_date;
                 nomination.committee_id = item.committee_id;
                 nomination.congress = item.congress;
                 nomination.status = item.status;
                 
                 actionsArray2 = [item.actions allObjects];
                 actionsArray = [[NSMutableArray alloc] init];
                 
                 for (int i = 0; i < [actionsArray2 count]; i++) {
                     [actionsArray addObject:[[NSString alloc] initWithData:[actionsArray2[i] gunzippedData] encoding:NSUTF8StringEncoding]];
                 }
                 
                 nomination.actions = [actionsArray copy];
                 [nominationsMutableArray addObject:nomination];
             }
             
             if (handler != nil && [nominationsMutableArray count] > 0) {
                 handler([nominationsMutableArray copy],nil);
             }
             else if (handler != nil) {
                 handler(nil,nil);
             }
         }
         return nil;
     }];
}

+(void)fetchVotes:(void(^)(NSArray *scanResult, NSError *error))handler {
    
    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    AWSDynamoDBQueryExpression *queryExpression = [AWSDynamoDBQueryExpression new];
    queryExpression.indexName = @"blank-voted_at-index";
    queryExpression.keyConditionExpression = @"blank = :blank";
    queryExpression.expressionAttributeValues = @{@":blank":@" "};
    queryExpression.scanIndexForward = @NO;
    queryExpression.limit = @20;

    GlobalVars *globals = [GlobalVars sharedInstance];
        
    if ([globals.voteLastKey count] > 0) {
        queryExpression.exclusiveStartKey = globals.voteLastKey;
    }
    
    [[dynamoDBObjectMapper query:[AWSVoteTableRow class]
                     expression:queryExpression]
     continueWithBlock:^id(AWSTask *task) {
         
         if (task.error) {
             if (handler != nil) {
                 handler(nil,task.error);
             }
         }
         else {
             AWSDynamoDBPaginatedOutput *paginatedOutput = task.result;
             
             if ([paginatedOutput.items count] > 0) {
                 globals.voteLastKey = paginatedOutput.lastEvaluatedKey;
             }
             
             Vote *vote;
             NSMutableArray *votesMutableArray = [[NSMutableArray alloc] init];
             NSArray *fields;
             int voteYesCount, voteNoCount, votePresentCount, voteNotVotingCount;
             
             for (AWSVoteTableRow *item in paginatedOutput.items) {
                 vote = [[Vote alloc] init];
                 vote.roll_id = item.roll_id;
                 vote.bill_id = item.bill_id;
                 vote.nomination_id = item.nomination_id;
                 vote.question = item.question;
                 vote.bill_title = item.bill_title;
                 vote.result = item.result;
                 vote.source = item.source;
                 vote.chamber = item.chamber;
                 vote.voted_at = [item.voted_at substringToIndex:10];
                 vote.republicanVotes = item.republicanVotes;
                 vote.democraticVotes = item.democraticVotes;
                 vote.independentVotes = item.independentVotes;
                 vote.individualVotes = [item.individualVotes allObjects];
                 
                 voteYesCount = 0;
                 voteNoCount = 0;
                 votePresentCount = 0;
                 voteNotVotingCount = 0;

                 fields = [vote.republicanVotes componentsSeparatedByString:@"@"];
                 
                 for (int i = 0; i < 4; i++) {
                 
                     switch (i) {
                         case 1:
                             voteYesCount += [fields[i] intValue];
                             break;
                         case 2:
                             voteNoCount += [fields[i] intValue];
                             break;
                         case 3:
                             voteNotVotingCount += [fields[i] intValue];
                             break;
                         case 4:
                             votePresentCount += [fields[i] intValue];
                             break;
                     }
                 }
                 
                 fields = [vote.democraticVotes componentsSeparatedByString:@"@"];
                 
                 for (int i = 0; i < 4; i++) {
                     
                     switch (i) {
                         case 1:
                             voteYesCount += [fields[i] intValue];
                             break;
                         case 2:
                             voteNoCount += [fields[i] intValue];
                             break;
                         case 3:
                             voteNotVotingCount += [fields[i] intValue];
                             break;
                         case 4:
                             votePresentCount += [fields[i] intValue];
                             break;
                     }
                 }
                 

                 fields = [vote.independentVotes componentsSeparatedByString:@"@"];
                 
                 for (int i = 0; i < 4; i++) {
                     
                     switch (i) {
                         case 1:
                             voteYesCount += [fields[i] intValue];
                             break;
                         case 2:
                             voteNoCount += [fields[i] intValue];
                             break;
                         case 3:
                             voteNotVotingCount += [fields[i] intValue];
                             break;
                         case 4:
                             votePresentCount += [fields[i] intValue];
                             break;
                     }
                 }
                 
                 NSMutableString *totalString = [[NSMutableString alloc] init];
                 
                 for (int i = 0; i < 4; i++) {
                     switch (i) {
                         case 1:
                             [totalString appendString:[NSString stringWithFormat:@"%d",voteYesCount]];
                             [totalString appendString:@"@"];
                             break;
                         case 2:
                             [totalString appendString:[NSString stringWithFormat:@"%d",voteNoCount]];
                             [totalString appendString:@"@"];
                             break;
                         case 3:
                             [totalString appendString:[NSString stringWithFormat:@"%d",voteNotVotingCount]];
                             [totalString appendString:@"@"];
                             break;
                         case 4:
                             [totalString appendString:[NSString stringWithFormat:@"%d",votePresentCount]];
                             break;
                     }
                 }
                 
                 vote.totalVotes = totalString;
                 
                 [votesMutableArray addObject:vote];
             }
             
             if (handler != nil && [votesMutableArray count] > 0) {
                 handler([votesMutableArray copy],nil);
             }
             else if (handler != nil) {
                 handler(nil,nil);
             }
         }
         return nil;
     }];
}

+(void)votesExistForBillID:(NSString*)bill_id block:(void(^)(BOOL votesExist))handler {
    
    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    AWSDynamoDBQueryExpression *queryExpression = [AWSDynamoDBQueryExpression new];
    queryExpression.indexName = @"bill_id-voted_at-index";
    queryExpression.keyConditionExpression = @"bill_id = :bill_id";
    queryExpression.expressionAttributeValues = @{@":bill_id":bill_id};
    queryExpression.limit = @1;
    
    [[dynamoDBObjectMapper query:[AWSVoteTableRow class]
                      expression:queryExpression]
     continueWithBlock:^id(AWSTask *task) {
         
         BOOL returnValue = NO;
         
         if (!task.error) {
             AWSDynamoDBPaginatedOutput *paginatedOutput = task.result;
             
             if ([paginatedOutput.items count] > 0) {
                 returnValue = YES;
             }
         }
       
         if (handler != nil) {
             handler(returnValue);
         }
         return nil;
     }];
}

+(void)votesExistForNominationID:(NSString*)nomination_id block:(void(^)(BOOL votesExist))handler {
    
    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    AWSDynamoDBQueryExpression *queryExpression = [AWSDynamoDBQueryExpression new];
    queryExpression.indexName = @"nomination_id-voted_at-index";
    queryExpression.keyConditionExpression = @"nomination_id = :nomination_id";
    queryExpression.expressionAttributeValues = @{@":nomination_id":nomination_id};
    queryExpression.limit = @1;
    
    [[dynamoDBObjectMapper query:[AWSVoteTableRow class]
                      expression:queryExpression]
     continueWithBlock:^id(AWSTask *task) {
         
         BOOL returnValue = NO;
         
         if (!task.error) {
             AWSDynamoDBPaginatedOutput *paginatedOutput = task.result;
             
             if ([paginatedOutput.items count] > 0) {
                 returnValue = YES;
             }
         }
         
         if (handler != nil) {
             handler(returnValue);
         }
         return nil;
     }];
}

+(void)fetchVotesForBillID:(NSString*)bill_id block:(void(^)(NSArray *scanResult, NSError *error))handler {
    
    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    AWSDynamoDBQueryExpression *queryExpression = [AWSDynamoDBQueryExpression new];
    queryExpression.indexName = @"bill_id-voted_at-index";
    queryExpression.keyConditionExpression = @"bill_id = :bill_id";
    queryExpression.expressionAttributeValues = @{@":bill_id":bill_id};
    queryExpression.scanIndexForward = @NO;
    queryExpression.limit = @20;
    
    GlobalVars *globals = [GlobalVars sharedInstance];
    
    if ([globals.billVoteLastKey count] > 0) {
        queryExpression.exclusiveStartKey = globals.billVoteLastKey;
    }
    
    [[dynamoDBObjectMapper query:[AWSVoteTableRow class]
                      expression:queryExpression]
     continueWithBlock:^id(AWSTask *task) {
         
         if (task.error) {
             if (handler != nil) {
                 handler(nil,task.error);
             }
         }
         else {
             AWSDynamoDBPaginatedOutput *paginatedOutput = task.result;
             
             if ([paginatedOutput.items count] > 0) {
                 globals.billVoteLastKey = paginatedOutput.lastEvaluatedKey;
             }
             
             Vote *vote;
             NSMutableArray *votesMutableArray = [[NSMutableArray alloc] init];
             NSArray *fields;
             int voteYesCount, voteNoCount, votePresentCount, voteNotVotingCount;
             
             for (AWSVoteTableRow *item in paginatedOutput.items) {
                 vote = [[Vote alloc] init];
                 vote.roll_id = item.roll_id;
                 vote.bill_id = item.bill_id;
                 vote.nomination_id = item.nomination_id;
                 vote.question = item.question;
                 vote.bill_title = item.bill_title;
                 vote.result = item.result;
                 vote.source = item.source;
                 vote.chamber = item.chamber;
                 vote.voted_at = [item.voted_at substringToIndex:10];
                 vote.republicanVotes = item.republicanVotes;
                 vote.democraticVotes = item.democraticVotes;
                 vote.independentVotes = item.independentVotes;
                 vote.individualVotes = [item.individualVotes allObjects];
                 
                 voteYesCount = 0;
                 voteNoCount = 0;
                 votePresentCount = 0;
                 voteNotVotingCount = 0;
                 
                 fields = [vote.republicanVotes componentsSeparatedByString:@"@"];
                 
                 for (int i = 0; i < 4; i++) {
                     
                     switch (i) {
                         case 1:
                             voteYesCount += [fields[i] intValue];
                             break;
                         case 2:
                             voteNoCount += [fields[i] intValue];
                             break;
                         case 3:
                             voteNotVotingCount += [fields[i] intValue];
                             break;
                         case 4:
                             votePresentCount += [fields[i] intValue];
                             break;
                     }
                 }
                 
                 fields = [vote.democraticVotes componentsSeparatedByString:@"@"];
                 
                 for (int i = 0; i < 4; i++) {
                     
                     switch (i) {
                         case 1:
                             voteYesCount += [fields[i] intValue];
                             break;
                         case 2:
                             voteNoCount += [fields[i] intValue];
                             break;
                         case 3:
                             voteNotVotingCount += [fields[i] intValue];
                             break;
                         case 4:
                             votePresentCount += [fields[i] intValue];
                             break;
                     }
                 }
                 
                 fields = [vote.independentVotes componentsSeparatedByString:@"@"];
                 
                 for (int i = 0; i < 4; i++) {
                     
                     switch (i) {
                         case 1:
                             voteYesCount += [fields[i] intValue];
                             break;
                         case 2:
                             voteNoCount += [fields[i] intValue];
                             break;
                         case 3:
                             voteNotVotingCount += [fields[i] intValue];
                             break;
                         case 4:
                             votePresentCount += [fields[i] intValue];
                             break;
                     }
                 }
                 
                 NSMutableString *totalString = [[NSMutableString alloc] init];
                 
                 for (int i = 0; i < 4; i++) {
                     switch (i) {
                         case 1:
                             [totalString appendString:[NSString stringWithFormat:@"%d",voteYesCount]];
                             [totalString appendString:@"@"];
                             break;
                         case 2:
                             [totalString appendString:[NSString stringWithFormat:@"%d",voteNoCount]];
                             [totalString appendString:@"@"];
                             break;
                         case 3:
                             [totalString appendString:[NSString stringWithFormat:@"%d",voteNotVotingCount]];
                             [totalString appendString:@"@"];
                             break;
                         case 4:
                             [totalString appendString:[NSString stringWithFormat:@"%d",votePresentCount]];
                             break;
                     }
                 }
                 
                 vote.totalVotes = totalString;
                 
                 [votesMutableArray addObject:vote];
             }
             
             if (handler != nil) {
                 handler([votesMutableArray copy],nil);
             }
         }
         return nil;
     }];
}

+(void)fetchVotesForNominationID:(NSString*)nomination_id block:(void(^)(NSArray *scanResult, NSError *error))handler {
    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    AWSDynamoDBQueryExpression *queryExpression = [AWSDynamoDBQueryExpression new];
    queryExpression.indexName = @"nomination_id-voted_at-index";
    queryExpression.keyConditionExpression = @"nomination_id = :nomination_id";
    queryExpression.expressionAttributeValues = @{@":nomination_id":nomination_id};
    queryExpression.scanIndexForward = @NO;
    queryExpression.limit = @20;
    
    GlobalVars *globals = [GlobalVars sharedInstance];
    
    if ([globals.billVoteLastKey count] > 0) {
        queryExpression.exclusiveStartKey = globals.billVoteLastKey;
    }
    
    [[dynamoDBObjectMapper query:[AWSVoteTableRow class]
                      expression:queryExpression]
     continueWithBlock:^id(AWSTask *task) {
         
         if (task.error) {
             if (handler != nil) {
                 handler(nil,task.error);
             }
         }
         else {
             AWSDynamoDBPaginatedOutput *paginatedOutput = task.result;
             
             if ([paginatedOutput.items count] > 0) {
                 globals.billVoteLastKey = paginatedOutput.lastEvaluatedKey;
             }
             
             Vote *vote;
             NSMutableArray *votesMutableArray = [[NSMutableArray alloc] init];
             NSArray *fields;
             int voteYesCount, voteNoCount, votePresentCount, voteNotVotingCount;
             
             for (AWSVoteTableRow *item in paginatedOutput.items) {
                 vote = [[Vote alloc] init];
                 vote.roll_id = item.roll_id;
                 vote.bill_id = item.bill_id;
                 vote.nomination_id = item.nomination_id;
                 vote.question = item.question;
                 vote.bill_title = item.bill_title;
                 vote.result = item.result;
                 vote.source = item.source;
                 vote.chamber = item.chamber;
                 vote.voted_at = [item.voted_at substringToIndex:10];
                 vote.republicanVotes = item.republicanVotes;
                 vote.democraticVotes = item.democraticVotes;
                 vote.independentVotes = item.independentVotes;
                 vote.individualVotes = [item.individualVotes allObjects];
                 
                 voteYesCount = 0;
                 voteNoCount = 0;
                 votePresentCount = 0;
                 voteNotVotingCount = 0;
                 
                 fields = [vote.republicanVotes componentsSeparatedByString:@"@"];
                 
                 for (int i = 0; i < 4; i++) {
                     
                     switch (i) {
                         case 1:
                             voteYesCount += [fields[i] intValue];
                             break;
                         case 2:
                             voteNoCount += [fields[i] intValue];
                             break;
                         case 3:
                             voteNotVotingCount += [fields[i] intValue];
                             break;
                         case 4:
                             votePresentCount += [fields[i] intValue];
                             break;
                     }
                 }
                 
                 fields = [vote.democraticVotes componentsSeparatedByString:@"@"];
                 
                 for (int i = 0; i < 4; i++) {
                     
                     switch (i) {
                         case 1:
                             voteYesCount += [fields[i] intValue];
                             break;
                         case 2:
                             voteNoCount += [fields[i] intValue];
                             break;
                         case 3:
                             voteNotVotingCount += [fields[i] intValue];
                             break;
                         case 4:
                             votePresentCount += [fields[i] intValue];
                             break;
                     }
                 }
                 
                 fields = [vote.independentVotes componentsSeparatedByString:@"@"];
                 
                 for (int i = 0; i < 4; i++) {
                     switch (i) {
                         case 1:
                             voteYesCount += [fields[i] intValue];
                             break;
                         case 2:
                             voteNoCount += [fields[i] intValue];
                             break;
                         case 3:
                             voteNotVotingCount += [fields[i] intValue];
                             break;
                         case 4:
                             votePresentCount += [fields[i] intValue];
                             break;
                     }
                 }
                 
                 NSMutableString *totalString = [[NSMutableString alloc] init];
                 
                 for (int i = 0; i < 4; i++) {
                     switch (i) {
                         case 1:
                             [totalString appendString:[NSString stringWithFormat:@"%d",voteYesCount]];
                             [totalString appendString:@"@"];
                             break;
                         case 2:
                             [totalString appendString:[NSString stringWithFormat:@"%d",voteNoCount]];
                             [totalString appendString:@"@"];
                             break;
                         case 3:
                             [totalString appendString:[NSString stringWithFormat:@"%d",voteNotVotingCount]];
                             [totalString appendString:@"@"];
                             break;
                         case 4:
                             [totalString appendString:[NSString stringWithFormat:@"%d",votePresentCount]];
                             break;
                     }
                 }
                 
                 vote.totalVotes = totalString;
                 
                 [votesMutableArray addObject:vote];
             }
             
             if (handler != nil) {
                 handler([votesMutableArray copy],nil);
             }
         }
         return nil;
     }];
}

@end
