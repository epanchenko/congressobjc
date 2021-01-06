//
//  BillDetailTableViewController.m
//  Congress
//
//  Created by ERIC on 7/23/16.
//  Copyright © 2016 Eric Panchenko. All rights reserved.
//

#import "BillDetailTableViewController.h"

@interface BillDetailTableViewController ()

@end

@implementation BillDetailTableViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
    
    
    NSString *imageName;
    
    if (![RealmFunctions findFavBill:self.bill.bill_id]) {
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
                
        [RealmFunctions insertFavBill:self.bill.bill_id name:self.title];
    }
    else {
        self.imageName = @"emptyStar";
        [btnFav setImage:[UIImage imageNamed:@"emptyStar.png"] forState:UIControlStateNormal];
        [RealmFunctions deleteFavBill:self.bill.bill_id];
    }
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIContentSizeCategoryDidChangeNotification
                                                  object:nil];
    
    if (self.filePath != nil) {
        NSFileManager *fileMgr = [NSFileManager defaultManager];
        [fileMgr removeItemAtPath:self.filePath error:NULL];
    }
}

- (void)fetchData:(BOOL)showProgress {
    
    if (showProgress) {
        self.hud = [Progress showGlobalProgressHUDWithTitle:@"Loading..."];
        [self.hud addGestureRecognizer:_HUDSingleTap];
    }
    
    if (self.bill == nil)
    [DataManager fetchBillID:self.bill_id block:^(Bill *bill, NSError *error) {
        
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [Progress dismissGlobalHUD];
            
                [UIAlertController showAlertInViewController:self withTitle:@"Error" message:@"Unable to fetch bill detail" cancelButtonTitle:@"OK" destructiveButtonTitle:nil otherButtonTitles:nil tapBlock:^(UIAlertController *controller, UIAlertAction *action, NSInteger buttonIndex) {}];
            });
        }
        else {
            self.bill = bill;
                        
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

- (void)openBill {
    
    NSURL  *url2 = [NSURL URLWithString:self.bill.text_url];
        
    NSURLSessionDataTask *downloadTask = [[NSURLSession sharedSession]
                                          dataTaskWithURL:url2 completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                              
          if (data) {
              
              NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
              NSString *cachesDirectory = [paths objectAtIndex:0];
              
              NSArray *fileArray = [self.bill.text_url componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"/"]];
              
              self.filePath = [NSString stringWithFormat:@"%@/%@", cachesDirectory,fileArray[[fileArray count] - 1]];
              
              [data writeToFile:self.filePath atomically:YES];
              
              ReaderDocument *document = [[ReaderDocument alloc] initWithFilePath:self.filePath password:nil];
              
              dispatch_async(dispatch_get_main_queue(), ^{
                  [Progress dismissGlobalHUD];
              });

              if (document != nil) {
                  ReaderViewController *readerViewController = [[ReaderViewController alloc] initWithReaderDocument:document];
                  
                  readerViewController.delegate = self;
                  readerViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
                  readerViewController.modalPresentationStyle = UIModalPresentationFullScreen;
                  
                  dispatch_async(dispatch_get_main_queue(), ^{
                      [self presentViewController:readerViewController animated:YES completion:NULL];
                  });
              }
          }
          else {
              dispatch_async(dispatch_get_main_queue(), ^{
                  [Progress dismissGlobalHUD];
                  [UIAlertController showAlertInViewController:self withTitle:@"Error" message:@"Error Opening Bill Text" cancelButtonTitle:@"OK" destructiveButtonTitle:nil otherButtonTitles:nil tapBlock:^(UIAlertController *controller, UIAlertAction *action, NSInteger buttonIndex) {
                      
                  }];
              });
          }
      }];
    
    [downloadTask resume];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {
        
        if ([self.bill.text_url hasSuffix:@"pdf"]) {
            self.hud = [Progress showGlobalProgressHUDWithTitle:@"Loading..."];
            [self.hud addGestureRecognizer:_HUDSingleTap];
            [self openBill];
        }
        else if ([self.bill.text_url hasSuffix:@"text"]){
            [self performSegueWithIdentifier:@"WebpageSegue" sender:nil];
        }
    }
    else if (indexPath.row == 1) {
        [self performSegueWithIdentifier:@"BillSummarySegue" sender:nil];
    }
    else if (indexPath.row == 2) {
        [self performSegueWithIdentifier:@"ActionsSegue" sender:nil];
    }
    else if (indexPath.row == 3) {
        [self performSegueWithIdentifier:@"VotesSegue" sender:nil];
    }
    else if (indexPath.row == 4) {
        [self performSegueWithIdentifier:@"AmendmentsSegue" sender:nil];
    }
    else if (indexPath.row == 5) {
        [self performSegueWithIdentifier:@"CommitteesSegue" sender:nil];
    }
}

- (void)dismissReaderViewController:(ReaderViewController *)viewController {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 9;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BillDetailCell" forIndexPath:indexPath];
    
    if (indexPath.row == 0) {
        
        if (self.bill.text_url == (id)[NSNull null] || self.bill.text_url == 0) {
            cell.userInteractionEnabled = false;
            cell.textLabel.enabled = false;
        }
        else {
            cell.userInteractionEnabled = true;
            cell.textLabel.enabled = true;
        }
                
        cell.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
        cell.textLabel.text = @"Bill Text";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else if (indexPath.row == 1) {
                
        if ([self.bill.summary isEqualToString:@""]) {
            cell.userInteractionEnabled = false;
            cell.textLabel.enabled = false;
        }
        else {
            cell.userInteractionEnabled = true;
            cell.textLabel.enabled = true;
        }
        
        cell.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
        cell.textLabel.text = @"Summary";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else if (indexPath.row == 2) {
        
        if ([self.bill.actions count] == 0) {
            cell.userInteractionEnabled = false;
            cell.textLabel.enabled = false;
        }
        else {
            cell.userInteractionEnabled = true;
            cell.textLabel.enabled = true;
        }

        cell.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
        cell.textLabel.text = @"Actions";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    else if (indexPath.row == 3) {
        cell.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
        cell.textLabel.text = @"Votes";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        NSString *searchID;
        
        if (self.bill == nil) {
            searchID = self.bill_id;
        }
        else {
            searchID = self.bill.bill_id;
        }
                
        [DataManager votesExistForBillID:searchID block:^(BOOL votesExist) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if (!votesExist) {
                    cell.userInteractionEnabled = false;
                    cell.textLabel.enabled = false;
                }
                else {
                    cell.userInteractionEnabled = true;
                    cell.textLabel.enabled = true;
                }
            });
        }];
    }

    else if (indexPath.row == 4) {
        cell.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
        cell.userInteractionEnabled = false;
        cell.textLabel.enabled = false;
        
        if ([self.bill.amendments count] > 0) {
            cell.userInteractionEnabled = true;
            cell.textLabel.enabled = true;
        }
        
        cell.textLabel.text = @"Amendments";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    else if (indexPath.row == 5) {
        cell.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
        cell.userInteractionEnabled = false;
        cell.textLabel.enabled = false;
        
        if ([self.bill.committee_ids count] > 0) {
            cell.userInteractionEnabled = true;
            cell.textLabel.enabled = true;
        }
        
        cell.textLabel.text = @"Committees";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    else if (indexPath.row == 6) {
        if (!(self.bill.congress == (id)[NSNull null] || self.bill.congress == 0)) {
            cell.textLabel.text = [NSString stringWithFormat:@"Congress: %@",self.bill.congress];
        }
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    }
    else if (indexPath.row == 7) {
        if (!(self.bill.introduced_date == (id)[NSNull null] || self.bill.introduced_date == 0)) {
            cell.textLabel.text = [NSString stringWithFormat:@"Introduced: %@",self.bill.introduced_date];
        }
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    }
    else if (indexPath.row == 8) {
        
        DynamicTableViewCell *cell2 = [tableView dequeueReusableCellWithIdentifier:@"SummaryCell" forIndexPath:indexPath];
        
        if (!(self.bill.actions.count == 0 || self.bill.actions[0] == (id)[NSNull null] || self.bill.actions[0] == 0)) {
            
            Action *action;
            NSArray *fields;
            NSMutableArray *mutableActions = [[NSMutableArray alloc] init];
            
            for (int i = 0; i < [self.bill.actions count]; i++) {
                action = [[Action alloc] init];
                fields = [self.bill.actions[i] componentsSeparatedByString:@"@"];
                action.action_id = [fields[0] intValue];
                action.acted_at = fields[1];
                action.text = [NSString stringWithFormat:@"%@\n%@",fields[2],fields[3]];
                
                [mutableActions addObject:action];
            }
            
            [mutableActions sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"action_id" ascending:NO]]];
            
            action = mutableActions[0];
            cell2.label.text = [NSString stringWithFormat:@"Last Action:\n%@\n%@",action.acted_at,action.text];
        }
        else {
            cell2.label.text = @"\n\n";
            
        }
        
        cell2.userInteractionEnabled = false;
        cell2.textLabel.enabled = false;
        cell2.accessoryType = UITableViewCellAccessoryNone;
        cell2.label.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        
        
        return cell2;
    }
    
    return cell;
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"BillSummarySegue"]) {
        SummaryViewController *vc = [segue destinationViewController];
        vc.title = self.title;
        vc.summary = self.bill.summary;
    }
    else if ([segue.identifier isEqualToString:@"ActionsSegue"]) {
        ActionTableViewController *vc = [segue destinationViewController];
        vc.uncompressedActions = self.bill.actions;
        vc.title = self.title;
        vc.mode = @"Bill";
    }
    else if ([segue.identifier isEqualToString:@"VotesSegue"]) {
        VotesTVC *vc = [segue destinationViewController];
        vc.bill_id = self.bill.bill_id;
        vc.title = self.title;
        vc.mode = @"Bill";
    }
    else if ([segue.identifier isEqualToString:@"AmendmentsSegue"]) {
        AmendmentsTVC *vc = [segue destinationViewController];
        
        NSSortDescriptor *sortDescriptor;
        sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"number"
                                                     ascending:NO];
        
        vc.amendments = [self.bill.amendments sortedArrayUsingDescriptors:@[sortDescriptor]];
        vc.title = self.title;
    }
    else if ([segue.identifier isEqualToString:@"CommitteesSegue"]) {
        CommitteesTVC *vc = [segue destinationViewController];
        vc.committees = self.bill.committee_ids;
        vc.title = self.title;
        vc.mode = @"LegislatorCommittees";
    }
    else if ([segue.identifier isEqualToString:@"WebpageSegue"]) {
        WebpageViewController *vc = [segue destinationViewController];
        vc.website = [[NSURL alloc] initWithString:self.bill.text_url];
        vc.title = self.bill.official_title;
    }
}

@end
