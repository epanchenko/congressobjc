//
//  AboutTableViewController.m
//  Congress
//
//  Created by Eric Panchenko on 10/12/17.
//  Copyright © 2017 Eric Panchenko. All rights reserved.
//

#import "AboutTableViewController.h"

@interface AboutTableViewController ()

@end

@implementation AboutTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Data Sources";
    
    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeAlways;
    
    
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"menuRow"];
    
    self.tvcMethods = [[TVCMethods alloc] init];
    self.tvcMethods.tableView = self.tableView;
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 80;
    
    [[NSNotificationCenter defaultCenter] addObserver:self.tvcMethods
                                             selector:@selector(didChangePreferredContentSize:)
                                                 name:UIContentSizeCategoryDidChangeNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.navigationController.toolbarHidden = YES;
}

- (BOOL)slideNavigationControllerShouldDisplayLeftMenu {
    return YES;
}

#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 7;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    NSString *url;
    
    switch (indexPath.row) {
        case 0:
            url = @"https://propublica.org";
            break;
        case 1:
            url = @"https://www.loc.gov";
            break;
        case 2:
            url = @"http://bioguide.congress.gov";
            break;
        case 3:
            url = @"https://github.com/unitedstates/districts";
            break;
        case 4:
            url = @"http://thenounproject.com/term/capitol-building/160031/";
            break;
        case 5:
            url = @"http://www.senate.gov/";
            break;
        case 6:
            url = @"http://www.house.gov/";
            break;
    }
    
    if ([[NSProcessInfo processInfo] operatingSystemVersion].majorVersion >= 9) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",url]]];
    }
    else {
        [self performSegueWithIdentifier:@"Webpage" sender:[NSURL URLWithString:[NSString stringWithFormat:@"%@",url]]];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = @"Propublica Congress API";
            break;
        case 1:
            cell.textLabel.text = @"U.S. Library of Congress";
            break;
        case 2:
            cell.textLabel.text = @"Biographical Directory of the U.S. Congress";
            break;
        case 3:
            cell.textLabel.text = @"GitHub U.S. District Coordinates";
            break;
        case 4:
            cell.textLabel.text = @"Capitol Building Image";
            break;
        case 5:
            cell.textLabel.text = @"U.S. Senate";
            break;
        case 6:
            cell.textLabel.text = @"U.S. House of Representatives";
            break;
    }
    
    return cell;
}


#pragma mark - Navigation

 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
     if ([segue.identifier isEqualToString:@"Webpage"]) {
          WebpageViewController *vc = [segue destinationViewController];
          vc.website = sender;
     }
 }

@end
