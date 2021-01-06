//
//  RealmFunctions.m
//  Congress
//
//  Created by ERIC on 8/28/16.
//  Copyright © 2016 Eric Panchenko. All rights reserved.
//

#import "RealmFunctions.h"
#import "AppDelegate.h"

@implementation RealmFunctions

+ (BOOL)findFavBill:(NSString *)bill_id {
    
    RLMResults<FavoriteBill *> *queryBills;
    
    queryBills = [FavoriteBill objectsWithPredicate:[NSPredicate predicateWithFormat:@"bill_id = %@",bill_id]];
    
    return [queryBills count] > 0;
}

+ (BOOL)findFavCommittee:(NSString*)committee_id {
    RLMResults<FavoriteCommittee *> *queryCommittees;
    
    queryCommittees = [FavoriteCommittee objectsWithPredicate:[NSPredicate predicateWithFormat:@"committee_id = %@",committee_id]];
    
    return [queryCommittees count] > 0;
}

+ (BOOL)findFavLegislator:(NSString*)legislator_id {
    
    RLMResults<FavoriteLegislator *> *queryLegislators;
    
    queryLegislators = [FavoriteLegislator objectsWithPredicate:[NSPredicate predicateWithFormat:@"legislator_id = %@",legislator_id]];
    
    return [queryLegislators count] > 0;
}

+ (BOOL)findFavNomination:(NSString *)nomination_id {
    
    RLMResults<FavoriteNomination *> *queryNominations;
    
    queryNominations = [FavoriteNomination objectsWithPredicate:[NSPredicate predicateWithFormat:@"nomination_id = %@",nomination_id]];
    
    return [queryNominations count] > 0;
}

+ (RLMResults<FavoriteBill *>*) getFavoriteBills {
    return [[FavoriteBill allObjects] sortedResultsUsingKeyPath:@"name" ascending:YES];
}

+ (RLMResults<FavoriteCommittee *>*) getFavoriteCommittees {
    return [[FavoriteCommittee allObjects] sortedResultsUsingKeyPath:@"name" ascending:YES];
}

+ (RLMResults<FavoriteLegislator *>*) getFavoriteLegislators {
    return [[FavoriteLegislator allObjects] sortedResultsUsingKeyPath:@"name" ascending:YES];
}

+ (RLMResults<FavoriteNomination *>*) getFavoriteNominations {
    return [[FavoriteNomination allObjects] sortedResultsUsingKeyPath:@"title" ascending:YES];
}

+ (void)insertFavBill:(NSString*)bill_id name:(NSString*)name {
    
    dispatch_async(dispatch_queue_create("background", 0), ^{
        
        RLMRealm *realm = [RLMRealm defaultRealm];
        
        RLMResults<FavoriteBill *> *queryBills = [FavoriteBill objectsWithPredicate:[NSPredicate predicateWithFormat:@"bill_id = %@",bill_id]];
        
        if ([queryBills count] == 0) {
            
            [realm beginWriteTransaction];
            
            FavoriteBill *bill = [[FavoriteBill alloc] init];
            
            bill.bill_id = bill_id;
            bill.name = name;
            
            [realm addObject:bill];
            
            [realm commitWriteTransaction];
        }
    });
}

+ (void)insertFavLegislator:(NSString*)legislator_id name:(NSString*)name {
    
    dispatch_async(dispatch_queue_create("background", 0), ^{
        
        RLMRealm *realm = [RLMRealm defaultRealm];
        
        RLMResults<FavoriteLegislator *> *queryLegislators = [FavoriteLegislator objectsWithPredicate:[NSPredicate predicateWithFormat:@"legislator_id = %@",legislator_id]];
        
        if ([queryLegislators count] == 0) {
            
            [realm beginWriteTransaction];
            
            FavoriteLegislator *legislator = [[FavoriteLegislator alloc] init];
            
            legislator.legislator_id = legislator_id;
            legislator.name = name;
            
            [realm addObject:legislator];
            
            [realm commitWriteTransaction];
            
            [self updateShortcutItems];
        }
    });
}

+ (void)insertFavNomination:(NSString*)nomination_id title:(NSString*)title {
    
    dispatch_async(dispatch_queue_create("background", 0), ^{
        
        RLMRealm *realm = [RLMRealm defaultRealm];
        
        RLMResults<FavoriteNomination *> *queryNominations = [FavoriteNomination objectsWithPredicate:[NSPredicate predicateWithFormat:@"nomination_id = %@",nomination_id]];
        
        if ([queryNominations count] == 0) {
            
            [realm beginWriteTransaction];
            
            FavoriteNomination *nomination = [[FavoriteNomination alloc] init];
            
            nomination.nomination_id = nomination_id;
            nomination.title = title;
            
            [realm addObject:nomination];
            [realm commitWriteTransaction];
        }
    });
}

+ (void)updateShortcutItems {
    if ([UIApplicationShortcutItem class]) {
        
        RLMResults<FavoriteLegislator *>* favLegislators = [RealmFunctions getFavoriteLegislators];
        
        NSMutableArray *items = [[NSMutableArray alloc] init];
        
        FavoriteLegislator *legislator;
        
        if ([favLegislators count] >= 1) {
            
            legislator = favLegislators[0];
            
            [items insertObject:[[UIMutableApplicationShortcutItem alloc] initWithType:@"com.choose4software.Congress.Legislator1" localizedTitle:[NSString stringWithFormat:@"Votes - %@",legislator.name]] atIndex:0];
        }
        
        if ([favLegislators count] >= 2) {
            
            legislator = favLegislators[1];
            
            [items insertObject:[[UIMutableApplicationShortcutItem alloc] initWithType:@"com.choose4software.Congress.Legislator2" localizedTitle:[NSString stringWithFormat:@"Votes - %@",legislator.name]] atIndex:0];
        }
        
        if ([favLegislators count] >= 3) {
            
            legislator = favLegislators[2];
            
            [items insertObject:[[UIMutableApplicationShortcutItem alloc] initWithType:@"com.choose4software.Congress.Legislator3" localizedTitle:[NSString stringWithFormat:@"Votes - %@",legislator.name]] atIndex:0];
        }
        
        UIApplication* application = [UIApplication sharedApplication];
        dispatch_async(dispatch_get_main_queue(), ^{
            application.shortcutItems = items;
        });
    }
}

+ (void)insertFavCommittee:(NSString*)committee_id name:(NSString*)name {
    
    dispatch_async(dispatch_queue_create("background", 0), ^{
        
        RLMRealm *realm = [RLMRealm defaultRealm];
        
        RLMResults<FavoriteCommittee *> *queryCommittees = [FavoriteCommittee objectsWithPredicate:[NSPredicate predicateWithFormat:@"committee_id = %@",committee_id]];
        
        if ([queryCommittees count] == 0) {

            [realm beginWriteTransaction];
            
            FavoriteCommittee *committee = [[FavoriteCommittee alloc] init];
            
            committee.committee_id = committee_id;
            committee.name = name;
            
            [realm addObject:committee];
            
            [realm commitWriteTransaction];
        }
    });
}

+ (void)deleteFavBill:(NSString*)bill_id {
    
    dispatch_async(dispatch_queue_create("background", 0), ^{
        
        RLMRealm *realm = [RLMRealm defaultRealm];
        
        RLMResults<FavoriteBill *> *queryBills = [FavoriteBill objectsWithPredicate:[NSPredicate predicateWithFormat:@"bill_id = %@",bill_id]];
        
        if ([queryBills count] > 0) {
            
            for (FavoriteBill* bill in queryBills) {
                [realm beginWriteTransaction];
                
                [realm deleteObject:bill];
                
                [realm commitWriteTransaction];
            }
        }
    });
}

+ (void)deleteFavLegislator:(NSString*)legislator_id {
    dispatch_async(dispatch_queue_create("background", 0), ^{
        
        RLMRealm *realm = [RLMRealm defaultRealm];
        
        RLMResults<FavoriteLegislator *> *queryLegislators = [FavoriteLegislator objectsWithPredicate:[NSPredicate predicateWithFormat:@"legislator_id = %@",legislator_id]];
        
        if ([queryLegislators count] > 0) {
            
            for (FavoriteLegislator* legislator in queryLegislators) {
                [realm beginWriteTransaction];
                
                [realm deleteObject:legislator];
                
                [realm commitWriteTransaction];
            }
            
            [self updateShortcutItems];
        }
    });
}

+ (void)deleteFavCommittee:(NSString*)committee_id {
    
    dispatch_async(dispatch_queue_create("background", 0), ^{
        
        RLMRealm *realm = [RLMRealm defaultRealm];

        RLMResults<FavoriteCommittee *> *queryCommittees = [FavoriteCommittee objectsWithPredicate:[NSPredicate predicateWithFormat:@"committee_id = %@",committee_id]];
        
        if ([queryCommittees count] > 0) {
            
            for (FavoriteCommittee* committee in queryCommittees) {
                [realm beginWriteTransaction];
                
                [realm deleteObject:committee];
                
                [realm commitWriteTransaction];
            }
        }
    });
}

+ (void)deleteFavNomination:(NSString*)nomination_id {
    
    dispatch_async(dispatch_queue_create("background", 0), ^{
        
        RLMRealm *realm = [RLMRealm defaultRealm];
        
        RLMResults<FavoriteNomination *> *queryNominations = [FavoriteNomination objectsWithPredicate:[NSPredicate predicateWithFormat:@"nomination_id = %@",nomination_id]];
        
        if ([queryNominations count] > 0) {
            
            for (FavoriteNomination* nomination in queryNominations) {
                [realm beginWriteTransaction];
                [realm deleteObject:nomination];
                [realm commitWriteTransaction];
            }
        }
    });
}

@end
