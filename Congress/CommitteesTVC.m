//
//  CommitteesTVC.m
//  Congress
//
//  Created by ERIC on 9/22/15.
//  Copyright © 2015 Eric Panchenko. All rights reserved.
//

#import "CommitteesTVC.h"
#import "UIColor+Constants.h"

@interface CommitteesTVC ()

@end

@implementation CommitteesTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tvcMethods = [[TVCMethods alloc] init];
    self.tvcMethods.tableView = self.tableView;
    
    if (self.mode == (id)[NSNull null] || [self.mode length] == 0) {
        [[NSUserDefaults standardUserDefaults] setInteger:3 forKey:@"menuRow"];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self.tvcMethods
                                             selector:@selector(didChangePreferredContentSize:)
                                                 name:UIContentSizeCategoryDidChangeNotification object:nil];
        
    self.tableView.estimatedRowHeight = 80;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    self.progress = [[Progress alloc] init];
    
    self.committeeNameSort = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    
    self.HUDSingleTap = [[ProgressTapGestureRecognizer alloc]initWithTarget:self.progress action:@selector(singleTap:)];
    self.HUDSingleTap.navigationController = self.navigationController;
    
    if (self.mode == (id)[NSNull null] || self.mode.length == 0) {
        self.title = @"Committees";
        self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeAlways;
    }
    else {
        self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
        UILabel* tlabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0, self.navigationController.navigationBar.frame.size.width, self.navigationController.navigationBar.frame.size.height)];
        tlabel.text = self.navigationItem.title;
        tlabel.textAlignment = NSTextAlignmentCenter;
        tlabel.textColor = [UIColor colorNamed:@"BlackOrWhite"];
        tlabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size: 17.0];
        tlabel.backgroundColor = [UIColor clearColor];
        tlabel.adjustsFontSizeToFitWidth = YES;
        [tlabel setMinimumScaleFactor:10.0/tlabel.font.pointSize];
        self.navigationItem.titleView = tlabel;
    }
    
    [self fetchCommittees];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.navigationController.toolbarHidden = YES;
}

- (void) dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIContentSizeCategoryDidChangeNotification
                                                  object:nil];
}

- (BOOL)slideNavigationControllerShouldDisplayLeftMenu {
    
    if (self.mode == (id)[NSNull null] || self.mode.length == 0)
        return YES;
    
    return NO;
}
    
- (void) fetchCommittees {
    
    self.hud = [Progress showGlobalProgressHUDWithTitle:@"Loading..."];
    [self.hud addGestureRecognizer:self.HUDSingleTap];
    
    if ([self.mode isEqualToString:@"LegislatorCommittees"]) {
        [DataManager fetchCommittees:self.committees all:NO block:^(NSArray *scanResult, NSError *error) {

            if (error != nil) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [Progress dismissGlobalHUD];
                     [UIAlertController showAlertInViewController:self withTitle:@"Error" message:@"Unable to fetch committees." cancelButtonTitle:@"OK" destructiveButtonTitle:nil otherButtonTitles:nil tapBlock:^(UIAlertController *controller, UIAlertAction *action, NSInteger buttonIndex) {}];
                });
            }
            else {
                self.committees = scanResult;
                
                self.committeesReadyCount = [self.committees count];
                
                self.committees = [self.committees sortedArrayUsingDescriptors:@[self.committeeNameSort]];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                    [Progress dismissGlobalHUD];
                });                
            }
        }];

    }
    else if (self.mode == (id)[NSNull null] || self.mode.length == 0 ) {
        
        self.committees = [[NSArray alloc] init];
        
        [DataManager fetchCommittees:nil all:YES block:^(NSArray *scanResult, NSError *error) {
            
            NSMutableArray *tempArray = [[NSMutableArray alloc] init];
            
            if (error != nil) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [Progress dismissGlobalHUD];
                    
                    [UIAlertController showAlertInViewController:self withTitle:@"Error" message:@"Unable to fetch committees." cancelButtonTitle:@"OK" destructiveButtonTitle:nil otherButtonTitles:nil tapBlock:^(UIAlertController *controller, UIAlertAction *action, NSInteger buttonIndex) {}];
                });
            }
            
            for (int i = 0; i < [scanResult count]; i++) {
                                
                if ([[scanResult[i] subcommittee] isEqualToString:@"no"]) {
                    [tempArray addObject:scanResult[i]];
                }
            }
            
            scanResult = [tempArray copy];
            
            self.committees = [scanResult sortedArrayUsingDescriptors:@[self.committeeNameSort]];
            
            self.committeesReadyCount = [self.committees count];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
                [Progress dismissGlobalHUD];
            });
        }];
    }
    else { //subcommittees
        
        [DataManager fetchCommittees:self.committees all:NO block:^(NSArray *scanResult, NSError *error) {
            
            if (error != nil) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [Progress dismissGlobalHUD];
                    
                    [UIAlertController showAlertInViewController:self withTitle:@"Error" message:@"Unable to fetch committees." cancelButtonTitle:@"OK" destructiveButtonTitle:nil otherButtonTitles:nil tapBlock:^(UIAlertController *controller, UIAlertAction *action, NSInteger buttonIndex) {}];
                });
            }
            
            else if ([scanResult count] > 0) {
                self.committees = scanResult;
                
                self.committeesReadyCount = [self.committees count];
                
                self.committees = [self.committees sortedArrayUsingDescriptors:@[self.committeeNameSort]];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                    [Progress dismissGlobalHUD];
                });
            }
            else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                    [Progress dismissGlobalHUD];
                });
            }
        }];
        
    }
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.committeesReadyCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
        
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CommitteeCell" forIndexPath:indexPath];
    
    cell.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    
    Committee *committee = self.committees[indexPath.row];
        
    cell.textLabel.text = [committee.name capitalizedString];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //if (![self.mode isEqualToString:@"Subcommittees"]) {
        [self performSegueWithIdentifier:@"CommitteeDetail" sender:nil];
    //}
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"CommitteeDetail"]) {
        
        CommitteeDetailTableViewController *tvc = [segue destinationViewController];
        Committee *committee = self.committees[[[self.tableView indexPathForSelectedRow] row]];
        
        tvc.committee = committee;
        tvc.title = [committee.name capitalizedString];
    }
}


@end
