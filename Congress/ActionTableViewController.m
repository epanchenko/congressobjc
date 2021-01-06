//
//  ActionTableViewController.m
//  Congress
//
//  Created by Eric Panchenko on 7/27/16.
//  Copyright © 2016 Eric Panchenko. All rights reserved.
//

#import "ActionTableViewController.h"


@interface ActionTableViewController ()

@end


@implementation ActionTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    
    self.tvcMethods = [[TVCMethods alloc] init];
    self.tvcMethods.tableView = self.tableView;
    
    [self.refreshControl addTarget:self action:@selector(handleRefresh:) forControlEvents:UIControlEventValueChanged];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 80;
    
    UILabel* tlabel=[[UILabel alloc] initWithFrame:CGRectMake(0,0, self.navigationController.navigationBar.frame.size.width, self.navigationController.navigationBar.frame.size.height)];
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self.tvcMethods
                                             selector:@selector(didChangePreferredContentSize:)
                                                 name:UIContentSizeCategoryDidChangeNotification object:nil];

    [self fetchData:YES];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIContentSizeCategoryDidChangeNotification
                                                  object:nil];
}


- (void)handleRefresh:(UIRefreshControl *)refreshControl {
        
    [self fetchData:NO];
    
    [self.tableView layoutIfNeeded];
    
    [refreshControl endRefreshing];
}

- (void)fetchData:(BOOL)showProgress {
    
    if (showProgress) {
        self.hud = [Progress showGlobalProgressHUDWithTitle:@"Loading..."];
        [self.hud addGestureRecognizer:_HUDSingleTap];
    }
    
    Action *action;
    NSArray *fields;
    NSMutableArray *mutableActions = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < [self.uncompressedActions count]; i++) {
        action = [[Action alloc] init];
        fields = [self.uncompressedActions[i] componentsSeparatedByString:@"@"];
                
        action.action_id = [fields[0] intValue];
        
        if ([self.mode isEqualToString:@"Bill"]) {
            action.chamber = [fields[1] capitalizedString];
            action.acted_at = fields[2];
            action.text = fields[3];
        }
        else { /* Nomination */
            action.acted_at = fields[1];
            action.text = fields[2];
        }
                
        [mutableActions addObject:action];
    }
    
    if ([self.mode isEqualToString:@"Bill"])
    [mutableActions sortUsingDescriptors:
                     @[[NSSortDescriptor sortDescriptorWithKey:@"action_id" ascending:NO]]];
    else
    [mutableActions sortUsingDescriptors:
                    @[[NSSortDescriptor sortDescriptorWithKey:@"action_id" ascending:YES]]];
    
    self.actions = [mutableActions copy];
    
    [self.tableView reloadData];
    
    [Progress dismissGlobalHUD];
    
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.actions count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DynamicTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ActionCell" forIndexPath:indexPath];
    
    Action *action = self.actions[indexPath.row];
    
    if (!(action.acted_at == (id)[NSNull null] || action.acted_at == 0)) {
        cell.label.text = [NSString stringWithFormat:@"%@",action.acted_at];
    }
    
    if (!(action.chamber == (id)[NSNull null] || action.chamber == 0)) {
        cell.label.text = [NSString stringWithFormat:@"%@\n%@",cell.label.text,action.chamber];
    }
    
    if (!(action.text == (id)[NSNull null] || action.text == 0)) {
        cell.label.text = [NSString stringWithFormat:@"%@\n%@",cell.label.text,action.text];
    }
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.label.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    
    return cell;
}

@end
