//
//  CommitteeDetailTableViewController.h
//  Congress
//
//  Created by Eric Panchenko on 8/7/16.
//  Copyright © 2016 Eric Panchenko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Committee.h"
#import "TVCMethods.h"
#import "WebpageViewController.h"
#import "CommitteesTVC.h"
#import "LegislatorsViewController.h"
#import "RealmFunctions.h"
#import "Progress.h"
#import "Constants.h"
#import "UIAlertController+Blocks.h"
#import "ProgressTapGestureRecognizer.h"

@interface CommitteeDetailTableViewController : UITableViewController

@property (nonatomic,strong) Committee *committee;
@property (nonatomic,strong) TVCMethods *tvcMethods;
@property (nonatomic,strong) MBProgressHUD *hud;
@property (nonatomic,strong) ProgressTapGestureRecognizer *HUDSingleTap;
@property (nonatomic,strong) Progress *progress;
@property (nonatomic,strong) NSString *imageName;
@end
