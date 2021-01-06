//
//  FavoritesViewController.m
//
//
//  Created by ERIC on 9/3/16.
//
//

#import "FavoritesViewController.h"
#import "LegislatorTVCell.h"
#import "Legislator.h"
#import "UIAlertController+Blocks.h"
#import "LegislatorDetailVC.h"
#import "Constants.h"
#import "UIViewController+PartialDictionary.h"
#import "MBProgressHUD.h"
#import "UIColor+Constants.h"
#import "RealmFunctions.h"
#import "BillShort.h"
#import "BillTableViewCell.h"
#import "NominationShort.h"

@interface FavoritesViewController () {}

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *tvSegmentedControl;
@property (nonatomic, strong) NSHTTPURLResponse *httpResponse;
@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic, strong) ProgressTapGestureRecognizer *HUDSingleTap;
@property (nonatomic, strong) Progress *progress;
@property (nonatomic, strong) NSArray *legislatorsArray;
@property (nonatomic, strong) NSArray *sectionTitles;
@property (nonatomic, strong) NSDictionary *legislatorsDictionary;
@property (nonatomic, strong) NSArray *filteredSectionTitles;
@property (nonatomic, strong) NSArray *filteredLegislators;
@property (nonatomic, strong) NSDictionary *filteredDictionary;
@property (nonatomic, strong) NSArray *sectionLegislators;
@property (nonatomic, strong) NSSortDescriptor *lastNameSort;
@property (nonatomic, strong) NSSortDescriptor *firstNameSort;
@property (nonatomic, strong) UIToolbar *toolbar;
@property (nonatomic, strong) NSMutableArray *bills;
@property (nonatomic, strong) NSMutableArray *committees;
@property (nonatomic, strong) NSMutableArray *nominations;
@property (nonatomic, strong) NSSortDescriptor *committeeNameSort;

@end

@implementation FavoritesViewController


-(void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];

    self.navigationController.toolbarHidden = YES;
    
    if ([self.tvSegmentedControl selectedSegmentIndex] == 0) {
        [self fetchLegislators];
        self.navigationItem.rightBarButtonItem.enabled = [self.legislatorsArray count] > 0;
    }
    else if ([self.tvSegmentedControl selectedSegmentIndex] == 1) {
        [self fetchBills];
        self.navigationItem.rightBarButtonItem.enabled = [self.bills count] > 0;
    }
    else if ([self.tvSegmentedControl selectedSegmentIndex] == 2) {
        [self fetchNominations];
        self.navigationItem.rightBarButtonItem.enabled = [self.nominations count] > 0;
    }
    else {
        [self fetchCommittees];
        self.navigationItem.rightBarButtonItem.enabled = [self.committees count] > 0;
    }
    
    [self.tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.title = @"Favorites";
    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeAlways;
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.searchBar.placeholder = @"Search Legislator Last Name";
    
    self.searchController.delegate = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.searchController.searchBar.delegate = self;
    self.searchController.hidesNavigationBarDuringPresentation = NO;
    
    self.searchController.searchBar.tintColor = [UIColor blackColor];
    self.searchController.searchBar.barTintColor = [UIColor whiteColor];
    
    UIView *backgroundView = [(UITextField*)[self.searchController.searchBar valueForKey:@"searchField"] subviews].firstObject;
    
    backgroundView.backgroundColor = [UIColor whiteColor];
    backgroundView.layer.cornerRadius = 10;
    backgroundView.clipsToBounds = YES;
    
    self.navigationItem.searchController = self.searchController;
    self.navigationItem.hidesSearchBarWhenScrolling = false;
    self.navigationItem.searchController.active = YES;

    CGRect frame, remain;
    CGRectDivide(self.view.bounds, &frame, &remain, 44, CGRectMaxYEdge);
    self.toolbar = [[UIToolbar alloc] initWithFrame:frame];
    [self.toolbar setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin];
    UIBarButtonItem *deleteButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deleteAction:)];
    [self.toolbar setItems:@[deleteButton]];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editAction:)];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"LegislatorTVCell" bundle:nil] forCellReuseIdentifier:@"LegislatorTVCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"BillTableViewCell" bundle:nil] forCellReuseIdentifier:@"BillCell"];
    
    self.lastNameSort = [NSSortDescriptor sortDescriptorWithKey:@"last_name" ascending:YES];
    self.firstNameSort = [NSSortDescriptor sortDescriptorWithKey:@"first_name" ascending:YES];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    
    //hide spinner
    refreshControl.tintColor = [UIColor clearColor];
    
    [self.tableView addSubview:refreshControl];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didChangePreferredContentSize:)
                                                 name:UIContentSizeCategoryDidChangeNotification object:nil];
    
    self.progress = [[Progress alloc] init];
    
    self.HUDSingleTap = [[ProgressTapGestureRecognizer alloc] initWithTarget:self.progress action:@selector(singleTap:)];
    self.HUDSingleTap.navigationController = self.navigationController;
    
    [[NSUserDefaults standardUserDefaults] setInteger:5 forKey:@"menuRow"];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 80;
    
    self.committeeNameSort = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    if ([self.searchController isActive]) {
        self.searchController.active = NO;
    }
}

- (void)editAction:(id)sender {
    [self.tableView setEditing:!self.tableView.editing];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelAction:)];
    if ([self.tvSegmentedControl selectedSegmentIndex] == 0) {
        self.navigationItem.rightBarButtonItem.enabled = [self.legislatorsArray count] > 0;
    }
    else if ([self.tvSegmentedControl selectedSegmentIndex] == 1) {
        self.navigationItem.rightBarButtonItem.enabled = [self.bills count] > 0;
    }
    else if ([self.tvSegmentedControl selectedSegmentIndex] == 2) {
        self.navigationItem.rightBarButtonItem.enabled = [self.nominations count] > 0;
    }
    else {
        self.navigationItem.rightBarButtonItem.enabled = [self.committees count] > 0;
    }
    
    [self.view addSubview:self.toolbar];
}

- (void)deleteAction:(id)sender {
    
    NSMutableArray *rowsToDelete = [[NSMutableArray alloc] init];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editAction:)];
    
    if ([self.tvSegmentedControl selectedSegmentIndex] == 0) {
        
        Legislator *legislator;
        NSMutableArray *tempArray;
        NSMutableIndexSet *sectionsToDelete = [NSMutableIndexSet indexSet];
        NSMutableArray *legislatorsToRemove = [[NSMutableArray alloc] init];
        NSArray *sectionLegislators;
        NSArray *tempLegislatorsArray;
        NSDictionary *tempLegislatorsDictionary;
        
        tempArray = [[NSMutableArray alloc] initWithArray:self.legislatorsArray];
        
        for (NSIndexPath *indexPath in [self.tableView indexPathsForSelectedRows]) {
            
            if (self.searchController.active) {
                sectionLegislators = [self.filteredDictionary objectForKey:[self.filteredSectionTitles objectAtIndex:indexPath.section]];
            }
            else {
                sectionLegislators = [self.legislatorsDictionary objectForKey:[self.sectionTitles objectAtIndex:indexPath.section]];
            }
            
            legislator = [sectionLegislators objectAtIndex:indexPath.row];
            
            [legislatorsToRemove addObject:legislator];
            
            [tempArray removeObject:legislator];
            
            tempLegislatorsArray = [tempArray sortedArrayUsingDescriptors:@[self.lastNameSort,self.firstNameSort]];
            
            tempLegislatorsDictionary = [self partialIndexOfLastNameInitialFromLegislators:tempLegislatorsArray];
            
            if ([tempLegislatorsDictionary valueForKey:[legislator.last_name substringToIndex:1]] == nil) {
                [sectionsToDelete addIndex:indexPath.section];
            }
            else {
                [rowsToDelete addObject:indexPath];
            }
            
            [RealmFunctions deleteFavLegislator:legislator.bioguide_id];
        }
        
        if (self.searchController.active) {
            
            tempArray = [[NSMutableArray alloc] initWithArray:self.filteredLegislators];
            
            [tempArray removeObjectsInArray:legislatorsToRemove];
            
            self.filteredLegislators = [tempArray sortedArrayUsingDescriptors:@[self.lastNameSort,self.firstNameSort]];
            
            self.filteredDictionary = [self partialIndexOfLastNameInitialFromLegislators:self.filteredLegislators];
            
            self.filteredSectionTitles = [[self.filteredDictionary allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        }
        
        tempArray = [[NSMutableArray alloc] initWithArray:self.legislatorsArray];
        
        [tempArray removeObjectsInArray:legislatorsToRemove];
        
        self.legislatorsArray = [tempArray sortedArrayUsingDescriptors:@[self.lastNameSort,self.firstNameSort]];
        
        self.legislatorsDictionary = [self partialIndexOfLastNameInitialFromLegislators:self.legislatorsArray];
        
        self.sectionTitles = [[self.legislatorsDictionary allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        
        [self.tableView beginUpdates];
        [self.tableView deleteSections:sectionsToDelete withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView deleteRowsAtIndexPaths:rowsToDelete withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
        
        if (!self.searchController.active) {
            self.navigationItem.rightBarButtonItem.enabled = [self.legislatorsArray count] > 0;
        }
        else {
            self.navigationItem.rightBarButtonItem.enabled = [self.filteredLegislators count] > 0;
        }
    }
    else if ([self.tvSegmentedControl selectedSegmentIndex] == 1) {
        
        Bill *bill;
        NSMutableArray *billsToRemove = [[NSMutableArray alloc] init];
        
        for (NSIndexPath *indexPath in [self.tableView indexPathsForSelectedRows]) {
            [rowsToDelete addObject:indexPath];
            
            bill = self.bills[indexPath.row];
            
            [billsToRemove addObject:bill];
            [RealmFunctions deleteFavBill:bill.bill_id];
        }
        
        [self.bills removeObjectsInArray:billsToRemove];
        
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:rowsToDelete withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
        
        self.navigationItem.rightBarButtonItem.enabled = [self.bills count] > 0;
    }
    else if ([self.tvSegmentedControl selectedSegmentIndex] == 2) {
        
        Nomination *nomination;
        NSMutableArray *nominationsToRemove = [[NSMutableArray alloc] init];
        
        for (NSIndexPath *indexPath in [self.tableView indexPathsForSelectedRows]) {
            [rowsToDelete addObject:indexPath];
            
            nomination = self.nominations[indexPath.row];
            
            [nominationsToRemove addObject:nomination];
            [RealmFunctions deleteFavNomination:nomination.nomination_id];
        }
        
        [self.nominations removeObjectsInArray:nominationsToRemove];
        
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:rowsToDelete withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
        
        self.navigationItem.rightBarButtonItem.enabled = [self.nominations count] > 0;
    }
    else {
        Committee *committee;
        NSMutableArray *committeesToRemove = [[NSMutableArray alloc] init];
        
        for (NSIndexPath *indexPath in [self.tableView indexPathsForSelectedRows]) {
            [rowsToDelete addObject:indexPath];
            
            committee = self.committees[indexPath.row];
            
            [committeesToRemove addObject:committee];
            [RealmFunctions deleteFavCommittee:committee.committee_id];
        }
        
        [self.committees removeObjectsInArray:committeesToRemove];
        
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:rowsToDelete withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
        
        self.navigationItem.rightBarButtonItem.enabled = [self.committees count] > 0;
    }
    
    [self.tableView reloadData];
    [self.tableView setEditing:!self.tableView.editing];
    [self.toolbar removeFromSuperview];
}

- (void)cancelAction:(id)sender {
    [self.tableView setEditing:!self.tableView.editing];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editAction:)];
    
    if ([self.tvSegmentedControl selectedSegmentIndex] == 0) {
        self.navigationItem.rightBarButtonItem.enabled = [self.legislatorsArray count] > 0;
    }
    else if ([self.tvSegmentedControl selectedSegmentIndex] == 1) {
        self.navigationItem.rightBarButtonItem.enabled = [self.bills count] > 0;
    }
    else if ([self.tvSegmentedControl selectedSegmentIndex] == 2) {
        self.navigationItem.rightBarButtonItem.enabled = [self.nominations count] > 0;
    }
    else {
        self.navigationItem.rightBarButtonItem.enabled = [self.committees count] > 0;
    }
    
    [self.toolbar removeFromSuperview];
}

- (void)didChangePreferredContentSize:(NSNotification *)notification {
    [self.tableView reloadData];
}

- (void)refresh:(UIRefreshControl *)refreshControl {
    
    if ([self.tvSegmentedControl selectedSegmentIndex] == 0) {
        
         self.searchController.searchBar.text = @"";
        
        [self fetchLegislators];
    }
    else if ([self.tvSegmentedControl selectedSegmentIndex] == 1) {
        self.navigationItem.rightBarButtonItem.enabled = [self.bills count] > 0;
        [self fetchBills];
    }
    else if ([self.tvSegmentedControl selectedSegmentIndex] == 2) {
        self.navigationItem.rightBarButtonItem.enabled = [self.nominations count] > 0;
        [self fetchNominations];
    }
    else {
        self.navigationItem.rightBarButtonItem.enabled = [self.committees count] > 0;
        [self fetchCommittees];
    }
    
    [refreshControl endRefreshing];
}

- (void)fetchBills {
    
    RLMResults<FavoriteBill *>* favBills = [RealmFunctions getFavoriteBills];
    
    if ([favBills count] > 0) {
        
        self.bills = [[NSMutableArray alloc] init];
        
        BillShort *bill;
        
        for (FavoriteBill *favBill in favBills) {
            bill = [[BillShort alloc] init];
            bill.bill_id = favBill.bill_id;
            bill.official_title = favBill.name;
            [self.bills addObject:bill];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.navigationItem.rightBarButtonItem.enabled = [self.bills count] > 0;
            [self.tableView reloadData];
            [Progress dismissGlobalHUD];
        });
    }
}

- (void)fetchCommittees {
    self.hud = [Progress showGlobalProgressHUDWithTitle:@"Loading..."];
    [self.hud addGestureRecognizer:self.HUDSingleTap];
    
    RLMResults<FavoriteCommittee *>* favCommittees = [RealmFunctions getFavoriteCommittees];
    
    NSMutableArray *committees = [[NSMutableArray alloc] init];
    
    self.committees = [[NSMutableArray alloc] init];
    
    if ([favCommittees count] > 0) {
        
        for (int i = 0; i < [favCommittees count]; i++) {
            [committees addObject:[favCommittees[i] committee_id]];
        }
        
        [DataManager fetchCommittees:[committees copy] all:NO block:^(NSArray *scanResult, NSError *error) {
            
            if ([scanResult count] > 0) {
                self.committees = [[NSMutableArray alloc] initWithArray:[scanResult sortedArrayUsingDescriptors:@[self.committeeNameSort]]];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.navigationItem.rightBarButtonItem.enabled = [self.committees count] > 0;
                    [self.tableView reloadData];
                    [Progress dismissGlobalHUD];
                });
            }
            else {                
                [DataManager fetchCommittees:nil all:YES block:^(NSArray *scanResult2, NSError *error2) {
                    
                    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
                    
                    if (error2 != nil || [scanResult2 count] == 0) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                            [Progress dismissGlobalHUD];
                            
                            [UIAlertController showAlertInViewController:self withTitle:@"Error" message:@"Unable to fetch committees." cancelButtonTitle:@"OK" destructiveButtonTitle:nil otherButtonTitles:nil tapBlock:^(UIAlertController *controller, UIAlertAction *action, NSInteger buttonIndex) {}];
                        });
                    }
                    
                    for (int j = 0; j < [committees count]; j++) {
                        for (int i = 0; i < [scanResult2 count]; i++) {
                            
                            if ([[scanResult2[i] committee_id] isEqualToString:committees[j]]) {
                                [tempArray addObject:scanResult2[i]];
                            }
                        }
                    }
                    
                    if ([tempArray count] > 0) {
                        self.committees = [[NSMutableArray alloc] initWithArray:[tempArray sortedArrayUsingDescriptors:@[self.committeeNameSort]]];
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            self.navigationItem.rightBarButtonItem.enabled = [self.committees count] > 0;
                            [self.tableView reloadData];
                            [Progress dismissGlobalHUD];
                        });
                    }
                    else {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [Progress dismissGlobalHUD];
                        });
                    }
                }];
            }
        }];
    }
    else {
        self.committees = [[NSMutableArray alloc] init];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            [Progress dismissGlobalHUD];
            self.navigationItem.rightBarButtonItem.enabled = NO;
        });
    }
    
}

- (void)fetchLegislators {
    self.hud = [Progress showGlobalProgressHUDWithTitle:@"Loading..."];
    [self.hud addGestureRecognizer:self.HUDSingleTap];
    
    [self.tvSegmentedControl setEnabled:NO];
    
    RLMResults<FavoriteLegislator *>* favLegislators = [RealmFunctions getFavoriteLegislators];
    
    NSMutableArray *legislators = [[NSMutableArray alloc] init];
    
    if ([favLegislators count] > 0) {
        
        for (int i = 0; i < [favLegislators count]; i++) {
            [legislators addObject:[favLegislators[i] legislator_id]];
        }
        
        [DataManager fetchLegislators:[legislators copy] all:NO chamber:@"All" block:^(NSArray *scanResult, NSError *error) {
            
            self.legislatorsArray = [scanResult sortedArrayUsingDescriptors:@[self.lastNameSort,self.firstNameSort]];
            
            self.legislatorsDictionary = [self partialIndexOfLastNameInitialFromLegislators:self.legislatorsArray];
            
            self.sectionTitles = [[self.legislatorsDictionary allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if (!self.searchController.active) {
                    self.navigationItem.rightBarButtonItem.enabled = [self.legislatorsArray count] > 0;
                }
                else {
                    self.navigationItem.rightBarButtonItem.enabled = [self.filteredLegislators count] > 0;
                }
                
                [self.tableView reloadData];
                [Progress dismissGlobalHUD];
                
                if ([scanResult count] == 0) {
                    self.navigationItem.rightBarButtonItem.enabled = NO;
                }
            });
        }];
    }
    else {
        self.legislatorsArray = @[];
        
        self.legislatorsDictionary = @{};
        
        self.sectionTitles = @[];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            [Progress dismissGlobalHUD];
            self.navigationItem.rightBarButtonItem.enabled = NO;
        });
    }
    
    [self.tvSegmentedControl setEnabled:YES];
}

- (void)fetchNominations {
    
    RLMResults<FavoriteNomination *>* favNominations = [RealmFunctions getFavoriteNominations];
    
    if ([favNominations count] > 0) {
        
        self.nominations = [[NSMutableArray alloc] init];
        
        NominationShort *nomination;
        
        for (FavoriteNomination *favNomination in favNominations) {
            nomination = [[NominationShort alloc] init];
            nomination.nomination_id = favNomination.nomination_id;
            nomination.nominee_description = favNomination.title;
            [self.nominations addObject:nomination];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.navigationItem.rightBarButtonItem.enabled = [self.nominations count] > 0;
            [self.tableView reloadData];
            [Progress dismissGlobalHUD];
        });
    }
}

- (IBAction)segmentedControlValueChanged:(id)sender {
    
    if ([self.tvSegmentedControl selectedSegmentIndex] == 0) {
        
        self.navigationItem.searchController = self.searchController;
        
        [self fetchLegislators];
        
        if (!self.searchController.active) {
            self.navigationItem.rightBarButtonItem.enabled = [self.legislatorsArray count] > 0;
        }
        else {
            self.navigationItem.rightBarButtonItem.enabled = [self.filteredLegislators count] > 0;
        }
    }
    else if ([self.tvSegmentedControl selectedSegmentIndex] == 1) {
        
        self.navigationItem.searchController.active = NO;
        self.navigationItem.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
        self.navigationItem.searchController = nil;
        
        [self fetchBills];
        self.navigationItem.rightBarButtonItem.enabled = [self.bills count] > 0;
    }
    else if ([self.tvSegmentedControl selectedSegmentIndex] == 2) {
        
        self.navigationItem.searchController.active = NO;
        self.navigationItem.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
        self.navigationItem.searchController = nil;
        
        [self fetchNominations];
        self.navigationItem.rightBarButtonItem.enabled = [self.nominations count] > 0;
    }
    else {
        self.navigationItem.searchController.active = NO;
        self.navigationItem.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
        self.navigationItem.searchController = nil;
        
        [self fetchCommittees];
        self.navigationItem.rightBarButtonItem.enabled = [self.committees count] > 0;
    }
    
    [self.tableView reloadData];
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIContentSizeCategoryDidChangeNotification
                                                  object:nil];
    
    self.searchController.searchResultsUpdater = nil;
    self.searchController.searchBar.delegate = nil;
    self.searchController.delegate = nil;
    self.searchController = nil;
    
    [self.searchController.view removeFromSuperview];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    
    NSMutableArray *searchResults = [self.legislatorsArray mutableCopy];
    
    NSString *strippedString = [searchController.searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    // %K is a key path %@ would be an object
    
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"%K BEGINSWITH[c] %@", @"last_name", strippedString];
    
    if ([strippedString length] > 0) {
        self.filteredLegislators = [[searchResults filteredArrayUsingPredicate:predicate] mutableCopy];
    }
    else {
        self.filteredLegislators = [self.legislatorsArray mutableCopy];
    }
    
    self.filteredDictionary = [self partialIndexOfLastNameInitialFromLegislators:self.filteredLegislators];
    self.filteredSectionTitles = [[self.filteredDictionary allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    
    [self.tableView reloadData];
    self.navigationItem.rightBarButtonItem.enabled = [self.filteredLegislators count] > 0;

}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    if ([self.tvSegmentedControl selectedSegmentIndex] == 0) {
        self.tableView.backgroundView = nil;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        
        if (!self.searchController.active) {
            return [self.sectionTitles count];
        }
        else {
            return [self.filteredSectionTitles count];
        }
    }
    else return 1;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    
    if ([self.tvSegmentedControl selectedSegmentIndex] == 0) {
        if (!self.searchController.active) {
            return self.sectionTitles;
        }
        else {
            return self.filteredSectionTitles;
        }
    }
    else {
        return @[];
    }
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    
    if ([self.tvSegmentedControl selectedSegmentIndex] == 0) {
        NSArray *array;
        
        if (!self.searchController.active) {
            array = self.sectionTitles;
        }
        else {
            array = self.filteredSectionTitles;
        }
        
        for (int i = 0; i < [array count]; i++) {
            if ([[(NSString*)array[i] substringToIndex:1] isEqualToString:title]) {
                return i;
            }
        }
        
        return 0;
    }
    else {
        return 0;
    }
}

- (NSDictionary *)partialIndex:(NSArray *)array {
    
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    NSArray *value;
    NSString *key;
    
    for (NSString *string in array) {
        key = [string substringToIndex:1];
        value = result[key];
        
        if (value == nil) {
            result[key] = [NSArray arrayWithObject:string]; // Create new array
        } else {
            result[key] = [value arrayByAddingObject:string]; // Add to existing
        }
    }
    
    return [result copy]; // NSMutableDictionary * to NSDictionary *
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if ([self.tvSegmentedControl selectedSegmentIndex] == 0) {
        
        if (!self.searchController.active) {
            
            if ([self.sectionTitles objectAtIndex:section] == nil) {
                return 0;
            }
            
            return [(NSDictionary*)[self.legislatorsDictionary objectForKey:[self.sectionTitles objectAtIndex:section]] count];
        }
        
        if ([self.filteredSectionTitles objectAtIndex:section] == nil) {
            return 0;
        }
        
        return [(NSDictionary*)[self.filteredDictionary objectForKey:[self.filteredSectionTitles objectAtIndex:section]] count];
    }
    else if ([self.tvSegmentedControl selectedSegmentIndex] == 1) {
        return [self.bills count];
    }
    else if ([self.tvSegmentedControl selectedSegmentIndex] == 2) {
        return [self.nominations count];
    }
    else {
        return [self.committees count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([self.tvSegmentedControl selectedSegmentIndex] == 0) {
        LegislatorTVCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LegislatorTVCell" forIndexPath:indexPath];
        
        NSArray *sectionLegislators;
        
        if (!self.searchController.active) {
            sectionLegislators = [self.legislatorsDictionary objectForKey:[self.sectionTitles objectAtIndex:indexPath.section]];
        }
        else {
            sectionLegislators = [self.filteredDictionary objectForKey:[self.filteredSectionTitles objectAtIndex:indexPath.section]];
        }
        
        Legislator *legislator = [sectionLegislators objectAtIndex:indexPath.row];
        
        cell.name.text = [NSString stringWithFormat:@"%@, %@ (%@.)",legislator.last_name,legislator.first_name,legislator.title];
        
        if ([legislator.district isKindOfClass:[NSNull class]] || [legislator.district intValue] == 0) {
            cell.location.text = [NSString stringWithFormat:@"(%@) %@",legislator.party,legislator.state_name];
        }
        else {
            cell.location.text = [NSString stringWithFormat:@"(%@) %@ - District %@",legislator.party,legislator.state_name,legislator.district];
        }
        
        cell.location.textColor = [UIColor grayColor];
        cell.name.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        cell.location.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        cell.name.adjustsFontSizeToFitWidth = YES;
        cell.location.adjustsFontSizeToFitWidth = YES;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        return cell;
    }
    else if ([self.tvSegmentedControl selectedSegmentIndex] == 1) {
        BillTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BillCell" forIndexPath:indexPath];
        
        BillShort *bill = self.bills[indexPath.row];
        
        cell.billNumber.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        
        NSString *billtype = [bill.bill_id substringToIndex:[bill.bill_id rangeOfString:@"-"].location],
        *number;
        
        NSMutableString *str2 = [[NSMutableString alloc] init],
        *str3 = [[NSMutableString alloc] init];
        
        NSCharacterSet *letterSet = [NSCharacterSet letterCharacterSet],
        *numberSet = [NSCharacterSet decimalDigitCharacterSet];
        
        unichar character;
        
        for (int i = 0; i < billtype.length; i++) {
            
            character = [billtype characterAtIndex:i];
            
            if ([letterSet characterIsMember:character]) {
                [str2 appendString:[NSString stringWithFormat:@"%c",character]];
            }
            else if ([numberSet characterIsMember:character]) {
                [str3 appendString:[NSString stringWithFormat:@"%c",character]];
            }
        }
        
        billtype = [str2 copy];
        number = [str3 copy];
        
        if ([billtype isEqualToString:@"hr"]) {
            billtype = @"H.R.";
        }
        else if ([billtype isEqualToString:@"hres"]) {
            billtype = @"H. Res.";
        }
        else if ([billtype isEqualToString:@"hjres"]) {
            billtype = @"H. J. Res.";
        }
        else if ([billtype isEqualToString:@"hconres"]) {
            billtype = @"H. Con. Res.";
        }
        else if ([billtype isEqualToString:@"s"]) {
            billtype = @"S.";
        }
        else if ([billtype isEqualToString:@"sres"]) {
            billtype = @"S. Res.";
        }
        else if ([billtype isEqualToString:@"sjres"]) {
            billtype = @"S. J. Res.";
        }
        else if ([billtype isEqualToString:@"sconres"]) {
            billtype = @"S. Con. Res.";
        }
        
        cell.billNumber.text = [NSString stringWithFormat:@"%@ %@",billtype,number];
        cell.title.text = [bill official_title];
        //cell.billNumber.backgroundColor = [UIColor colorWithRed:0.35 green:0.78 blue:0.98 alpha:1.0];
        cell.title.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        return cell;
        
    }
    else if ([self.tvSegmentedControl selectedSegmentIndex] == 2) {
        BillTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BillCell" forIndexPath:indexPath];
        NominationShort *nomination = self.nominations[indexPath.row];
        
        cell.billNumber.text = [NSString stringWithFormat:@"%@",[nomination.nomination_id substringWithRange:NSMakeRange(0, [nomination.nomination_id rangeOfString:@"-"].location)]];
        cell.title.text = nomination.nominee_description;
        //cell.billNumber.backgroundColor = [UIColor colorWithRed:0.35 green:0.78 blue:0.98 alpha:1.0];
        cell.title.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        return cell;
    }
    else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CommitteeCell" forIndexPath:indexPath];
        
        Committee *committee = self.committees[indexPath.row];
        
        cell.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
        cell.textLabel.text = [committee.name capitalizedString];
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (![self.tableView isEditing] ) {
        if ([self.tvSegmentedControl selectedSegmentIndex] == 0) {
            self.sectionLegislators = [self.legislatorsDictionary objectForKey:[self.sectionTitles objectAtIndex:indexPath.section]];
            
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                
                [self performSegueWithIdentifier:@"LegislatorDetail" sender:[self.sectionLegislators objectAtIndex:indexPath.row]];
            });
        }
        else if ([self.tvSegmentedControl selectedSegmentIndex] == 1) {
            [self performSegueWithIdentifier:@"BillDetail" sender:nil];
        }
        else if ([self.tvSegmentedControl selectedSegmentIndex] == 2) {
            [self performSegueWithIdentifier:@"NominationDetail" sender:nil];
        }
        else {
            [self performSegueWithIdentifier:@"CommitteeDetail" sender:nil];
        }
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if ([self.tvSegmentedControl selectedSegmentIndex] == 0) {
        return [self.sectionTitles objectAtIndex:section];
    }
    
    return @"";
}

- (void)setEditing:(BOOL)editing {
    
    [super setEditing:editing animated:YES];
    [self.tableView setEditing:editing animated:YES];
}

- (BOOL)slideNavigationControllerShouldDisplayLeftMenu {
    return YES;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"LegislatorDetail"]) {
        LegislatorDetailVC *tvc = [segue destinationViewController];
        Legislator *legislator = (Legislator*)sender;
        
        tvc.legislator = legislator;
        tvc.title = [NSString stringWithFormat:@"%@, %@",legislator.last_name,legislator.first_name];
    }
    else if ([segue.identifier isEqualToString:@"BillDetail"]) {
        BillDetailTableViewController *vc = [segue destinationViewController];
        BillShort *bill = self.bills[[[self.tableView indexPathForSelectedRow] row]];
        vc.bill_id = bill.bill_id;
        vc.title = [bill official_title];
    }
    else if ([segue.identifier isEqualToString:@"NominationDetail"]) {
        NominationDetailTableViewController *vc = [segue destinationViewController];
        NominationShort *nomination = self.nominations[[[self.tableView indexPathForSelectedRow] row]];
        vc.nomination_id = nomination.nomination_id;
        vc.title = nomination.nominee_description;
    }
    else if ([segue.identifier isEqualToString:@"CommitteeDetail"]) {
        CommitteeDetailTableViewController *tvc = [segue destinationViewController];
        Committee *committee = self.committees[[[self.tableView indexPathForSelectedRow] row]];
        
        tvc.committee = committee;
        tvc.title = [committee.name capitalizedString];
    }
}

@end
