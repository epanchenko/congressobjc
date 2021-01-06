//
//  TVCMethods.h
//  Congress
//
//  Created by ERIC on 7/19/16.
//  Copyright © 2016 Eric Panchenko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
//#import "HTMLReader.h"
#import "States.h"

@interface TVCMethods : NSObject

@property (nonatomic, strong) UITableView *tableView;

- (void)didChangePreferredContentSize:(NSNotification *)notification;
+ (NSData *)sendSynchronousRequest:(NSURLRequest *)request
                 returningResponse:(__autoreleasing NSURLResponse **)responsePtr
                             error:(__autoreleasing NSError **)errorPtr;
+ (NSString *)addSuffixToNumber:(int) number;
+ (NSString *)getAmendmentURL:(NSString*)bill_id chamber:(NSString*)chamber;
+ (NSString *)getStateName:(NSString*)abbreviation;
+ (NSString *)getTitle:(NSString*)abbreviation;
+ (NSInteger)daysBetweenDate:(NSDate*)fromDateTime andDate:(NSDate*)toDateTime;
@end
