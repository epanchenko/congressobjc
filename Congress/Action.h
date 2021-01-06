//
//  Action.h
//  Congress
//
//  Created by Eric Panchenko on 7/27/16.
//  Copyright © 2016 Eric Panchenko. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Action : NSObject

@property (nonatomic, strong) NSString *acted_at;
@property (nonatomic, strong) NSString *chamber;
@property (nonatomic, assign) int action_id;
@property (nonatomic, strong) NSString *text;

@end
