//
//  NominationTableViewController.m
//  Congress
//
//  Created by ERIC on 8/14/16.
//  Copyright © 2016 Eric Panchenko. All rights reserved.
//

#import "NominationTableViewController.h"


@interface NominationTableViewController ()

@end

@implementation NominationTableViewController

-(void)initRefreshControl {
    self.refreshControl = [UIRefreshControl new];
    [self.refreshControl addTarget:self action:@selector(handleRefresh:) forControlEvents:UIControlEventValueChanged];
    [self.refreshControl layoutIfNeeded];
}

-(void)enableRefreshControl {
    [self.tableView addSubview:self.refreshControl];
    [self.tableView sendSubviewToBack:self.refreshControl];
}

-(void)disableRefreshControl {
    [self.refreshControl removeFromSuperview];
    self.refreshControl = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeAlways;
    
    UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    self.showMoreNominationsButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFastForward target:self action:@selector(showMoreNominationsAction)];
    _refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshNominations)];
    [self.showMoreNominationsButton setAccessibilityLabel:NSLocalizedString(@"Show More Nominations", @"")];
    [self.showMoreNominationsButton setAccessibilityHint:NSLocalizedString(@"Show More Nominations", @"")];
    [_refreshButton setAccessibilityLabel:NSLocalizedString(@"Refresh Nominations", @"")];
    [_refreshButton setAccessibilityHint:NSLocalizedString(@"Refresh Nominations", @"")];
    [self setToolbarItems:[NSMutableArray arrayWithObjects:spaceItem,self.showMoreNominationsButton,spaceItem,_refreshButton,spaceItem,nil]];
    
    [self.showMoreNominationsButton setEnabled:NO];
    [_refreshButton setEnabled:NO];
    
    self.nominations = [[NSMutableArray alloc] init];
    [[GlobalVars sharedInstance] clearNominationVars];
    
    [[NSUserDefaults standardUserDefaults] setInteger:2 forKey:@"menuRow"];
    
    self.progress = [[Progress alloc] init];
    _HUDSingleTap = [[ProgressTapGestureRecognizer alloc]initWithTarget:self.progress action:@selector(singleTap:)];
    _HUDSingleTap.navigationController = self.navigationController;
    
    self.tvcMethods = [[TVCMethods alloc] init];
    self.tvcMethods.tableView = self.tableView;
    
    [[NSNotificationCenter defaultCenter] addObserver:self.tvcMethods
                                             selector:@selector(didChangePreferredContentSize:)
                                                 name:UIContentSizeCategoryDidChangeNotification object:nil];
    
    self.progress = [[Progress alloc] init];
    _HUDSingleTap = [[ProgressTapGestureRecognizer alloc]initWithTarget:self.progress action:@selector(singleTap:)];
    _HUDSingleTap.navigationController = self.navigationController;
    
    self.tvcMethods = [[TVCMethods alloc] init];
    self.tvcMethods.tableView = self.tableView;
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 80;
    self.title = @"Nominations";
    
    [self fetchData:@"" showMiddleSpinner:YES showToast:NO];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIContentSizeCategoryDidChangeNotification
                                                  object:nil];
}

- (void)refreshNominations {
    _nominations = [[NSMutableArray alloc] init];
    
    [self.tableView reloadData];
    
    [_refreshButton setEnabled:NO];
    [self.showMoreNominationsButton setEnabled:NO];
    [self disableRefreshControl];
    
    [[GlobalVars sharedInstance] clearNominationVars];
    
    [self fetchData:@"" showMiddleSpinner:YES showToast:NO];
}

- (void)showMoreNominationsAction {
    
    [self.showMoreNominationsButton setEnabled:NO];
    [_refreshButton setEnabled:NO];
    [self disableRefreshControl];
    [self fetchData:@"" showMiddleSpinner:NO showToast:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.navigationController.toolbarHidden = NO;
}

- (void)handleRefresh:(UIRefreshControl *)refreshControl {
    
    _refreshing = YES;
    _nominations = [[NSMutableArray alloc] init];
    
    [self.tableView reloadData];
    
    [_refreshButton setEnabled:NO];
    [self.showMoreNominationsButton setEnabled:NO];
    [[GlobalVars sharedInstance] clearNominationVars];
    
    [self fetchData:@"" showMiddleSpinner:YES showToast:NO];
}

- (void)fetchData:(NSString *)textString showMiddleSpinner:(BOOL) showMiddleSpinner showToast:(BOOL)showToast {
    
    if (showMiddleSpinner) {
        self.hud = [Progress showGlobalProgressHUDWithTitle:@"Loading..."];
        [self.hud addGestureRecognizer:_HUDSingleTap];
    }
    else if (showToast) {
        [self.view.window makeToast:@"Loading More Nominations..."
                           duration:0.5
                           position:CSToastPositionCenter];
    }
    
    [DataManager fetchNominations:^(NSArray *scanResult, NSError *error) {
        if (error != nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self.showMoreNominationsButton setEnabled:YES];
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
                    errorMessage = @"No More Nominations Found";
                    [self.showMoreNominationsButton setEnabled:NO];
                }
                else {
                    errorMessage = @"Error Connecting to Nominations";
                }
                
                [UIAlertController showAlertInViewController:self withTitle:@"Error" message:errorMessage cancelButtonTitle:@"OK" destructiveButtonTitle:nil otherButtonTitles:nil tapBlock:^(UIAlertController *controller, UIAlertAction *action, NSInteger buttonIndex) {
                    
                }];
                
            });
        }
        else {
            Nomination *nomination;
                        
            for (int i = 0; i < [scanResult count]; i++) {
                nomination = scanResult[i];
                                
                [self.nominations addObject:nomination];
            }
            
            self.nominations = [[NSMutableArray alloc] initWithArray:[self.nominations sortedArrayUsingDescriptors:@[[[NSSortDescriptor alloc] initWithKey:@"latest_action_date" ascending:NO]]]];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.tableView reloadData];
            [self.tableView layoutIfNeeded];
            
            if ([scanResult count] == 20) {
                [self.showMoreNominationsButton setEnabled:YES];
            }
            else {
                [self.showMoreNominationsButton setEnabled:NO];
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
    }];
}
    
- (BOOL)slideNavigationControllerShouldDisplayLeftMenu {
    return YES;
}

#pragma mark - Table view data source

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"NominationDetail" sender:nil];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.nominations count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DynamicTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NominationCell" forIndexPath:indexPath];
    
    NominationShort *nomination = self.nominations[indexPath.row];
    
    cell.label.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.label.text = nomination.nominee_description;
    
    return cell;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"NominationDetail"]) {
        
        NominationDetailTableViewController *vc = [segue destinationViewController];
        Nomination *nomination = self.nominations[[[self.tableView indexPathForSelectedRow] row]];
        
        vc.nomination = nomination;
        vc.title = nomination.nominee_description;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    if (self.showMoreNominationsButton.enabled && !self.refreshing) {
        if (scrollView.contentSize.height != 0 &&
            scrollView.contentOffset.y + scrollView.bounds.size.height - scrollView.contentInset.bottom >= scrollView.contentSize.height) {
            [self showMoreNominationsAction];
        }
    }
    else {
        self.refreshing = NO;
    }
}

@end
