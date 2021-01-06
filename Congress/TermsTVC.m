//
//  TermsTVC.m
//  Congress
//
//  Created by Eric Panchenko on 5/14/16.
//  Copyright © 2016 Eric Panchenko. All rights reserved.
//

#import "TermsTVC.h"
#import "TVCMethods.h"

@interface TermsTVC ()

@property (nonatomic,strong) TVCMethods *tvcMethods;
@end

@implementation TermsTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Terms";
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    [[NSNotificationCenter defaultCenter] addObserver:self.tvcMethods
                                             selector:@selector(didChangePreferredContentSize:)
                                                 name:UIContentSizeCategoryDidChangeNotification object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIContentSizeCategoryDidChangeNotification
                                                  object:nil];
}
    
#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_terms count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TermCell" forIndexPath:indexPath];
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    Term *term = _terms[indexPath.row];
    
    NSDate *startDate = [dateFormatter dateFromString: term.startDate];
    NSDate *endDate = [dateFormatter dateFromString: term.endDate];
    
    [dateFormatter setLocale:[NSLocale currentLocale]];
    [dateFormatter setDateStyle:NSDateFormatterLongStyle];
    
    [dateFormatter setDateFormat:@"MMMM d, yyyy"];
    
    cell.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@ - %@",[dateFormatter stringFromDate:startDate],
                           [dateFormatter stringFromDate:endDate]];
    
    cell.detailTextLabel.text = term.title;
    
    cell.detailTextLabel.textColor = [UIColor grayColor];
    
    return cell;
}

@end
