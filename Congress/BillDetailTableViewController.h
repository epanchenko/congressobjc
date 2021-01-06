//
//  BillDetailTableViewController.h
//  Congress
//
//  Created by ERIC on 7/23/16.
//  Copyright © 2016 Eric Panchenko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Progress.h"
#import "Constants.h"
#import "UIAlertController+Blocks.h"
#import "ProgressTapGestureRecognizer.h"
#import "Bill.h"
#import "ReaderViewController.h"
#import "SummaryViewController.h"
#import "AmendmentsTVC.h"
#import "NSDate+Time.h"
#import "TVCMethods.h"
#import "ActionTableViewController.h"
#import "RealmFunctions.h"
#import "VotesTVC.h"
#import "DataManager.h"
#import "GlobalVars.h"

@interface BillDetailTableViewController : UITableViewController <ReaderViewControllerDelegate>

@property (nonatomic,strong) NSString *bill_id;
@property (nonatomic,strong) Bill *bill;
@property (nonatomic,strong) TVCMethods *tvcMethods;
@property (nonatomic,strong) NSString *filePath;
@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic, strong) ProgressTapGestureRecognizer *HUDSingleTap;
@property (nonatomic, strong) Progress *progress;
@property (nonatomic, strong) NSString *imageName;

@end
