//
//  RealmFunctions.h
//  Congress
//
//  Created by ERIC on 8/28/16.
//  Copyright © 2016 Eric Panchenko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Realm/Realm.h>
#import "FavoriteBill.h"
#import "FavoriteLegislator.h"
#import "FavoriteCommittee.h"
#import "FavoriteNomination.h"
#import "Legislator.h"
#import "Term.h"
#import "Committee.h"

@interface RealmFunctions : NSObject
+ (BOOL)findFavLegislator:(NSString*)legislator_id;
+ (BOOL)findFavCommittee:(NSString*)committee_id;
+ (BOOL)findFavBill:(NSString*)bill_id;
+ (BOOL)findFavNomination:(NSString*)nomination_id;
+ (RLMResults<FavoriteBill *>*) getFavoriteBills;
+ (RLMResults<FavoriteCommittee *>*) getFavoriteCommittees;
+ (RLMResults<FavoriteNomination *>*) getFavoriteNominations;
+ (RLMResults<FavoriteLegislator *>*) getFavoriteLegislators;
+ (void)insertFavBill:(NSString*)bill_id name:(NSString*)name;
+ (void)insertFavLegislator:(NSString*)legislator_id name:(NSString*)name;
+ (void)insertFavCommittee:(NSString*)committee_id name:(NSString*)name;
+ (void)insertFavNomination:(NSString*)nomination_id title:(NSString*)title;
+ (void)deleteFavBill:(NSString*)bill_id;
+ (void)deleteFavLegislator:(NSString*)legislator_id;
+ (void)deleteFavCommittee:(NSString*)committee_id;
+ (void)deleteFavNomination:(NSString*)nomination_id;
+ (void)updateShortcutItems;
@end
