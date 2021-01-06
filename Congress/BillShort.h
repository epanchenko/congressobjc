//
//  BillShort.h
//  Congress
//
//  Created by Eric Panchenko on 8/5/16.
//  Copyright © 2016 Eric Panchenko. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BillShort : NSObject

@property (nonatomic, strong) NSString *bill_id;
@property (nonatomic, strong) NSString *official_title;
@property (nonatomic, strong) NSString *chamber;

@end
