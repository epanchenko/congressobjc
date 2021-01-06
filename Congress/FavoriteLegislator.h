//
//  FavoriteLegislator.h
//  Congress
//
//  Created by ERIC on 8/28/16.
//  Copyright © 2016 Eric Panchenko. All rights reserved.
//

#import <Realm/Realm.h>

@interface FavoriteLegislator : RLMObject

@property NSString *legislator_id;
@property NSString *name;

@end
