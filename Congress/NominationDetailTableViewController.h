//
//  NominationDetailTableViewController.h
//  Congress
//
//  Created by ERIC on 8/9/16.
//  Copyright © 2016 Eric Panchenko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Progress.h"
#import "Constants.h"
#import "UIAlertController+Blocks.h"
#import "ProgressTapGestureRecognizer.h"
#import "GlobalVars.h"
#import "Nomination.h"
#import "NSDate+Time.h"
#import "TVCMethods.h"
#import "ActionTableViewController.h"
#import "RealmFunctions.h"
#import "VotesTVC.h"
#import "DataManager.h"
#import "DynamicTableViewCell.h"
#import "CommitteeDetailTableViewController.h"
#import "Committee.h"

@interface NominationDetailTableViewController : UITableViewController

@property (nonatomic,strong) Nomination *nomination;
@property (nonatomic,strong) NSString *nomination_id;
@property (nonatomic,strong) TVCMethods *tvcMethods;
@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic, strong) ProgressTapGestureRecognizer *HUDSingleTap;
@property (nonatomic, strong) Progress *progress;
@property (nonatomic, strong) Committee *committee;
@property (nonatomic, strong) NSString *imageName;

@end
