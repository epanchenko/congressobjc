//
//  VotesTVC.m
//  
//
//  Created by Eric Panchenko on 5/29/17.
//
//

#import "VotesTVC.h"
#import "RealmFunctions.h"

@interface VotesTVC ()
@end

@implementation VotesTVC

-(void)initRefreshControl {
    self.refreshControl = [UIRefreshControl new];
    [self.refreshControl addTarget:self action:@selector(handleRefresh:) forControlEvents:UIControlEventValueChanged];
}

-(void)enableRefreshControl {
    [self.tableView addSubview:self.refreshControl];
    [self.tableView sendSubviewToBack:self.refreshControl];
}

-(void)disableRefreshControl {
    [self.refreshControl removeFromSuperview];
    self.refreshControl = nil;
}

- (BOOL)slideNavigationControllerShouldDisplayLeftMenu {
    return self.showMenu;
}
    
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [RealmFunctions updateShortcutItems];
    
    if (!(self.title == (id)[NSNull null] || self.title.length == 0)) {
        UILabel* tlabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0, self.navigationController.navigationBar.frame.size.width, self.navigationController.navigationBar.frame.size.height)];
        tlabel.text = self.navigationItem.title;
        tlabel.textAlignment = NSTextAlignmentCenter;
        //tlabel.textColor = [UIColor blackColor];
        tlabel.textColor = [UIColor colorNamed:@"BlackOrWhite"];
        tlabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size: 17.0];
        tlabel.backgroundColor = [UIColor clearColor];
        tlabel.adjustsFontSizeToFitWidth = YES;
        [tlabel setMinimumScaleFactor:10.0/tlabel.font.pointSize];
        self.navigationItem.titleView = tlabel;
        
        self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
        
    }
    else {
        self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeAlways;
        self.showMenu = YES;
    }
    
    UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    self.showMoreVotesButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFastForward target:self action:@selector(showMoreVotesAction)];
    self.refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshVotes)];
    [self.showMoreVotesButton setAccessibilityLabel:NSLocalizedString(@"Show More Votes", @"")];
    [self.showMoreVotesButton setAccessibilityHint:NSLocalizedString(@"Show More Votes", @"")];
    [self.refreshButton setAccessibilityLabel:NSLocalizedString(@"Refresh Votes", @"")];
    [self.refreshButton setAccessibilityHint:NSLocalizedString(@"Refresh Votes", @"")];
    self.navigationController.toolbarHidden = NO;
    [self setToolbarItems:[NSMutableArray arrayWithObjects:spaceItem,self.showMoreVotesButton,spaceItem,self.refreshButton,spaceItem,nil]];
    
    [self.showMoreVotesButton setEnabled:NO];
    [self.refreshButton setEnabled:NO];
    
    self.currentPage = [NSNumber numberWithInt:1];
    
    self.tvcMethods = [[TVCMethods alloc] init];
    self.tvcMethods.tableView = self.tableView;
    
    if (!([self.mode isEqualToString:@"Bill"] || [self.mode isEqualToString:@"Nomination"])) {
        [[NSUserDefaults standardUserDefaults] setInteger:4 forKey:@"menuRow"];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self.tvcMethods
                                             selector:@selector(didChangePreferredContentSize:)
                                                 name:UIContentSizeCategoryDidChangeNotification object:nil];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"LegislatorVoteCell" bundle:nil] forCellReuseIdentifier:@"VoteCell"];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 80;
    
    self.progress = [[Progress alloc] init];
    
    self.HUDSingleTap = [[ProgressTapGestureRecognizer alloc]initWithTarget:self.progress action:@selector(singleTap:)];
    self.HUDSingleTap.navigationController = self.navigationController;
    
    self.votes = [[NSMutableArray alloc] init];
    self.votesDict = [[NSMutableDictionary alloc] init];
    
    [[GlobalVars sharedInstance] clearVoteVars];
    
    [self executeEndPointAsync:YES showToast:NO];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.navigationController.toolbarHidden = NO;
}

- (void)handleRefresh:(UIRefreshControl *)refreshControl {
    
    self.refreshing = YES;
    self.votes = [[NSMutableArray alloc] init];
    self.votesDict = [[NSMutableDictionary alloc] init];
    
    [[GlobalVars sharedInstance] clearVoteVars];
    
    [self.tableView reloadData];
    
    [self.refreshButton setEnabled:NO];
    [self.showMoreVotesButton setEnabled:NO];
    self.currentPage = [[NSNumber alloc] initWithInt:1];
    
    [self executeEndPointAsync:NO showToast:NO];
}

- (void)refreshVotes {
    self.votes = [[NSMutableArray alloc] init];
    self.votesDict = [[NSMutableDictionary alloc] init];
    
    [[GlobalVars sharedInstance] clearVoteVars];
    
    [self.tableView reloadData];
    
    [self.refreshButton setEnabled:NO];
    [self.showMoreVotesButton setEnabled:NO];
    [self disableRefreshControl];
    
    self.currentPage = [[NSNumber alloc] initWithInt:1];
    
    [self executeEndPointAsync:YES showToast:NO];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIContentSizeCategoryDidChangeNotification
                                                  object:nil];
}

- (void)showMoreVotesAction {
    
    [self.showMoreVotesButton setEnabled:NO];
    [self.refreshButton setEnabled:NO];
    [self disableRefreshControl];
    
    self.currentPage = [NSNumber numberWithInt:[self.currentPage intValue] + 1];
        
    [self executeEndPointAsync:NO showToast:YES];
}

- (void)executeEndPointAsync:(BOOL)showMiddleSpinner showToast:(BOOL)showToast {
    
    if ([self.currentPage intValue] == 1) {
        self.votes = [[NSMutableArray alloc] init];
        self.votesDict = [[NSMutableDictionary alloc] init];
        [[GlobalVars sharedInstance] clearVoteVars];
    }
    
    if (showMiddleSpinner) {
        self.hud = [Progress showGlobalProgressHUDWithTitle:@"Loading..."];
        [self.hud addGestureRecognizer:self.HUDSingleTap];
    }
    else if (showToast) {
        [self.view.window makeToast:@"Loading More Votes..."
                duration:0.5
                position:CSToastPositionCenter];
    }
    
    if ([self.mode isEqualToString:@"Bill"])
        [DataManager fetchVotesForBillID:self.bill_id block:^(NSArray *scanResult, NSError *error) {
            
            if (error != nil) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [self.showMoreVotesButton setEnabled:YES];
                    [self.refreshButton setEnabled:YES];
                    
                    if (self.refreshControl != nil) {
                        [self.refreshControl endRefreshing];
                    }
                    else {
                        [self initRefreshControl];
                        [self enableRefreshControl];
                    }
                    
                    [Progress dismissGlobalHUD];
                    
                    NSString *errorMessage;
                    
                    if ([error.domain isEqualToString:@"NotFound"]) {
                        errorMessage = @"No More Votes Found";
                        [self.showMoreVotesButton setEnabled:NO];
                    }
                    else {
                        errorMessage = @"Error Connecting to Votes";
                    }
                    
                    [UIAlertController showAlertInViewController:self withTitle:@"Error" message:errorMessage cancelButtonTitle:@"OK" destructiveButtonTitle:nil otherButtonTitles:nil tapBlock:^(UIAlertController *controller, UIAlertAction *action, NSInteger buttonIndex) {
                        
                    }];
                });
                
            }
            else {
                Vote *vote;
                
                for (int i = 0; i < [scanResult count]; i++) {
                    vote = scanResult[i];
                    
                    if ([[self.votes filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"roll_id == %@", vote.roll_id]] count] == 0) {
                        [self.votes addObject:scanResult[i]];
                    }
                }
                
                NSMutableArray *array;
                
                self.votesDict = [[NSMutableDictionary alloc] init];
                
                for (Vote* vote in self.votes) {
                    
                    array = self.votesDict[vote.voted_at];
                    
                    if (array == nil) {
                        array = [[NSMutableArray alloc] initWithObjects:vote,nil];
                    }
                    else {
                        [array addObject:vote];
                    }
                    
                    [self.votesDict setValue:array forKey:vote.voted_at];
                }
                
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [self.tableView reloadData];
                    [self.tableView layoutIfNeeded];
                    
                    if ([scanResult count] == 20) {
                        [self.showMoreVotesButton setEnabled:YES];
                    }
                    else {
                        [self.showMoreVotesButton setEnabled:NO];
                    }
                    
                    [self.refreshButton setEnabled:YES];
                    
                    if (self.refreshControl != nil) {
                        [self.refreshControl endRefreshing];
                    }
                    else {
                        [self initRefreshControl];
                        [self enableRefreshControl];
                    }
                    
                    [Progress dismissGlobalHUD];
                });
            }
        }];
    else if ([self.mode isEqualToString:@"Nomination"])
        [DataManager fetchVotesForNominationID:self.nomination_id block:^(NSArray *scanResult, NSError *error) {
                        
            if (error != nil) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [self.showMoreVotesButton setEnabled:YES];
                    [self.refreshButton setEnabled:YES];
                    
                    if (self.refreshControl != nil) {
                        [self.refreshControl endRefreshing];
                    }
                    else {
                        [self initRefreshControl];
                        [self enableRefreshControl];
                    }
                    
                    [Progress dismissGlobalHUD];
                    
                    NSString *errorMessage;
                    
                    if ([error.domain isEqualToString:@"NotFound"]) {
                        errorMessage = @"No More Votes Found";
                        [self.showMoreVotesButton setEnabled:NO];
                    }
                    else {
                        errorMessage = @"Error Connecting to Votes";
                    }
                    
                    [UIAlertController showAlertInViewController:self withTitle:@"Error" message:errorMessage cancelButtonTitle:@"OK" destructiveButtonTitle:nil otherButtonTitles:nil tapBlock:^(UIAlertController *controller, UIAlertAction *action, NSInteger buttonIndex) {
                        
                    }];
                });
            }
            else {
                Vote *vote;
                
                for (int i = 0; i < [scanResult count]; i++) {
                    vote = scanResult[i];
                    
                    if ([[self.votes filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"roll_id == %@", vote.roll_id]] count] == 0) {
                        [self.votes addObject:scanResult[i]];
                    }
                }
                
                NSMutableArray *array;
                
                self.votesDict = [[NSMutableDictionary alloc] init];
                
                for (Vote* vote in self.votes) {
                    
                    array = self.votesDict[vote.voted_at];
                    
                    if (array == nil) {
                        array = [[NSMutableArray alloc] initWithObjects:vote,nil];
                    }
                    else {
                        [array addObject:vote];
                    }
                    
                    [self.votesDict setValue:array forKey:vote.voted_at];
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [self.tableView reloadData];
                    [self.tableView layoutIfNeeded];
                    
                    if ([scanResult count] == 20) {
                        [self.showMoreVotesButton setEnabled:YES];
                    }
                    else {
                        [self.showMoreVotesButton setEnabled:NO];
                    }
                    
                    [self.refreshButton setEnabled:YES];
                    
                    if (self.refreshControl != nil) {
                        [self.refreshControl endRefreshing];
                    }
                    else {
                        [self initRefreshControl];
                        [self enableRefreshControl];
                    }
                    
                    [Progress dismissGlobalHUD];
                });
            }
        }];
    else
    [DataManager fetchVotes:^(NSArray *scanResult, NSError *error) {
        
        if (error != nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self.showMoreVotesButton setEnabled:YES];
                [self.refreshButton setEnabled:YES];
                
                if (self.refreshControl != nil) {
                    [self.refreshControl endRefreshing];
                }
                else {
                    [self initRefreshControl];
                    [self enableRefreshControl];
                }
                
                [Progress dismissGlobalHUD];
                
                NSString *errorMessage;
                
                if ([error.domain isEqualToString:@"NotFound"]) {
                    errorMessage = @"No More Votes Found";
                    [self.showMoreVotesButton setEnabled:NO];
                }
                else {
                    errorMessage = @"Error Connecting to Votes";
                }
                
                [UIAlertController showAlertInViewController:self withTitle:@"Error" message:errorMessage cancelButtonTitle:@"OK" destructiveButtonTitle:nil otherButtonTitles:nil tapBlock:^(UIAlertController *controller, UIAlertAction *action, NSInteger buttonIndex) {
                    
                }];
            });
        }
        else {
            Vote *vote;
            
            for (int i = 0; i < [scanResult count]; i++) {
                vote = scanResult[i];
                [self.votes addObject:vote];
            }
            
            NSMutableArray *array;
            
            self.votes = [[NSMutableArray alloc] initWithArray:[self.votes sortedArrayUsingDescriptors:@[[[NSSortDescriptor alloc] initWithKey:@"roll_id"
                                              ascending:NO]]]];
            
            self.votesDict = [[NSMutableDictionary alloc] init];
            
            for (Vote* vote in self.votes) {
                                
                array = self.votesDict[vote.voted_at];
                
                if (array == nil) {
                    array = [[NSMutableArray alloc] initWithObjects:vote,nil];
                }
                else {
                    [array addObject:vote];
                }
                
                [self.votesDict setValue:array forKey:vote.voted_at];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self.tableView reloadData];
                [self.tableView layoutIfNeeded];
                                
                if ([scanResult count] == 20) {
                    [self.showMoreVotesButton setEnabled:YES];
                }
                else {
                    [self.showMoreVotesButton setEnabled:NO];
                }
                
                [self.refreshButton setEnabled:YES];
                
                if (self.refreshControl != nil) {
                    [self.refreshControl endRefreshing];
                }
                else {
                    [self initRefreshControl];
                    [self enableRefreshControl];
                }
                
                [Progress dismissGlobalHUD];
            });
        }
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"LegislatorVoteDetailSegue"]) {
        
        LegislatorVoteDetailTVC *vc = [segue destinationViewController];
        vc.roll_id = self.currentVote2.roll_id;
        vc.bill_id = self.currentVote2.bill_id;
        vc.chamber = self.currentVote2.chamber;
        vc.nomination_id = self.currentVote2.nomination_id;
        vc.vote = self.currentVote2;
        vc.title = [self.currentVote2 bill_title];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self.votesDict allKeys] count];
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    // Background color
    //view.tintColor = [UIColor colorWithRed:0.35 green:0.78 blue:0.98 alpha:1.0];
    
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView*)view;
    
    header.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    header.textLabel.adjustsFontSizeToFitWidth = YES;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSDateFormatter *formatter2 = [[NSDateFormatter alloc] init];
    
    [formatter setDateFormat:@"yyyy-MM-dd"];
    
    [formatter2 setDateStyle:NSDateFormatterFullStyle];
    [formatter2 setTimeStyle:NSDateFormatterNoStyle];
    
    return [formatter2 stringFromDate:[formatter dateFromString:[[[self.votesDict allKeys] sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:nil ascending:NO selector:@selector(localizedCompare:)]]] objectAtIndex:section]]];
                                    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [(NSDictionary*)self.votesDict[[[[self.votesDict allKeys] sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:nil ascending:NO selector:@selector(localizedCompare:)]]] objectAtIndex:section]] count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
        
    NSArray *array = self.votesDict[[[[self.votesDict allKeys] sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:nil ascending:NO selector:@selector(localizedCompare:)]]] objectAtIndex:indexPath.section]];
    
    self.currentVote2 = (Vote*)array[indexPath.row];
        
    [self performSegueWithIdentifier:@"LegislatorVoteDetailSegue" sender:nil];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    LegislatorVoteCellTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"VoteCell" forIndexPath:indexPath];

    if ([self.votesDict count] > 0) {
    
        NSArray* sortedArray = [[self.votesDict allKeys] sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:nil ascending:NO selector:@selector(localizedCompare:)]]];
        
        cell.billTitle.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
        
        NSString *key = [sortedArray objectAtIndex:indexPath.section];
        NSArray *array = self.votesDict[key];
        
        cell.question.text = [NSString stringWithFormat:@"%@: %@",[[array[indexPath.row] chamber] capitalizedString],[array[indexPath.row] question]];
        cell.question.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        
        cell.billTitle.text = [array[indexPath.row] bill_title];
        
        cell.resultLabel.text = [NSString stringWithFormat:@"%@",[array[indexPath.row] result]];
        cell.resultLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    return cell;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    if (self.showMoreVotesButton.enabled && !self.refreshing) {
        if (scrollView.contentSize.height != 0 &&
            scrollView.contentOffset.y + scrollView.bounds.size.height - scrollView.contentInset.bottom >= scrollView.contentSize.height) {
            
            [self showMoreVotesAction];
        }
    }
    else self.refreshing = NO;
}

@end
