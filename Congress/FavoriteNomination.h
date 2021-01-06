//
//  FavoriteNomination.h
//  Congress
//
//  Created by Eric Panchenko on 10/9/17.
//  Copyright © 2017 Eric Panchenko. All rights reserved.
//

#import <Realm/Realm.h>

@interface FavoriteNomination : RLMObject

@property NSString *nomination_id;
@property NSString *title;

@end
