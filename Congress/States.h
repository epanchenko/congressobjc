//
//  States.h
//  Congress
//
//  Created by Eric Panchenko on 7/3/17.
//  Copyright © 2017 Eric Panchenko. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface States : NSObject

+ (States*)sharedInstance;

@property (nonatomic,strong) NSDictionary* stateDict;
@property (nonatomic,strong) NSDictionary* terrDict;

@end
