//
//  LegislatorVoteDetailTVC.m
//  Congress
//
//  Created by Eric Panchenko on 6/18/16.
//  Copyright © 2016 Eric Panchenko. All rights reserved.
//

#import "LegislatorVoteDetailTVC.h"


@interface LegislatorVoteDetailTVC ()

@end

@implementation LegislatorVoteDetailTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
    
    UILabel* tlabel=[[UILabel alloc] initWithFrame:CGRectMake(0,0, self.navigationController.navigationBar.frame.size.width, self.navigationController.navigationBar.frame.size.height)];
    
    tlabel.text = self.navigationItem.title;
    tlabel.textAlignment = NSTextAlignmentCenter;
    tlabel.textColor = [UIColor colorNamed:@"BlackOrWhite"];
    tlabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size: 17.0];
    tlabel.backgroundColor = [UIColor clearColor];
    tlabel.adjustsFontSizeToFitWidth = YES;
    [tlabel setMinimumScaleFactor:10.0/tlabel.font.pointSize];
    
    self.navigationItem.titleView = tlabel;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"LegislatorVoterDetailGraphTableViewCell" bundle:nil] forCellReuseIdentifier:@"LegislatorVoterDetailGraphTableViewCell"];
    
    self.tvcMethods = [[TVCMethods alloc] init];
    self.tvcMethods.tableView = self.tableView;
    
    [[NSNotificationCenter defaultCenter] addObserver:self.tvcMethods
                                             selector:@selector(didChangePreferredContentSize:)
                                                 name:UIContentSizeCategoryDidChangeNotification object:nil];
    
    self.progress = [[Progress alloc] init];
    
    _HUDSingleTap = [[ProgressTapGestureRecognizer alloc]initWithTarget:self.progress action:@selector(singleTap:)];
    _HUDSingleTap.navigationController = self.navigationController;
    
    [self fetchData];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.navigationController.toolbarHidden = YES;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIContentSizeCategoryDidChangeNotification
                                                  object:nil];
}

- (void) fetchData {
    
    self.hud = [Progress showGlobalProgressHUDWithTitle:@"Loading..."];
    [self.hud addGestureRecognizer:_HUDSingleTap];

    _totalKeysArray = [[NSMutableArray alloc] initWithArray:@[@"Yea",@"Nay",@"No Vote",@"Present"]];
    
    int totalYea = 0, totalNo = 0, totalPresent = 0, totalNotVoting = 0;
    
    NSMutableDictionary *partyMutableDict = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *totalMutableDict = [[NSMutableDictionary alloc] init];
    
    _partyDict = [[NSDictionary alloc] init];
    _totalDict = [[NSDictionary alloc] init];
    
    NSMutableDictionary *partyVotes = [[NSMutableDictionary alloc] init];
    
    NSArray *fields;
    
    fields = [_vote.republicanVotes componentsSeparatedByString:@"@"];
    
    [partyVotes setValue:fields[0] forKey:@"Yea"];
    [partyVotes setValue:fields[1] forKey:@"Nay"];
    [partyVotes setValue:fields[2] forKey:@"No Vote"];
    [partyVotes setValue:fields[3] forKey:@"Present"];
    
    totalYea += [fields[0] intValue];
    totalNo += [fields[1] intValue];
    totalNotVoting += [fields[2] intValue];
    totalPresent += [fields[3] intValue];
    
    [partyMutableDict setValue:partyVotes forKey:@"R"];
    
    partyVotes = [[NSMutableDictionary alloc] init];
    fields = [_vote.democraticVotes componentsSeparatedByString:@"@"];
    
    [partyVotes setValue:fields[0] forKey:@"Yea"];
    [partyVotes setValue:fields[1] forKey:@"Nay"];
    [partyVotes setValue:fields[2] forKey:@"No Vote"];
    [partyVotes setValue:fields[3] forKey:@"Present"];
    
    totalYea += [fields[0] intValue];
    totalNo += [fields[1] intValue];
    totalNotVoting += [fields[2] intValue];
    totalPresent += [fields[3] intValue];
    
    [partyMutableDict setValue:partyVotes forKey:@"D"];
    
    partyVotes = [[NSMutableDictionary alloc] init];
    fields = [_vote.independentVotes componentsSeparatedByString:@"@"];
    
    [partyVotes setValue:fields[0] forKey:@"Yea"];
    [partyVotes setValue:fields[1] forKey:@"Nay"];
    [partyVotes setValue:fields[2] forKey:@"No Vote"];
    [partyVotes setValue:fields[3] forKey:@"Present"];
    
    totalYea += [fields[0] intValue];
    totalNo += [fields[1] intValue];
    totalNotVoting += [fields[2] intValue];
    totalPresent += [fields[3] intValue];
    
    [partyMutableDict setValue:partyVotes forKey:@"I"];
    
    [totalMutableDict setValue:[NSString stringWithFormat:@"%d",totalYea] forKey:@"Yea"];
    [totalMutableDict setValue:[NSString stringWithFormat:@"%d",totalNo] forKey:@"Nay"];
    [totalMutableDict setValue:[NSString stringWithFormat:@"%d",totalPresent] forKey:@"Present"];
    [totalMutableDict setValue:[NSString stringWithFormat:@"%d",totalNotVoting] forKey:@"No Vote"];
    
    _partyDict = [[NSDictionary alloc] initWithDictionary:partyMutableDict];
    _totalDict = [[NSDictionary alloc] initWithDictionary:totalMutableDict];
     
    for (NSString *key in [_totalKeysArray copy]) {
        if (![key isEqualToString:@"Yea"] && ![key isEqualToString:@"Nay"] && [_totalDict[key] intValue] == 0) {
            [_totalKeysArray removeObject:key];
        }
    }
    
    _totalKeys = [[NSMutableDictionary alloc] init];
    
    int counter = 0;
    
    for (NSString *key in _totalKeysArray) {
        if ([key isEqualToString:@"Yea"]) {
            _totalKeys[key] = [UIColor colorWithRed:0.02 green:0.44 blue:0.11 alpha:1.0];
        }
        else if ([key isEqualToString:@"Nay"]) {
            _totalKeys[key] = [UIColor redColor];
        }
        else if ([key isEqualToString:@"Present"]) {
            _totalKeys[key] = [UIColor purpleColor];
        }
        else {
            _totalKeys[key] = [UIColor otherColor:counter];
            counter++;
        }
    }
    
    _totalKeysArraySorted = [[_totalKeys allKeys] sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        
        NSString *first = (NSString*)a;
        NSString *second = (NSString*)b;
        
        first = [first stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        second = [second stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        
        NSArray *values = @[@"Yea",@"Nay",@"Present",@"No Vote"];
        
        if ([values indexOfObject:first] < [values indexOfObject:second]) {
            return -1;
        }
        
        return 1;
    }];
    
    _partyKeysArray = [[[NSMutableArray alloc] initWithArray:[_partyDict allKeys]] sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        
        NSString *first = (NSString*)a;
        NSString *second = (NSString*)b;
        
        first = [first stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        second = [second stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        
        NSArray *values = @[@"R",@"D",@"I"];
        
        if ([values indexOfObject:first] < [values indexOfObject:second]) {
            return -1;
        }
        
        return 1;
    }];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [Progress dismissGlobalHUD];
        [self.tableView reloadData];
    });
}

#pragma mark - Table view data source

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0 || indexPath.section == 1) {
        return 44;
    }
    else if (indexPath.section == 2) {
        if (indexPath.row == [_totalKeysArray count]) {
            return 300;
        }
        else {
            return 44;
        }
    }
    else {
        
        NSString *party = _partyKeysArray[indexPath.section - 3];
        
        int count = 0;
        
        for (NSString *key in _partyDict[party]) {
            
            if ([key isEqualToString:@"Yea"] || [key isEqualToString:@"Nay"] || [_partyDict[party][key] intValue] != 0) {
                count++;
            }
        }
        
        if (indexPath.row == count) {
            return 300;
        }
        else {
            return 44;
        }
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3 + [_partyKeysArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 0 || section == 1) {
        return 1;
    }
    else if (section == 2) {
        return 1 + [_totalKeysArray count];
    }
    else {
        int count = 0;
        
        NSString *party = _partyKeysArray[section - 3];
        
        for (NSString *key in _partyDict[party]) {
            
            if ([key isEqualToString:@"Yea"] || [key isEqualToString:@"Nay"] || [_partyDict[party][key] intValue] != 0) {
                count++;
            }
        }
       
        return count + 1;
    }
}

- (NSString *)hexStringFromColor:(UIColor *)color {
    const CGFloat *components = CGColorGetComponents(color.CGColor);
    
    CGFloat r = components[0];
    CGFloat g = components[1];
    CGFloat b = components[2];
    
    return [NSString stringWithFormat:@"#%02lX%02lX%02lX",
            lroundf(r * 255),
            lroundf(g * 255),
            lroundf(b * 255)];
}
    
-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    if (section == 0 || section == 1) {
        return @"";
    }
    else if (section == 2) {
        return @"Total";
    }
    else {
        return _partyKeysArray[section - 3];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    
    if (section > 1) {
        // Background color
        //view.tintColor = [UIColor colorWithRed:0.35 green:0.78 blue:0.98 alpha:1.0];
        
        UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
        
        //header.textLabel.textColor = [UIColor blackColor];
        header.textLabel.textColor = [UIColor colorNamed:@"BlackOrWhite"];
        header.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
        CGRect headerFrame = header.frame;
        header.textLabel.frame = headerFrame;
        header.textLabel.adjustsFontSizeToFitWidth = YES;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0 && indexPath.row == 0) {
        
        if (!(self.bill_id == (id)[NSNull null] || self.bill_id.length == 0) ||
        ((self.bill_id == (id)[NSNull null] || self.bill_id.length == 0)
         && (self.nomination_id == (id)[NSNull null] || self.nomination_id.length == 0))) {
            [self performSegueWithIdentifier:@"BillDetailSegue" sender:nil];
        }
        else {
            [self performSegueWithIdentifier:@"NominationDetailSegue" sender:nil];
        }
    }
    else if (indexPath.section == 1 && indexPath.row == 0) {
        [self performSegueWithIdentifier:@"RollCallSegue" sender:nil];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"VoteCell" forIndexPath:indexPath];
        
        if (!(self.bill_id == (id)[NSNull null] || self.bill_id.length == 0) ||
            ((self.bill_id == (id)[NSNull null] || self.bill_id.length == 0)
             && (self.nomination_id == (id)[NSNull null] || self.nomination_id.length == 0))) {
            cell.textLabel.text = @"Bill Detail";
        }
        else {
            cell.textLabel.text = @"Nomination Detail";
        }
                
        if ((self.bill_id == (id)[NSNull null] || self.bill_id.length == 0) &&
            (self.nomination_id == (id)[NSNull null] || self.nomination_id.length == 0)) {
            cell.userInteractionEnabled = false;
            cell.textLabel.enabled = false;
        }
        else {
            cell.userInteractionEnabled = true;
            cell.textLabel.enabled = true;
        }
        
        //cell.textLabel.textColor = [UIColor blackColor];
        cell.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
        cell.textLabel.adjustsFontSizeToFitWidth = YES;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        return cell;
    }

    else if (indexPath.section == 1) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"VoteCell" forIndexPath:indexPath];
        cell.textLabel.text = @"Roll Call";
        //cell.textLabel.textColor = [UIColor blackColor];
        cell.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
        cell.textLabel.adjustsFontSizeToFitWidth = YES;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        return cell;
    }
    
    else if (indexPath.section == 2) {
        
        if (indexPath.row == [_totalKeysArraySorted count]) {
            LegislatorVoterDetailGraphTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LegislatorVoterDetailGraphTableViewCell" forIndexPath:indexPath];
            
            VBPieChart *chart = [[VBPieChart alloc] initWithFrame:CGRectMake((cell.frame.size.width / 2) - (cell.graphImageView.frame.size.height / 2), cell.graphImageView.frame.origin.y + 10, cell.graphImageView.frame.size.width, cell.graphImageView.frame.size.height)];
            
            chart.startAngle = M_PI+M_PI_2;
            
            [chart setLabelsPosition:VBLabelsPositionNone];
            
            NSMutableArray *chartValues = [[NSMutableArray alloc] init];
            NSMutableDictionary *dict;
            
            for (NSString *key in _totalKeysArraySorted) {
                dict = [[NSMutableDictionary alloc] init];
                dict[@"value"] = @([_totalDict[key] intValue]);
                dict[@"color"] = [self hexStringFromColor:_totalKeys[key]];
            
                [chartValues addObject:dict];
            }

            [chart setChartValues:chartValues animation:NO];
            
            [cell.graphImageView addSubview:chart];
            
            return cell;
        }
        
        else {
            
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"VoteCell" forIndexPath:indexPath];
            cell.textLabel.text = [NSString stringWithFormat:@"%@: %@",_totalKeysArraySorted[indexPath.row],_totalDict[_totalKeysArraySorted[indexPath.row]]];
            cell.textLabel.textColor = _totalKeys[_totalKeysArraySorted[indexPath.row]];
            cell.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
            cell.textLabel.adjustsFontSizeToFitWidth = YES;
            return cell;
        }
    }
    
    else { //party sections
                
        NSString *party = _partyKeysArray[indexPath.section - 3];
        
        int count = 0;
        
        for (NSString *key in _partyDict[party]) {
            
            if ([key isEqualToString:@"Yea"] || [key isEqualToString:@"Nay"] || [_partyDict[party][key] intValue] != 0) {
                count++;
            }
        }
        
        int counter = 0;
        
        NSMutableDictionary *totalOtherPartyKeys = [[NSMutableDictionary alloc] init];
        
        NSMutableArray *partyKeysArray2 = [[NSMutableArray alloc] initWithArray:[[_partyDict[party] allKeys] sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
            
            NSString *first = (NSString*)a;
            NSString *second = (NSString*)b;
            
            first = [first stringByReplacingOccurrencesOfString:@"\"" withString:@""];
            second = [second stringByReplacingOccurrencesOfString:@"\"" withString:@""];
            
            NSArray *values = @[@"Yea",@"Nay",@"Present",@"No Vote"];
            
            if ([values indexOfObject:first] < [values indexOfObject:second]) {
                return -1;
            }
            
            return 1;
        }]];
        
        NSUInteger index = [partyKeysArray2 indexOfObject:@"Yea"];
        
        if (index != NSNotFound) {
            id object = [partyKeysArray2 objectAtIndex:index];
            [partyKeysArray2 removeObjectAtIndex:index];
            [partyKeysArray2 insertObject:object atIndex:0];
        }
        
        index = [partyKeysArray2 indexOfObject:@"Nay"];
        
        if (index != NSNotFound) {
            id object = [partyKeysArray2 objectAtIndex:index];
            [partyKeysArray2 removeObjectAtIndex:index];
            [partyKeysArray2 insertObject:object atIndex:1];
        }
        
        for (NSString *key in partyKeysArray2) {
            
            if ([key isEqualToString:@"Yea"] || [key isEqualToString:@"Nay"] || [_partyDict[party][key] intValue] != 0) {
                
                if ([key isEqualToString:@"Yea"]) {
                    totalOtherPartyKeys[key] = [UIColor colorWithRed:0.02 green:0.44 blue:0.11 alpha:1.0];;
                }
                else if ([key isEqualToString:@"Nay"]) {
                    totalOtherPartyKeys[key] = [UIColor redColor];
                }
                else if ([key isEqualToString:@"Present"]) {
                    totalOtherPartyKeys[key] = [UIColor purpleColor];
                }
                else {
                   totalOtherPartyKeys[key] = [UIColor otherColor:counter];
                   counter++;
                }
            }
        }
        
        _totalOtherPartyKeysSorted = [[totalOtherPartyKeys allKeys] sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
            
            NSString *first = (NSString*)a;
            NSString *second = (NSString*)b;
            
            first = [first stringByReplacingOccurrencesOfString:@"\"" withString:@""];
            second = [second stringByReplacingOccurrencesOfString:@"\"" withString:@""];
            
            NSArray *values = @[@"Yea",@"Nay",@"Present",@"No Vote"];
            
            if ([values indexOfObject:first] < [values indexOfObject:second]) {
                return -1;
            }
            
            return 1;
        }];
        
        if (indexPath.row != count) {
            
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"VoteCell" forIndexPath:indexPath];
            cell.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
            cell.textLabel.adjustsFontSizeToFitWidth = YES;
            cell.textLabel.text = [NSString stringWithFormat:@"%@: %@",
                                   _totalOtherPartyKeysSorted[indexPath.row],_partyDict[party][_totalOtherPartyKeysSorted[indexPath.row]]];
            
            if ([_totalOtherPartyKeysSorted[indexPath.row] isEqualToString:@"Yea"]) {
                cell.textLabel.textColor = [UIColor colorWithRed:0.02 green:0.44 blue:0.11 alpha:1.0];
            }
            else if ([_totalOtherPartyKeysSorted[indexPath.row] isEqualToString:@"Nay"]) {
                cell.textLabel.textColor = [UIColor redColor];
            }
            else if ([_totalOtherPartyKeysSorted[indexPath.row] isEqualToString:@"Nay"]) {
                cell.textLabel.textColor = [UIColor purpleColor];
            }
            else {
                cell.textLabel.textColor = totalOtherPartyKeys[_totalOtherPartyKeysSorted[indexPath.row]];
            }
            
            return cell;
        }
        else {
            LegislatorVoterDetailGraphTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LegislatorVoterDetailGraphTableViewCell" forIndexPath:indexPath];
            
            VBPieChart *chart = [[VBPieChart alloc] initWithFrame:CGRectMake((cell.frame.size.width / 2) - (cell.graphImageView.frame.size.height / 2), cell.graphImageView.frame.origin.y + 10, cell.graphImageView.frame.size.width, cell.graphImageView.frame.size.height)];
            
            chart.startAngle = M_PI+M_PI_2;
            
            [chart setLabelsPosition:VBLabelsPositionNone];
            
            NSMutableArray *chartValues = [[NSMutableArray alloc] init];
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            
            for (NSString *key in totalOtherPartyKeys) {
                dict = [[NSMutableDictionary alloc] init];
                dict[@"value"] = @([_partyDict[party][key] intValue]);
                dict[@"color"] = [self hexStringFromColor:totalOtherPartyKeys[key]];
                
                [chartValues addObject:dict];
            }
            
            [chart setChartValues:chartValues animation:NO];
            [cell.graphImageView addSubview:chart];
            
            return cell;
        }
    }
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"BillDetailSegue"]) {
        
        BillDetailTableViewController *tvc = [segue destinationViewController];
        
        tvc.title = self.title;
        tvc.bill_id = self.bill_id;
        
    }
    else if ([segue.identifier isEqualToString:@"NominationDetailSegue"]) {
        
        NominationDetailTableViewController *tvc = [segue destinationViewController];
        
        tvc.title = self.title;
        tvc.nomination_id = self.nomination_id;
    }
    else if ([segue.identifier isEqualToString:@"RollCallSegue"]) {
        
        RollCallTVC *tvc = [segue destinationViewController];
        
        tvc.title = self.title;
        tvc.votes = self.vote.individualVotes;
        tvc.chamber = self.vote.chamber;
    }
}


@end

