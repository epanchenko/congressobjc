//
//  RealmString.h
//  Congress
//
//  Created by Eric Panchenko on 8/6/17.
//  Copyright © 2017 Eric Panchenko. All rights reserved.
//

#import <Realm/Realm.h>

RLM_ARRAY_TYPE(RealmString)

@interface RealmString : RLMObject
    @property NSString *stringValue;
@end
