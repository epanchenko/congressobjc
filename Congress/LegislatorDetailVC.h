//
//  LegislatorDetailVC.h
//  Congress
//
//  Created by Eric Panchenko on 9/15/15.
//  Copyright © 2015 Eric Panchenko. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Legislator.h"
#import "LegislatorHeaderCell.h"
#import "LegislatorBioViewController.h"
#import "Progress.h"
#import "Constants.h"
#import "UIAlertController+Blocks.h"
#import "CommitteesTVC.h"
#import "LegislatorVotesTableViewController.h"
#import "ProgressTapGestureRecognizer.h"
#import "TermsTVC.h"
#import "ContactTableViewController.h"
#import "UIColor+Constants.h"
#import "MapViewController.h"
#import "RealmFunctions.h"
#import "Committee.h"
#import "DataManager.h"

@interface LegislatorDetailVC : UIViewController <UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong) Legislator *legislator;
@property (nonatomic) BOOL favorite;
@property (nonatomic,strong) Progress *progress;
@property (nonatomic,strong) MBProgressHUD *hud;
@property (nonatomic,strong) ProgressTapGestureRecognizer *HUDSingleTap;
@property (nonatomic,strong) NSString *filePath;
@property (nonatomic,strong) NSString *mapURL;
@property (nonatomic,strong) NSString *imageName;


@end
