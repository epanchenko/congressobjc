//
//  LegislatorDetailVC.m
//  Congress
//
//  Created by Eric Panchenko on 9/15/15.
//  Copyright © 2015 Eric Panchenko. All rights reserved.
//

#import "LegislatorDetailVC.h"


@interface LegislatorDetailVC ()

@end

@implementation LegislatorDetailVC


UIImage *image;
NSHTTPURLResponse *httpResponse4;
int headerRow = 0, biographyRow = 1, mapRow = 2, committeesRow = 3, contactRow = 4, termsRow = 5, votes = 6;

dispatch_group_t group1;
    
- (void) checkFlags {
    
   dispatch_group_notify(group1, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
       
       dispatch_async(dispatch_get_main_queue(), ^{
           [Progress dismissGlobalHUD];
           [self.tableView reloadData];
           if (self.favorite) {
               self.favorite = NO;
               [self performSegueWithIdentifier:@"LegislatorFavoriteVotes" sender:nil];
           }
       });
   });
}

- (void) btnFavPressed:(UIButton*)btnFav {
    if ([self.imageName isEqualToString:@"emptyStar"] ) {
        self.imageName = @"filledStar";
        [btnFav setImage:[UIImage imageNamed:@"filledStar.png"] forState:UIControlStateNormal];
                
        [RealmFunctions insertFavLegislator:self.legislator.bioguide_id name:[NSString stringWithFormat:@"%@, %@",self.legislator.last_name,self.legislator.first_name]];
    }
    else {
        self.imageName = @"emptyStar";
        [btnFav setImage:[UIImage imageNamed:@"emptyStar.png"] forState:UIControlStateNormal];
        [RealmFunctions deleteFavLegislator:_legislator.bioguide_id];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
    
    NSString *imageName;
        
    if (![RealmFunctions findFavLegislator:_legislator.bioguide_id]) {
        imageName = @"emptyStar";
    }
    else {
        imageName = @"filledStar";
    }
    
    UIButton *favButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [favButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    favButton.showsTouchWhenHighlighted = YES;
    favButton.frame = CGRectMake(0.0, 3.0, 50,30);
    self.imageName = imageName;
    
    [favButton addTarget:self action:@selector(btnFavPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithCustomView:favButton];
    self.navigationItem.rightBarButtonItem = rightButton;
    
    self.progress = [[Progress alloc] init];
    _HUDSingleTap = [[ProgressTapGestureRecognizer alloc]initWithTarget:self.progress action:@selector(singleTap:)];
    _HUDSingleTap.navigationController = self.navigationController;

    _HUDSingleTap = [[ProgressTapGestureRecognizer alloc]initWithTarget:self.progress action:@selector(singleTap:)];
    _HUDSingleTap.navigationController = self.navigationController;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"LegislatorHeaderCell" bundle:nil] forCellReuseIdentifier:@"LegislatorHeaderCell"];
    
    self.tableView.estimatedRowHeight = 50.0f;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didChangePreferredContentSize:)
                                                 name:UIContentSizeCategoryDidChangeNotification object:nil];
    
    [self fetchLegislator];
        
    [self fetchImage:_legislator.bioguide_id];
    
    //don't show blank cells at bottom
    self.tableView.tableFooterView = [UIView new];    
    self.tableView.contentInset = UIEdgeInsetsMake(15, 0, 0, 0);
    

}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIContentSizeCategoryDidChangeNotification
                                                  object:nil];
    _legislator = nil;
    
    if (self.filePath != nil) {
        NSFileManager *fileMgr = [NSFileManager defaultManager];
        [fileMgr removeItemAtPath:self.filePath error:NULL];
    }
}

- (void)didChangePreferredContentSize:(NSNotification *)notification {
    [self.tableView reloadData];
}

- (void) fetchLegislator {
    
    group1 = dispatch_group_create();
    
    dispatch_group_enter(group1);
    dispatch_group_leave(group1);
    
    [self checkFlags];
}

- (void) fetchImage:(NSString *)bioguideID {
    
    dispatch_group_enter(group1);
    
    image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString: [NSString stringWithFormat:@"%@%@.jpg",@"https://theunitedstates.io/images/congress/225x275/",bioguideID]]]];
    
    dispatch_group_leave(group1);
    
    [self checkFlags];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 7;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == mapRow) {
        
        NSString *districtString;
        
        if ([_legislator.district isKindOfClass:[NSNull class]] || [_legislator.district intValue] == 0) {
            self.mapURL = [NSString stringWithFormat:@"http://www2.census.gov/geo/maps/cong_dist/cd114/st_based/CD114_%@.pdf",[_legislator.state uppercaseString]];
        }
        else {
            
            if ([_legislator.district intValue] < 10 ) {
                districtString = [NSString stringWithFormat:@"0%d",[_legislator.district intValue]];
            }
            else {
                districtString = [NSString stringWithFormat:@"%d",[_legislator.district intValue]];
            }
            
            self.mapURL = [NSString stringWithFormat:@"http://gis.govtrack.us/boundaries/cd-2012/%@-%@/shape?format=json",[_legislator.state lowercaseString],districtString];
        }
        
        self.hud = [Progress showGlobalProgressHUDWithTitle:@"Loading..."];
        [self.hud addGestureRecognizer:_HUDSingleTap];
        
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == headerRow) {
        
        LegislatorHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LegislatorHeaderCell" forIndexPath:indexPath];
        
        cell.legislatorImageView.image = image;
        cell.nameLabel.text = @"";
        cell.roleLabel.text = @"";
        cell.name2Label.text = @"";
        cell.nextElectionLabel.text = @"";
        
        if (_legislator.middle_name == (id)[NSNull null] || [_legislator.middle_name length] == 0) {
            if (!(_legislator.first_name == (id)[NSNull null] || [_legislator.first_name length] == 0) &&
                !(_legislator.last_name == (id)[NSNull null] || [_legislator.last_name length] == 0))
                cell.nameLabel.text = [NSString stringWithFormat:@" %@ %@",_legislator.first_name,_legislator.last_name];
        }
        else {
            if (!(_legislator.first_name == (id)[NSNull null] || [_legislator.first_name length] == 0) &&
                !(_legislator.last_name == (id)[NSNull null] || [_legislator.last_name length] == 0))
                cell.nameLabel.text = [NSString stringWithFormat:@" %@ %@ %@",_legislator.first_name,_legislator.middle_name,_legislator.last_name];
        }

        
        if ([_legislator.title isEqualToString:@"Rep"]) {
            cell.roleLabel.text = [NSString stringWithFormat:@" Representative (%@)",_legislator.party];
        }
        else if ([_legislator.title isEqualToString:@"Sen"]) {
            cell.roleLabel.text = [NSString stringWithFormat:@" Senator (%@)",_legislator.party];
        }
        else if ([_legislator.title isEqualToString:@"Del"]) {
            cell.roleLabel.text = [NSString stringWithFormat:@" Delegate (%@)",_legislator.party];
        }
        
        if (_legislator.district == (id)[NSNull null] || [_legislator.district intValue] == 0) {
            if (!(_legislator.state_name == (id)[NSNull null] || [_legislator.state_name length] == 0))
                cell.name2Label.text = [NSString stringWithFormat:@" %@",_legislator.state_name];
        }
        else if (!(_legislator.state_name == (id)[NSNull null] || [_legislator.state_name length] == 0))
            cell.name2Label.text = [NSString stringWithFormat:@" %@ - District %@",_legislator.state_name,_legislator.district];
        
        int year = [[NSString stringWithFormat:@"%@",[_legislator.date_of_birth substringWithRange:NSMakeRange(0,4)]] intValue];
        NSDate *today = [[NSDate alloc] init];
        
        NSCalendar* calendar = [NSCalendar currentCalendar];
        NSDateComponents* components = [calendar components:NSCalendarUnitYear fromDate:today];
        
        if (year != 0) {
            cell.nextElectionLabel.text = [NSString stringWithFormat:@" Age: %ld",(long)[components year] - year];
        }
        
        cell.nextElectionLabel.text = [NSString stringWithFormat:@"%@ Next Election: %@",cell.nextElectionLabel.text,_legislator.next_election];

        cell.nameLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
        cell.roleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
        cell.name2Label.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
        cell.nextElectionLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
        
        cell.nameLabel.adjustsFontSizeToFitWidth = YES;
        cell.roleLabel.adjustsFontSizeToFitWidth = YES;
        cell.name2Label.adjustsFontSizeToFitWidth = YES;
        cell.nextElectionLabel.adjustsFontSizeToFitWidth = YES;
        
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        return cell;
    }
    
    else if (indexPath.row == biographyRow) {
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LegislatorBioCell" forIndexPath:indexPath];
        cell.textLabel.text = @"Biography";
        cell.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        return cell;
    }

    else if (indexPath.row == mapRow) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LegislatorMapCell" forIndexPath:indexPath];
        cell.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
        cell.textLabel.text = @"Constituents Map";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        return cell;
    }
    else if (indexPath.row == committeesRow) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CommitteesCell" forIndexPath:indexPath];
        
        if (_legislator.committees == (id)[NSNull null] || [_legislator.committees count] == 0) {
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.textLabel.enabled = NO;
            cell.userInteractionEnabled = false;
        }
        else {
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.textLabel.enabled = YES;
            cell.userInteractionEnabled = YES;
        }

        cell.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
        cell.textLabel.text = @"Committees";
        
        return cell;
    }
    
    else if (indexPath.row == contactRow) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ContactCell" forIndexPath:indexPath];
        cell.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
        cell.textLabel.text = @"Contact";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        return cell;
    }
    
    else if (indexPath.row == termsRow) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TermsLabelCell" forIndexPath:indexPath];
        cell.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
        //cell.textLabel.textColor = [UIColor colorNamed:@"BlackOrWhite"];
        cell.textLabel.text = @"Terms";
        
        if (_legislator.terms == (id)[NSNull null] || [_legislator.terms count] == 0) {
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.textLabel.enabled = NO;
            cell.userInteractionEnabled = false;
        }
        else {
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.textLabel.enabled = YES;
            cell.userInteractionEnabled = YES;
        }
        
        return cell;
    }
    
    else /*if (indexPath.row == votes)*/ {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"VotesCell" forIndexPath:indexPath];
        cell.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
        cell.textLabel.text = @"Votes";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                
        return cell;
    }
}

-(BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    
    if (action == @selector(copy:) &&
        indexPath.row == 0) {
        return YES;
    }
    
    return NO;
}

-(void)tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    
    UIPasteboard* pasteboard = [UIPasteboard generalPasteboard];
    NSString *name1, *name2, *role, *birthday;
    
    if (indexPath.row == headerRow) {

        if ([_legislator.middle_name isKindOfClass:[NSNull class]]) {
            name1 = [NSString stringWithFormat:@" %@ %@",_legislator.first_name,_legislator.last_name];
        }
        else {
            name1 = [NSString stringWithFormat:@" %@ %@ %@",_legislator.first_name,_legislator.middle_name,_legislator.last_name];
        }

        if ([_legislator.title isEqualToString:@"Rep"]) {
            role = [NSString stringWithFormat:@" Representative (%@)",_legislator.party];
        }
        else if ([_legislator.title isEqualToString:@"Sen"]) {
            role = [NSString stringWithFormat:@" Senator (%@)",_legislator.party];
        }
        else if ([_legislator.title isEqualToString:@"Del"]) {
            role = [NSString stringWithFormat:@" Delegate (%@)",_legislator.party];
        }
        
        if ([_legislator.district isKindOfClass:[NSNull class]]
            || [_legislator.district intValue] == 0) {
            name2 = [NSString stringWithFormat:@" (%@) %@",_legislator.party,_legislator.state];
        }
        else {
            name2 = [NSString stringWithFormat:@" (%@) %@ - District %@",_legislator.party,_legislator.state,_legislator.district];
        }
        
        int year = [[NSString stringWithFormat:@"%@",[_legislator.date_of_birth substringWithRange:NSMakeRange(0, 4)]] intValue];
        NSDate *today = [[NSDate alloc] init];
        NSDateComponents* components = [[NSCalendar currentCalendar] components:NSCalendarUnitYear fromDate:today];
        
        birthday = [NSString stringWithFormat:@" Age: %ld",(long)[components year] - year];
        
        pasteboard.string = [NSString stringWithFormat:@"%@\n%@\n%@\n%@\n%@",name1,role,name2,birthday,_legislator.next_election];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"MapDetail"]) {
        MapViewController *tvc = [segue destinationViewController];
        tvc.legislator = _legislator;
        tvc.title = @"Constituents Map";
    }
    else if ([segue.identifier isEqualToString:@"BioDetail"]) {
        LegislatorBioViewController *tvc = [segue destinationViewController];
        tvc.bioguideid = _legislator.bioguide_id;
        tvc.lastName = _legislator.last_name;
        tvc.title = @"Biography";
    }
    else if ([segue.identifier isEqualToString:@"CommitteesDetail"]) {
        CommitteesTVC *tvc = [segue destinationViewController];
        tvc.committees = _legislator.committees;
        tvc.mode = @"LegislatorCommittees";
        tvc.title = [NSString stringWithFormat:@"Committees of %@", self.title];
    }
    else if ([segue.identifier isEqualToString:@"Terms"]) {
        TermsTVC *vc = [segue destinationViewController];        
        vc.terms = _legislator.terms;
    }
    else if ([segue.identifier isEqualToString:@"Contact"]) {
        ContactTableViewController *vc = [segue destinationViewController];
        vc.phone = _legislator.phone;
        vc.website = _legislator.url;
        vc.facebook_account = _legislator.facebook_account;
        vc.youtube_account = _legislator.youtube_account;
        vc.twitter_account = _legislator.twitter_account;
    }
    else if ([segue.identifier isEqualToString:@"LegislatorVotes"] ||
        [segue.identifier isEqualToString:@"LegislatorFavoriteVotes"]) {
        LegislatorVotesTableViewController *vc = [segue destinationViewController];
        vc.bioguide_id = _legislator.bioguide_id;
        vc.chamber = _legislator.chamber;
        vc.title = @"Votes";
    }

}
@end
