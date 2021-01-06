//
//  LegislatorVotesTableViewController.m
//  Congress
//
//  Created by Eric Panchenko on 5/22/16.
//  Copyright © 2016 Eric Panchenko. All rights reserved.
//

#import "LegislatorVotesTableViewController.h"
#import "UIView+Toast.h"

@interface LegislatorVotesTableViewController ()

@end

@implementation LegislatorVotesTableViewController


Vote *currentVote;

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

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self.tvcMethods
                                             selector:@selector(didChangePreferredContentSize:)
                                                 name:UIContentSizeCategoryDidChangeNotification object:nil];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"LegislatorVoteCell" bundle:nil] forCellReuseIdentifier:@"Vote"];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 80;
    
    self.progress = [[Progress alloc] init];
    
    self.HUDSingleTap = [[ProgressTapGestureRecognizer alloc]initWithTarget:self.progress action:@selector(singleTap:)];
    self.HUDSingleTap.navigationController = self.navigationController;
    
    [self executeEndPointAsync:YES showToast:NO];
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

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.navigationController.toolbarHidden = NO;
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

- (void) executeEndPointAsync:(BOOL)showMiddleSpinner showToast:(BOOL)showToast {
    
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
        
    [DataManager fetchLegislatorVotesChamber:self.chamber legislatorID:self.bioguide_id block:^(NSArray *scanResult, NSError *error) {
        
        if (error) {
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
                
                [UIAlertController showAlertInViewController:self withTitle:@"Error" message:[error localizedDescription] cancelButtonTitle:@"OK" destructiveButtonTitle:nil otherButtonTitles:nil tapBlock:^(UIAlertController *controller, UIAlertAction *action, NSInteger buttonIndex) {
                    
                }];
            });
        }
        else {
            self.votes = [[NSMutableArray alloc] init];
            
            for (int i = 0; i < [scanResult count]; i++) {
                
                [self.votes addObject:scanResult[i]];
            }
            
            NSMutableArray *array;
            
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
        
        vc.roll_id = currentVote.roll_id;
        vc.bill_id = currentVote.bill_id;
        vc.chamber = currentVote.chamber;
        vc.nomination_id = currentVote.nomination_id;
        vc.vote = currentVote;
        vc.title = [currentVote bill_title];
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
    
    NSArray* sortedArray = [[self.votesDict allKeys] sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:nil ascending:NO selector:@selector(localizedCompare:)]]];

    NSString *key = [sortedArray objectAtIndex:indexPath.section];
    
    NSArray *array = self.votesDict[key];
    
    currentVote = (Vote*)array[indexPath.row];
    
    [self performSegueWithIdentifier:@"LegislatorVoteDetailSegue" sender:nil];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    LegislatorVoteCellTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Vote" forIndexPath:indexPath];
    
    NSArray* sortedArray = [[self.votesDict allKeys] sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:nil ascending:NO selector:@selector(localizedCompare:)]]];
    
    cell.billTitle.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    
    NSString *key = [sortedArray objectAtIndex:indexPath.section];
    NSArray *array = self.votesDict[key];
    
    cell.question.text = [array[indexPath.row] question];
    cell.question.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    cell.billTitle.text = [array[indexPath.row] bill_title];
    
    NSString *voteCast = [array[indexPath.row] voteCast];
    NSString *voteS;
    NSRange range;
    NSMutableAttributedString *voteString;
    
    if (!([voteCast isEqualToString:@"No Vote"])) {
        voteS = [NSString stringWithFormat:@"Voted %@: %@",
                 voteCast, [array[indexPath.row] result]];
        range = [voteS rangeOfString:[NSString stringWithFormat:@"Voted %@:", voteCast]];
        voteString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"Voted %@: %@", voteCast, [array[indexPath.row] result]]];
    }
    else {
        voteS = [NSString stringWithFormat:@"%@: %@",
                 voteCast, [array[indexPath.row] result]];
        range = [voteS rangeOfString:[NSString stringWithFormat:@"%@:", voteCast]];
        voteString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@: %@", voteCast, [array[indexPath.row] result]]];
    }
    
    UIColor *color;
    
    if ([voteCast isEqualToString:@"Yea"]) {
        color = [UIColor colorWithRed:0.02 green:0.44 blue:0.11 alpha:1.0];
    }
    else if ([voteCast isEqualToString:@"Nay"]) {
        color = [UIColor redColor];
    }
    else {
        color = [UIColor grayColor];
    }
    
    [voteString addAttribute:NSForegroundColorAttributeName
                   value:color
                   range:range];
    
    cell.resultLabel.attributedText = voteString;
    cell.resultLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    if (self.showMoreVotesButton.enabled
        && !self.refreshing &&
        scrollView.contentSize.height != 0 &&
        scrollView.contentOffset.y + scrollView.bounds.size.height - scrollView.contentInset.bottom >= scrollView.contentSize.height) {
        [self showMoreVotesAction];
    }
    else self.refreshing = NO;
}


@end
