//
//  RollCallTVC.m
//  Congress
//
//  Created by Eric Panchenko on 7/8/16.
//  Copyright © 2016 Eric Panchenko. All rights reserved.
//

#import "RollCallTVC.h"
#import "TVCMethods.h"
#import "LegislatorDetailVC.h"

@interface RollCallTVC ()

@property (nonatomic,strong) TVCMethods *tvcMethods;
@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic, strong) ProgressTapGestureRecognizer *HUDSingleTap;
@property (nonatomic, strong) Progress *progress;

@end

@implementation RollCallTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UILabel* tlabel=[[UILabel alloc] initWithFrame:CGRectMake(0,0, self.navigationController.navigationBar.frame.size.width, self.navigationController.navigationBar.frame.size.height)];
    tlabel.text = self.navigationItem.title;
    tlabel.textAlignment = NSTextAlignmentCenter;
    tlabel.textColor = [UIColor colorNamed:@"BlackOrWhite"];
    tlabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size: 17.0];
    tlabel.backgroundColor = [UIColor clearColor];
    tlabel.adjustsFontSizeToFitWidth = YES;
    [tlabel setMinimumScaleFactor:10.0/tlabel.font.pointSize];
    self.navigationItem.titleView = tlabel;
    
    self.tvcMethods = [[TVCMethods alloc] init];
    self.tvcMethods.tableView = self.tableView;
    
    [[NSNotificationCenter defaultCenter] addObserver:self.tvcMethods
                                             selector:@selector(didChangePreferredContentSize:)
                                                 name:UIContentSizeCategoryDidChangeNotification object:nil];
    
    self.progress = [[Progress alloc] init];
    
    _HUDSingleTap = [[ProgressTapGestureRecognizer alloc]initWithTarget:self.progress action:@selector(singleTap:)];
    _HUDSingleTap.navigationController = self.navigationController;
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 60;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(handleRefresh:) forControlEvents:UIControlEventValueChanged];
    
    [self fetchData:YES];
}

- (void)handleRefresh:(UIRefreshControl *)refreshControl {
    [self fetchData:NO];
    [self.tableView layoutIfNeeded];
    [refreshControl endRefreshing];
}

-(RollCall*)createRollCall:(NSString*)vote {
    
    RollCall *rollCall = [[RollCall alloc] init];
    
    NSArray *fields = [vote componentsSeparatedByString:@"@"];
    NSArray *nameFields = [fields[1] componentsSeparatedByString:@" "];
    NSMutableString *string = [[NSMutableString alloc] initWithString:nameFields[[nameFields count] - 1]];
    
    [string appendString:@","];
    
    for (int i = 0; i < [nameFields count] - 1; i++) {
        [string appendString:[NSString stringWithFormat:@" %@",nameFields[i]]];
    }
    
    rollCall.bioguide_id = fields[0];
    rollCall.name = string;
    rollCall.party = fields[2];
    rollCall.stateLabel = fields[3];
    
    if ([fields[4] isEqualToString:@"Y"])
        rollCall.vote = @"Yea";
    else if ([fields[4] isEqualToString:@"N"])
        rollCall.vote = @"Nay";
    else if ([fields[4] isEqualToString:@"P"])
        rollCall.vote = @"Present";
    else if ([fields[4] isEqualToString:@"X"])
        rollCall.vote = @"No Vote";
    
    if ([fields count] == 6)
        rollCall.district = fields[5];
    else rollCall.district = (id)[NSNull null];
    
    return rollCall;
}

-(void) fetchData:(BOOL)showProgress {
    
    if (showProgress) {
        self.hud = [Progress showGlobalProgressHUDWithTitle:@"Loading..."];
        [self.hud addGestureRecognizer:_HUDSingleTap];
    }
    
    NSMutableArray *rollCallArray = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < [_votes count]; i++) {
        [rollCallArray addObject:[self createRollCall:_votes[i]]];
    }
    
    self.rollCallArr = [rollCallArray sortedArrayUsingSelector:@selector(rollCallCompare:)];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [Progress dismissGlobalHUD];
        [self.tableView reloadData];
    });
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIContentSizeCategoryDidChangeNotification
                                                  object:nil];
}
    
#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.rollCallArr count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RollCall" forIndexPath:indexPath];
    
    cell.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    cell.detailTextLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];

    NSString *dist = [self.rollCallArr[indexPath.row] district];
    
    if (dist == (id)[NSNull null]) {
        cell.textLabel.text = [NSString stringWithFormat:@"%@ (%@) - %@",[self.rollCallArr[indexPath.row] name],[self.rollCallArr[indexPath.row] party],[self.rollCallArr[indexPath.row] stateLabel]];
    }
    else {
        cell.textLabel.text = [NSString stringWithFormat:@"%@ (%@) %@ - District %@",
            [self.rollCallArr[indexPath.row] name], [self.rollCallArr[indexPath.row] party], [self.rollCallArr[indexPath.row] stateLabel], dist];
    }
    
    cell.textLabel.textColor = [UIColor colorNamed:@"BlackOrWhite"];
    
    NSMutableAttributedString *voteString = [[NSMutableAttributedString alloc] initWithString:[self.rollCallArr[indexPath.row] vote]];
        
    UIColor *color;
    
    if ([[self.rollCallArr[indexPath.row] vote] isEqualToString:@"Yea"]) {
        color = [UIColor colorWithRed:0.02 green:0.44 blue:0.11 alpha:1.0];
    }
    else if ([[self.rollCallArr[indexPath.row] vote] isEqualToString:@"Nay"]) {
        color = [UIColor redColor];
    }
    else {
        color = [UIColor grayColor];
    }

    [voteString addAttribute:NSForegroundColorAttributeName
                       value:color
                       range:NSMakeRange(0, [voteString length])];
    
    cell.detailTextLabel.attributedText = voteString;
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    cell.textLabel.enabled = false;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.userInteractionEnabled = false;
    
    return cell;
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"LegislatorDetail"]) {
        LegislatorDetailVC *tvc = [segue destinationViewController];
        
        if (self.selectedLegislator != nil) {
            tvc.legislator = self.selectedLegislator;
            tvc.title = [NSString stringWithFormat:@"%@, %@",tvc.legislator.last_name,tvc.legislator.first_name];
        }
    }
}

@end
