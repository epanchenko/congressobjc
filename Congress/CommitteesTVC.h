//
//  CommitteesTVC.h
//  Congress
//
//  Created by ERIC on 9/22/15.
//  Copyright © 2015 Eric Panchenko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"
#import "Progress.h"
#import "UIAlertController+Blocks.h"
#import "CommitteeDetailTableViewController.h"
#import "TVCMethods.h"
#import "Committee.h"
#import "DataManager.h"
#import "SlideNavigationController.h"

@interface CommitteesTVC : UITableViewController<SlideNavigationControllerDelegate>

@property (strong, nonatomic) NSString *mode;
@property (strong, nonatomic) NSArray *committees;
@property (nonatomic) NSInteger committeesReadyCount;
@property (nonatomic,strong) TVCMethods *tvcMethods;
@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic, strong) ProgressTapGestureRecognizer *HUDSingleTap;
@property (nonatomic, strong) Progress *progress;
@property (nonatomic, strong) NSSortDescriptor *committeeNameSort;

@end
