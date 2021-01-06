//
//  LegislatorsViewController.h
//  
//
//  Created by Eric Panchenko on 8/29/15.
//
//

#import <UIKit/UIKit.h>
#import "Progress.h"
#import "LegislatorTVCell.h"
#import "Legislator.h"
#import "UIAlertController+Blocks.h"
#import "LegislatorDetailVC.h"
#import "Constants.h"
#import "UIViewController+PartialDictionary.h"
#import "MBProgressHUD.h"
#import "UIColor+Constants.h"
#import "TVCMethods.h"
#import "Term.h"
#import "DataManager.h"
#import "SlideNavigationController.h"

@interface LegislatorsViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating,SlideNavigationControllerDelegate>

@property (nonatomic, strong) NSString *committee_id;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *tvSegmentedControl;
@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic,strong) NSHTTPURLResponse *httpResponse;
@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic, strong) ProgressTapGestureRecognizer *HUDSingleTap;
@property (nonatomic, strong) Progress *progress;
@property (nonatomic, strong) NSArray *legislatorsArray;
@property (nonatomic, strong) NSArray *sectionTitles;
@property (nonatomic, strong) NSDictionary *legislatorsDictionary;
@property (nonatomic, strong) NSArray *filteredSectionTitles;
@property (nonatomic, strong) NSArray *filteredLegislators;
@property (nonatomic, strong) NSArray *currentCommitteeMembers;
@property (nonatomic, strong) NSDictionary *filteredDictionary;
@property (nonatomic, strong) NSArray *sectionLegislators;
@property (nonatomic, strong) NSSortDescriptor *lastNameSort;
@property (nonatomic, strong) NSSortDescriptor *firstNameSort;
@property (nonatomic, strong) NSSortDescriptor *stateSort;
@property (nonatomic) BOOL favorite;
@property (nonatomic, strong) NSString *mode;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *gpsButton;
@property (nonatomic) BOOL showMenu;

@end
