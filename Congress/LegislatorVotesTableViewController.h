//
//  LegislatorVotesTableViewController.h
//  Congress
//
//  Created by Eric Panchenko on 5/22/16.
//  Copyright © 2016 Eric Panchenko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"
#import "Vote.h"
#import "Progress.h"
#import "UIAlertController+Blocks.h"
#import "LegislatorVoteCellTableViewCell.h"
#import "LegislatorVoteDetailTVC.h"
#import "NSDate+Time.h"
#import "UIColor+Constants.h"
#import "ProgressTapGestureRecognizer.h"
#import "TVCMethods.h"
#import "DataManager.h"

@interface LegislatorVotesTableViewController : UITableViewController

@property (nonatomic, strong) NSString *bioguide_id;
@property (nonatomic, strong) NSString *chamber;
@property (nonatomic, strong) TVCMethods *tvcMethods;
@property (nonatomic, strong) NSNumber *currentPage;
@property (nonatomic, strong) NSMutableDictionary *votesDict;
@property (nonatomic, strong) NSMutableArray *votes;
@property (nonatomic, strong) UIBarButtonItem *showMoreVotesButton;
@property (nonatomic, strong) UIBarButtonItem *refreshButton;
@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic, strong) ProgressTapGestureRecognizer *HUDSingleTap;
@property (nonatomic, strong) Progress *progress;

@property (nonatomic) BOOL refreshing;
@end
