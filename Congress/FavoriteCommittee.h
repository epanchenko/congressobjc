//
//  FavoriteCommittee.h
//  Congress
//
//  Created by ERIC on 8/28/16.
//  Copyright © 2016 Eric Panchenko. All rights reserved.
//

#import <Realm/Realm.h>

@interface FavoriteCommittee : RLMObject

@property NSString* committee_id;
@property NSString* name;

@end
