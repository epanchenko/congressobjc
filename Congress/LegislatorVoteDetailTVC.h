//
//  LegislatorVoteDetailTVC.h
//  Congress
//
//  Created by Eric Panchenko on 6/18/16.
//  Copyright © 2016 Eric Panchenko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Vote.h"
#import "LegislatorVoterDetailGraphTableViewCell.h"
#import "VBPieChart.h"
#import "UIColor+Constants.h"
#import "RollCallTVC.h"
#import "Progress.h"
#import "BillDetailTableViewController.h"
#import "NominationDetailTableViewController.h"
#import "TVCMethods.h"

@interface LegislatorVoteDetailTVC : UITableViewController

@property (strong,nonatomic) NSString *roll_id;
@property (strong,nonatomic) NSString *bill_id;
@property (strong,nonatomic) NSString *nomination_id;
@property (strong,nonatomic) NSString *chamber;
@property (strong,nonatomic) Vote* vote;

@property (nonatomic,strong) TVCMethods *tvcMethods;
@property (nonatomic,strong) NSDictionary *totalDict;
@property (nonatomic,strong) NSDictionary *partyDict;
@property (nonatomic,strong) NSMutableDictionary *totalKeys;
@property (nonatomic,strong) NSArray *totalKeysArraySorted;
@property (nonatomic,strong) NSMutableArray *totalKeysArray;
@property (nonatomic,strong) NSArray *partyKeysArray;
@property (nonatomic,strong) NSMutableDictionary *totalOtherPartyKeys;
@property (nonatomic,strong) NSArray *totalOtherPartyKeysSorted;
@property (nonatomic,strong) MBProgressHUD *hud;
@property (nonatomic,strong) ProgressTapGestureRecognizer *HUDSingleTap;
@property (nonatomic,strong) Progress *progress;

@end
