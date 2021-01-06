//
//  NominationTableViewController.h
//  Congress
//
//  Created by ERIC on 8/14/16.
//  Copyright © 2016 Eric Panchenko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Progress.h"
#import "Constants.h"
#import "UIAlertController+Blocks.h"
#import "ProgressTapGestureRecognizer.h"
#import "NominationShort.h"
#import "NominationDetailTableViewController.h"
#import "TVCMethods.h"
#import "DynamicTableViewCell.h"
#import "UIView+Toast.h"
#import "SlideNavigationController.h"

@interface NominationTableViewController : UITableViewController<SlideNavigationControllerDelegate>

@property (nonatomic,strong) TVCMethods *tvcMethods;
@property (nonatomic,strong) NSMutableArray *nominations;
@property (nonatomic,strong) MBProgressHUD *hud;
@property (nonatomic,strong) ProgressTapGestureRecognizer *HUDSingleTap;
@property (nonatomic,strong) Progress *progress;
@property (nonatomic, strong) UIBarButtonItem *showMoreNominationsButton;
@property (nonatomic, strong) UIBarButtonItem *refreshButton;
@property (nonatomic) BOOL refreshing;

@end
