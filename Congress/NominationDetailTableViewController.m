//
//  NominationDetailTableViewController.m
//  Congress
//
//  Created by ERIC on 8/9/16.
//  Copyright © 2016 Eric Panchenko. All rights reserved.
//

#import "NominationDetailTableViewController.h"


@interface NominationDetailTableViewController ()

@end

@implementation NominationDetailTableViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
    
    NSString *imageName;
    
    if (![RealmFunctions findFavNomination:self.nomination.nomination_id]) {
        imageName = @"emptyStar";
    }
    else {
        imageName = @"filledStar";
    }
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 80;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(handleRefresh:) forControlEvents:UIControlEventValueChanged];
    
    UIButton *favButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [favButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    favButton.showsTouchWhenHighlighted = YES;
    favButton.frame = CGRectMake(0.0, 3.0, 50,30);
    self.imageName = imageName;
    
    [favButton addTarget:self action:@selector(btnFavPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithCustomView:favButton];
    self.navigationItem. rightBarButtonItem = rightButton;
    
    UILabel* tlabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0, self.navigationController.navigationBar.frame.size.width, self.navigationController.navigationBar.frame.size.height)];
    tlabel.text = self.navigationItem.title;
    tlabel.textAlignment = NSTextAlignmentCenter;
    tlabel.textColor = [UIColor colorNamed:@"BlackOrWhite"];
    tlabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size: 17.0];
    tlabel.backgroundColor = [UIColor clearColor];
    tlabel.adjustsFontSizeToFitWidth = YES;
    [tlabel setMinimumScaleFactor:10.0/tlabel.font.pointSize];
    self.navigationItem.titleView = tlabel;
    
    self.progress = [[Progress alloc] init];
    _HUDSingleTap = [[ProgressTapGestureRecognizer alloc]initWithTarget:self.progress action:@selector(singleTap:)];
    _HUDSingleTap.navigationController = self.navigationController;
    
    self.tvcMethods = [[TVCMethods alloc] init];
    self.tvcMethods.tableView = self.tableView;
    
    [[NSNotificationCenter defaultCenter] addObserver:self.tvcMethods
                                             selector:@selector(didChangePreferredContentSize:)
                                                 name:UIContentSizeCategoryDidChangeNotification object:nil];
    
    [self fetchData:YES];
}

- (void)handleRefresh:(UIRefreshControl *)refreshControl {
    
    [self fetchData:NO];
    [self.tableView layoutIfNeeded];
    [refreshControl endRefreshing];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.navigationController.toolbarHidden = YES;
}

- (void) btnFavPressed:(UIButton*)btnFav {
    if ([self.imageName isEqualToString:@"emptyStar"] ) {
        self.imageName = @"filledStar";
        [btnFav setImage:[UIImage imageNamed:@"filledStar.png"] forState:UIControlStateNormal];
        
        [RealmFunctions insertFavNomination:self.nomination.nomination_id title:self.title];
    }
    else {
        self.imageName = @"emptyStar";
        [btnFav setImage:[UIImage imageNamed:@"emptyStar.png"] forState:UIControlStateNormal];
        [RealmFunctions deleteFavNomination:self.nomination.nomination_id];
    }
}
- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIContentSizeCategoryDidChangeNotification
                                                  object:nil];
}

- (void)fetchData:(BOOL)showProgress {
    
    self.hud = [Progress showGlobalProgressHUDWithTitle:@"Loading..."];
    [self.hud addGestureRecognizer:_HUDSingleTap];
    
    if (self.nomination == nil)
        [DataManager fetchNominationID:self.nomination_id block:^(Nomination *nomination, NSError *error) {
            
            if (error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [Progress dismissGlobalHUD];
                    
                    [UIAlertController showAlertInViewController:self withTitle:@"Error" message:@"Unable to fetch nomination detail" cancelButtonTitle:@"OK" destructiveButtonTitle:nil otherButtonTitles:nil tapBlock:^(UIAlertController *controller, UIAlertAction *action, NSInteger buttonIndex) {}];
                });
            }
            else {
                self.nomination = nomination;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                    [Progress dismissGlobalHUD];
                });
            }
        }];
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
                [Progress dismissGlobalHUD];
            });
        }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 8;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 1 && ![self.nomination.committee_id isEqualToString:@""]) {
        
        [DataManager fetchCommittees:@[self.nomination.committee_id] all:NO block:^(NSArray *scanResult, NSError *error) {
            
            if ([scanResult count] > 0) {
                self.committee = scanResult[0];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self performSegueWithIdentifier:@"CommitteesSegue" sender:nil];
                });
            }
            else {                
                [DataManager fetchCommittees:nil all:YES block:^(NSArray *scanResult2, NSError *error2) {
                    
                    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
                    
                    if (error2 != nil) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                            [Progress dismissGlobalHUD];
                            
                            [UIAlertController showAlertInViewController:self withTitle:@"Error" message:@"Unable to fetch committee." cancelButtonTitle:@"OK" destructiveButtonTitle:nil otherButtonTitles:nil tapBlock:^(UIAlertController *controller, UIAlertAction *action, NSInteger buttonIndex) {}];
                        });
                    }
                    
                    for (int i = 0; i < [scanResult2 count]; i++) {
                        
                        if ([[scanResult2[i] committee_id] isEqualToString:self.nomination.committee_id]) {
                            [tempArray addObject:scanResult2[i]];
                        }
                    }
                    
                    if ([tempArray count] > 0) {
                        self.committee = tempArray[0];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self performSegueWithIdentifier:@"CommitteesSegue" sender:nil];
                        });
                    }
                }];
            }
        }];
    }
    else if (indexPath.row == 2) {
        [self performSegueWithIdentifier:@"ActionsSegue" sender:nil];
    }
    else if (indexPath.row == 3) {
        [self performSegueWithIdentifier:@"VotesSegue" sender:nil];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {
        
        DynamicTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DynamicCell" forIndexPath:indexPath];
        
        cell.label.text = self.nomination.nominee_description;
        cell.label.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];

        return cell;
    }
    else if (indexPath.row == 1) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NominationCell" forIndexPath:indexPath];
        
        if (![self.nomination.committee_id isEqualToString:@""] && self.nomination.committee_id != nil) {
            cell.textLabel.enabled = YES;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.userInteractionEnabled = YES;
        }
        else {
            cell.textLabel.enabled = NO;
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.userInteractionEnabled = false;
        }
        
        cell.textLabel.text = @"Committee";
        cell.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
        
        return cell;
    }
    else if (indexPath.row == 2) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NominationCell" forIndexPath:indexPath];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.text = @"Actions";
        cell.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
        
        return cell;
    }
    else if (indexPath.row == 3) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NominationCell" forIndexPath:indexPath];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.text = @"Votes";
        cell.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
        
        NSString *searchID;
        
        if (self.nomination == nil) {
            searchID = self.nomination_id;
        }
        else {
            searchID = self.nomination.nomination_id;
        }
                
        [DataManager votesExistForNominationID:searchID block:^(BOOL votesExist) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if (!votesExist) {
                    cell.userInteractionEnabled = false;
                    cell.textLabel.enabled = false;
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
                else {
                    cell.userInteractionEnabled = true;
                    cell.textLabel.enabled = true;
                }
            });
        }];
        
        return cell;
    }
    else if (indexPath.row == 6) {
        
        DynamicTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DynamicCell" forIndexPath:indexPath];
        
        cell.accessoryType = UITableViewCellAccessoryNone;
        if (!(self.nomination.actions[0] == (id)[NSNull null] || self.nomination.actions[0] == 0)) {
            
            Action *action;
            NSArray *fields;
            NSMutableArray *mutableActions = [[NSMutableArray alloc] init];
            
            for (int i = 0; i < [self.nomination.actions count]; i++) {
                action = [[Action alloc] init];
                fields = [self.nomination.actions[i] componentsSeparatedByString:@"@"];
                action.action_id = [fields[0] intValue];
                action.acted_at = fields[1];
                action.text = fields[2];
                
                [mutableActions addObject:action];
            }
            
            [mutableActions sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"action_id" ascending:YES]]];
            
            action = mutableActions[0];
            cell.label.text = [NSString stringWithFormat:@"Last Action:\n%@\n%@",action.acted_at,action.text];
        }
        cell.label.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        
        return cell;
    }
    else if (indexPath.row == 5) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NominationCell" forIndexPath:indexPath];
        cell.accessoryType = UITableViewCellAccessoryNone;
        if (!(self.nomination.status == (id)[NSNull null] || self.nomination.status == 0)) {
            cell.textLabel.text = [NSString stringWithFormat:@"Status: %@",self.nomination.status];
        }
        cell.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        
        return cell;
    }
    else if (indexPath.row == 4) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NominationCell" forIndexPath:indexPath];
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        if (!(self.nomination.congress == (id)[NSNull null] || self.nomination.congress == 0)) {
            cell.textLabel.text = [NSString stringWithFormat:@"Congress: %@",self.nomination.congress];
        }
        cell.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        return cell;
    }
    
    else  {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NominationCell" forIndexPath:indexPath];
        cell.accessoryType = UITableViewCellAccessoryNone;
        if (!(self.nomination.date_received == (id)[NSNull null] || self.nomination.date_received == 0)) {
            cell.textLabel.text = [NSString stringWithFormat:@"Received On: %@",self.nomination.date_received];
        }
        cell.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        
        return cell;
    }
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"CommitteesSegue"]) {
        CommitteeDetailTableViewController *tvc = [segue destinationViewController];
        tvc.committee = self.committee;
        tvc.title = [self.committee.name capitalizedString];
    }
    else if ([segue.identifier isEqualToString:@"ActionsSegue"]) {
        ActionTableViewController *tvc = [segue destinationViewController];
        tvc.title = self.title;
        tvc.mode = @"Nomination";
        tvc.uncompressedActions = self.nomination.actions;
    }
    else if ([segue.identifier isEqualToString:@"VotesSegue"]) {
        VotesTVC *vc = [segue destinationViewController];
        vc.nomination_id = self.nomination.nomination_id;
        vc.title = self.title;
        vc.mode = @"Nomination";
    }
}

@end
