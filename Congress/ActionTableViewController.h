//
//  ActionTableViewController.h
//  Congress
//
//  Created by Eric Panchenko on 7/27/16.
//  Copyright © 2016 Eric Panchenko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Progress.h"
#import "Constants.h"
#import "UIAlertController+Blocks.h"
#import "ProgressTapGestureRecognizer.h"
#import "Action.h"
#import "DynamicTableViewCell.h"
#import "TVCMethods.h"
#import "SlideNavigationController.h"

@interface ActionTableViewController : UITableViewController

@property (nonatomic, strong) NSArray *actions;
@property (nonatomic, strong) NSArray *uncompressedActions;
@property (nonatomic, strong) NSString *mode;

@property (nonatomic,strong) TVCMethods *tvcMethods;
@property (nonatomic,strong) MBProgressHUD *hud;
@property (nonatomic,strong) ProgressTapGestureRecognizer *HUDSingleTap;
@property (nonatomic,strong) Progress *progress;

@end
