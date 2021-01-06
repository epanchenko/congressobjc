//
//  CommitteeDetailTableViewController.m
//  Congress
//
//  Created by Eric Panchenko on 8/7/16.
//  Copyright © 2016 Eric Panchenko. All rights reserved.
//

#import "CommitteeDetailTableViewController.h"


@interface CommitteeDetailTableViewController ()

@end

@implementation CommitteeDetailTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
    
    if (![RealmFunctions findFavCommittee:self.committee.committee_id]) {
        self.imageName = @"emptyStar";
    }
    else {
        self.imageName = @"filledStar";
    }
    
    UIButton *favButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [favButton setImage:[UIImage imageNamed:self.imageName] forState:UIControlStateNormal];
    favButton.showsTouchWhenHighlighted = YES;
    favButton.frame = CGRectMake(0.0, 3.0, 50,30);
    
    [favButton addTarget:self action:@selector(btnFavPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithCustomView:favButton];
    self.navigationItem. rightBarButtonItem = rightButton;
    UILabel* tlabel=[[UILabel alloc] initWithFrame:CGRectMake(0,0, self.navigationController.navigationBar.frame.size.width, self.navigationController.navigationBar.frame.size.height)];
    tlabel.text = self.navigationItem.title;
    tlabel.textAlignment = NSTextAlignmentCenter;
    tlabel.textColor = [UIColor colorNamed:@"BlackOrWhite"];
    tlabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size: 17.0];
    tlabel.backgroundColor = [UIColor clearColor];
    [tlabel setMinimumScaleFactor:10.0/tlabel.font.pointSize];
    tlabel.adjustsFontSizeToFitWidth = YES;
    self.navigationItem.titleView = tlabel;
    
    self.progress = [[Progress alloc] init];
    _HUDSingleTap = [[ProgressTapGestureRecognizer alloc]initWithTarget:self.progress action:@selector(singleTap:)];
    _HUDSingleTap.navigationController = self.navigationController;
    
    self.tvcMethods = [[TVCMethods alloc] init];
    self.tvcMethods.tableView = self.tableView;
    
    [[NSNotificationCenter defaultCenter] addObserver:self.tvcMethods
                                             selector:@selector(didChangePreferredContentSize:)
                                                 name:UIContentSizeCategoryDidChangeNotification object:nil];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 80;
    
    _HUDSingleTap = [[ProgressTapGestureRecognizer alloc]initWithTarget:self.progress action:@selector(singleTap:)];
    _HUDSingleTap.navigationController = self.navigationController;
}

- (void) btnFavPressed:(UIButton*)btnFav {
    if ([self.imageName isEqualToString:@"emptyStar"] ) {
        self.imageName = @"filledStar";
        [btnFav setImage:[UIImage imageNamed:@"filledStar.png"] forState:UIControlStateNormal];
        [RealmFunctions insertFavCommittee:self.committee.committee_id name:self.committee.name];
    }
    else {
        self.imageName = @"emptyStar";
        [btnFav setImage:[UIImage imageNamed:@"emptyStar.png"] forState:UIControlStateNormal];
        [RealmFunctions deleteFavCommittee:self.committee.committee_id];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIContentSizeCategoryDidChangeNotification
                                                  object:nil];
}

#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    int count = 2;
    
    if (!(self.committee.url == (id)[NSNull null] || self.committee.url.length == 0)) {
        count++;
    }
    
    return count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {
        [self performSegueWithIdentifier:@"CommitteeMembers" sender:nil];
    }
    else if (indexPath.row == 1) {
        [self performSegueWithIdentifier:@"Subcommittees" sender:nil];
    }
    else if (indexPath.row == 2 && (!(self.committee.url == (id)[NSNull null] || self.committee.url == 0)) ) {
        
        if ([[NSProcessInfo processInfo] operatingSystemVersion].majorVersion >= 9) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.committee.url]];
        }
        else {
            [self performSegueWithIdentifier:@"Webpage" sender:nil];
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 1) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CommitteeCell" forIndexPath:indexPath];
        
        cell.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
        cell.textLabel.text = @"Subcommittees";
                
        if ([self.committee.subcommittees count] > 0) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
            cell.userInteractionEnabled = YES;
            cell.textLabel.enabled = YES;
        }
        else {
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.userInteractionEnabled = NO;
            cell.textLabel.enabled = NO;
        }
        
        return cell;
    }
    else if (indexPath.row == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CommitteeCell" forIndexPath:indexPath];
        
        cell.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
        cell.textLabel.text = @"Members";
        
        if ([self.committee.currentMembers count] > 0) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
            cell.userInteractionEnabled = YES;
            cell.textLabel.enabled = YES;
        }
        else {
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.userInteractionEnabled = NO;
            cell.textLabel.enabled = NO;
        }
        return cell;
    }
    else if (indexPath.row == 2) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CommitteeCell" forIndexPath:indexPath];
        
        cell.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];

        cell.textLabel.text = @"Website";
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        if (!(self.committee.url == (id)[NSNull null] || self.committee.url.length == 0)) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        
        return cell;
    }
    
    else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CommitteeCell" forIndexPath:indexPath];
        
        cell.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
        
        return cell;
    }
}


// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"Webpage"]) {
        WebpageViewController *vc = [segue destinationViewController];
        
        vc.website = [NSURL URLWithString:self.committee.url];
        vc.title = @"Website";
    }
    
    else if ([segue.identifier isEqualToString:@"Subcommittees"]) {
        CommitteesTVC *vc = [segue destinationViewController];
        vc.committees = self.committee.subcommittees;
        vc.mode = @"Subcommittees";
        vc.title = [NSString stringWithFormat:@"Subcommittees of %@",self.title];
    }
    else if ([segue.identifier isEqualToString:@"CommitteeMembers"]) {
        LegislatorsViewController *vc = [segue destinationViewController];
        
        vc.currentCommitteeMembers = self.committee.currentMembers;
        vc.mode = @"CurrentCommitteeMembers";
        vc.title = [NSString stringWithFormat:@"Current Members of %@",self.title];
    }
}

@end
