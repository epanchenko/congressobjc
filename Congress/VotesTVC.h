//
//  VotesTVC.h
//  
//
//  Created by Eric Panchenko on 5/29/17.
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
#import "XMLDictionary.h"
#import "UIView+Toast.h"
#import "DataManager.h"
#import "GlobalVars.h"
#import "SlideNavigationController.h"


@interface VotesTVC : UITableViewController<SlideNavigationControllerDelegate>

@property (nonatomic, strong) NSString *mode;
@property (nonatomic, strong) NSString *bill_id;
@property (nonatomic, strong) NSString *nomination_id;
@property (nonatomic, strong) TVCMethods *tvcMethods;
@property (nonatomic, strong) NSNumber *currentPage;
@property (nonatomic, strong) NSMutableDictionary *votesDict;
@property (nonatomic, strong) NSMutableArray *votes;
@property (nonatomic, strong) UIBarButtonItem *showMoreVotesButton;
@property (nonatomic, strong) UIBarButtonItem *refreshButton;
@property (nonatomic, strong) Vote *currentVote2;
@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic, strong) ProgressTapGestureRecognizer *HUDSingleTap;
@property (nonatomic, strong) Progress *progress;
@property (nonatomic) BOOL refreshing;
@property (nonatomic) BOOL showMenu;

@end
