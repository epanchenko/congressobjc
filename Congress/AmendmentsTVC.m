//
//  AmendmentsTVC.m
//  Congress
//
//  Created by Eric Panchenko on 6/11/17.
//  Copyright © 2017 Eric Panchenko. All rights reserved.
//

#import "AmendmentsTVC.h"

@interface AmendmentsTVC ()

@end

@implementation AmendmentsTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tvcMethods = [[TVCMethods alloc] init];
    self.tvcMethods.tableView = self.tableView;
    
    UILabel* tlabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0, self.navigationController.navigationBar.frame.size.width, self.navigationController.navigationBar.frame.size.height)];
    tlabel.text = self.navigationItem.title;
    tlabel.textAlignment = NSTextAlignmentCenter;
    tlabel.textColor = [UIColor colorNamed:@"BlackOrWhite"];
    tlabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size: 17.0];
    tlabel.backgroundColor = [UIColor clearColor];
    tlabel.adjustsFontSizeToFitWidth = YES;
    [tlabel setMinimumScaleFactor:10.0/tlabel.font.pointSize];
    self.navigationItem.titleView = tlabel;
    
    [[NSNotificationCenter defaultCenter] addObserver:self.tvcMethods
                                             selector:@selector(didChangePreferredContentSize:)
                                                 name:UIContentSizeCategoryDidChangeNotification object:nil];

    [self.tableView registerNib:[UINib nibWithNibName:@"LegislatorVoteCell" bundle:nil] forCellReuseIdentifier:@"Amendment"];
    
    self.tableView.estimatedRowHeight = 80;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    
    
    [self.tableView reloadData];
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIContentSizeCategoryDidChangeNotification
                                                  object:nil];
}

#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [self.amendments count];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Amendment *amendment = self.amendments[indexPath.row];
    
    if (!(amendment.url == (id)[NSNull null] || amendment.url.length == 0)) {
        if ([[NSProcessInfo processInfo] operatingSystemVersion].majorVersion >= 9) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",amendment.url]]];
        }
        else {
            [self performSegueWithIdentifier:@"Webpage" sender:[NSURL URLWithString:amendment.url]];
        }
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"Webpage"]) {
        WebpageViewController *vc = [segue destinationViewController];
        vc.website = sender;
        vc.title = @"Website";
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    LegislatorVoteCellTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Amendment" forIndexPath:indexPath];
        
    Amendment *amendment = self.amendments[indexPath.row];
    
    cell.billTitle.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    cell.billTitle.text = [NSString stringWithFormat:@"Amendment %@",amendment.number];
    
    if (![amendment.title isEqualToString:@""]) {
        cell.question.text = amendment.title;
    }
    
    cell.question.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    
    NSString *string1 = [[NSString alloc] init];
    
    if (!(amendment.sponsor == (id)[NSNull null] || amendment.sponsor == 0)) {
        string1 = [NSString stringWithFormat:@"Sponsor: %@",amendment.sponsor];
    }
    
    NSString *string2;
    
    if (string1.length > 0)
        string2 = [NSString stringWithFormat:@"\nLatest Action: %@ %@",amendment.latestAction, amendment.latestActionDate];
    else
        string2 = [NSString stringWithFormat:@"Latest Action: %@ %@",amendment.latestAction, amendment.latestActionDate];
        
    NSMutableAttributedString *string3 = [[NSMutableAttributedString alloc] initWithString:string1];
    NSMutableAttributedString *string4 = [[NSMutableAttributedString alloc] initWithString:string2];
     
    NSRange boldedRange = [string1 rangeOfString:@"Sponsor:"];
    
    if (boldedRange.location != NSNotFound) {
        [string3 addAttribute:NSForegroundColorAttributeName
                        value:[UIColor grayColor]
                        range:boldedRange];
    }
    
    boldedRange = [string2 rangeOfString:@"Latest Action:"];
    
    if (boldedRange.location != NSNotFound) {
        [string4 addAttribute:NSForegroundColorAttributeName
                        value:[UIColor grayColor]
                        range:boldedRange];
    }
    
    NSMutableAttributedString* result = [string3 mutableCopy];
    
    [result appendAttributedString:string4];
     
    cell.resultLabel.attributedText = result;
    cell.resultLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    
    if (amendment.url == (id)[NSNull null] || amendment.url == 0) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.textLabel.enabled = NO;
        cell.userInteractionEnabled = false;
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    return cell;
}

@end
