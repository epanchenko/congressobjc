//
//  RollCallTVC.h
//  Congress
//
//  Created by Eric Panchenko on 7/8/16.
//  Copyright © 2016 Eric Panchenko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Progress.h"
#import "Constants.h"
#import "UIAlertController+Blocks.h"
#import "RollCall.h"
#import "DataManager.h"
#import "SlideNavigationController.h"

@interface RollCallTVC : UITableViewController

@property (nonatomic, strong) NSString *chamber;
@property (nonatomic, strong) NSArray *votes;
@property (nonatomic, strong) NSString *voter_ids;
@property (nonatomic, strong) NSArray *rollCallArr;
@property (nonatomic, strong) Legislator *selectedLegislator;

@end
