//
//  LegislatorsViewController.m
//
//  Created by Eric Panchenko on 8/29/15.


#import "LegislatorsViewController.h"

@interface LegislatorsViewController ()  {}

@end

@implementation LegislatorsViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
        
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
        
    UIRefreshControl *refreshControl = [UIRefreshControl new];
    [refreshControl addTarget:self action:@selector(handleRefresh:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refreshControl];
    [self.tableView sendSubviewToBack:refreshControl];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"LegislatorTVCell" bundle:nil] forCellReuseIdentifier:@"LegislatorTVCell"];
    
    if (![self.mode isEqualToString:@"CurrentCommitteeMembers"]) {
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"menuRow"];
        
        self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeAlways;
        
        _showMenu = YES;
    }
    else {
        
        self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
        
        self.gpsButton.tintColor = [UIColor clearColor];
        self.gpsButton.enabled = NO;
        
        UILabel* tlabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0, self.navigationController.navigationBar.frame.size.width, self.navigationController.navigationBar.frame.size.height)];
        tlabel.text = self.navigationItem.title;
        tlabel.textAlignment = NSTextAlignmentCenter;
        tlabel.textColor = [UIColor colorNamed:@"BlackOrWhite"];
        tlabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size: 17.0];
        tlabel.backgroundColor = [UIColor clearColor];
        tlabel.adjustsFontSizeToFitWidth = YES;
        self.navigationItem.titleView = tlabel;
    }
    
    _lastNameSort = [NSSortDescriptor sortDescriptorWithKey:@"last_name" ascending:YES];
    _firstNameSort = [NSSortDescriptor sortDescriptorWithKey:@"first_name" ascending:YES];
    _stateSort = [NSSortDescriptor sortDescriptorWithKey:@"state_name" ascending:YES];
    
    _searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.searchBar.placeholder = @"Search Legislator Last Name";
    
    self.searchController.delegate = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.searchController.searchBar.delegate = self;
    self.searchController.hidesNavigationBarDuringPresentation = NO;
        
    //self.searchController.searchBar.tintColor = [UIColor blackColor];
    //self.searchController.searchBar.barTintColor = [UIColor whiteColor];
    
    UIView *backgroundView = [(UITextField*)[self.searchController.searchBar valueForKey:@"searchField"] subviews].firstObject;
    
    //backgroundView.backgroundColor = [UIColor whiteColor];
    backgroundView.layer.cornerRadius = 10;
    backgroundView.clipsToBounds = YES;
    
    self.navigationItem.searchController = self.searchController;
    self.navigationItem.hidesSearchBarWhenScrolling = false;
    self.navigationItem.searchController.active = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didChangePreferredContentSize:)
                                                 name:UIContentSizeCategoryDidChangeNotification object:nil];
    
    
    self.progress = [[Progress alloc] init];
    
    _HUDSingleTap = [[ProgressTapGestureRecognizer alloc] initWithTarget:self.progress action:@selector(singleTap:)];
    _HUDSingleTap.navigationController = self.navigationController;
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if ((self.mode == (id)[NSNull null] || self.mode.length == 0 ) || [self.mode isEqualToString:@"All"]  ) {
            [self fetchAllLegislators:YES];
        }
        else if ([self.mode isEqualToString:@"CurrentCommitteeMembers"]) {
            
            self.hud = [Progress showGlobalProgressHUDWithTitle:@"Loading..."];
            [self.hud addGestureRecognizer:self->_HUDSingleTap];
            
            [self fetchLegislators:self.mode];
        }
    });
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    if ([self.searchController isActive]) {
        self.searchController.active = NO;
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIContentSizeCategoryDidChangeNotification
                                                  object:nil];

    self.searchController.searchResultsUpdater = nil;
    self.searchController.searchBar.delegate = nil;
    self.searchController.delegate = nil;
    self.searchController = nil;
    
    [self.searchController.view removeFromSuperview];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.navigationController.toolbarHidden = YES;
}

- (BOOL)slideNavigationControllerShouldDisplayLeftMenu {
    return _showMenu;
}
    
- (void)didChangePreferredContentSize:(NSNotification *)notification {
    [self.tableView reloadData];
}

- (void)handleRefresh:(UIRefreshControl *)refreshControl {
    self.searchController.searchBar.text = @"";

    [refreshControl endRefreshing];
    
    [self fetchAllLegislators:NO];
    [self.tableView layoutIfNeeded];
    
    [refreshControl endRefreshing];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    
    NSMutableArray *searchResults = [self.legislatorsArray mutableCopy];
    
    NSString *strippedString = [searchController.searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    /* %K is a key path
       %@ would be an object */
    
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"%K BEGINSWITH[c] %@", @"last_name", strippedString];
    
    if ([strippedString length] > 0) {
        _filteredLegislators = [[searchResults filteredArrayUsingPredicate:predicate] mutableCopy];
    }
    else {
        _filteredLegislators = [self.legislatorsArray mutableCopy];
    }
        
    if (self.tvSegmentedControl.selectedSegmentIndex == 0) {
        _filteredDictionary = [self partialIndexOfStatesFromLegislators:_filteredLegislators];
    }
    else {
        _filteredDictionary = [self partialIndexOfLastNameInitialFromLegislators:_filteredLegislators];
    }
    
    _filteredSectionTitles = [[_filteredDictionary allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    
    [self.tableView reloadData];
}
- (IBAction)locateLegislator:(id)sender {
    [self performSegueWithIdentifier:@"Webpage" sender:nil];
}

- (IBAction)segmentedControlAction:(UISegmentedControl *)sender {
    
    if (!self.searchController.active) {
        if (self.tvSegmentedControl.selectedSegmentIndex == 0) {
            self.legislatorsArray = [self.legislatorsArray sortedArrayUsingDescriptors:@[_stateSort,_lastNameSort,_firstNameSort]];
            self.legislatorsDictionary = [self partialIndexOfStatesFromLegislators:self.legislatorsArray];
        }
        else {
            self.legislatorsArray = [self.legislatorsArray sortedArrayUsingDescriptors:@[_lastNameSort,_firstNameSort]];
            self.legislatorsDictionary = [self partialIndexOfLastNameInitialFromLegislators:self.legislatorsArray];
        }
        
        _sectionTitles = [[self.legislatorsDictionary allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    }
    else {
        if (self.tvSegmentedControl.selectedSegmentIndex == 0) {
            _filteredLegislators = [_filteredLegislators sortedArrayUsingDescriptors:@[_stateSort,_lastNameSort,_firstNameSort]];
            _filteredDictionary = [self partialIndexOfStatesFromLegislators:_filteredLegislators];
        }
        else {
            _filteredLegislators = [_filteredLegislators sortedArrayUsingDescriptors:@[_lastNameSort,_firstNameSort]];
            _filteredDictionary = [self partialIndexOfLastNameInitialFromLegislators:_filteredLegislators];
        }
        
        _filteredSectionTitles = [[_filteredDictionary allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    }
    
    [self.tableView reloadData];
}

- (void)fetchAllLegislators:(BOOL)showProgress {
    
    if (showProgress) {
        self.hud = [Progress showGlobalProgressHUDWithTitle:@"Loading..."];
        [self.hud addGestureRecognizer:self.HUDSingleTap];
    }
    
    [self fetchLegislators:@"All"];
}

- (void)fetchLegislators:(NSString*)mode {
    
    if ([mode isEqualToString:@"All"]) {
        
        [DataManager fetchLegislators:nil all:YES chamber:@"All" block:^(NSArray *scanResult, NSError *error) {
            
            self.legislatorsArray = scanResult;
            
            [self setupTableView];
        }];
    }
    else if ([mode isEqualToString:@"CurrentCommitteeMembers"]) {
        
        if ([self.currentCommitteeMembers count] > 0) {
        
            NSMutableArray *tempLegislators = [[NSMutableArray alloc] init];
            
            if ([self.currentCommitteeMembers[0] respondsToSelector:@selector(stringValue)]) {
                
                for (int i = 0; i < [self.currentCommitteeMembers count]; i++) {
                    [tempLegislators addObject:[self.currentCommitteeMembers[i] stringValue]];
                }
            }
            else {
                tempLegislators = [self.currentCommitteeMembers copy];
            }
            
            [DataManager fetchLegislators:tempLegislators all:NO chamber:@"All" block:^(NSArray *scanResult, NSError *error) {
                
                self.legislatorsArray = scanResult;
                
                [self setupTableView];
            }];
        }
    }
}

- (void)setupTableView {
     dispatch_async(dispatch_get_main_queue(), ^{
         
        if (self.tvSegmentedControl.selectedSegmentIndex == 0) {
            self.legislatorsArray = [self.legislatorsArray sortedArrayUsingDescriptors:@[self.stateSort,self.lastNameSort,self.firstNameSort]];
            self.legislatorsDictionary = [self partialIndexOfStatesFromLegislators:self.legislatorsArray];
        }
        else {
            self.legislatorsArray = [self.legislatorsArray sortedArrayUsingDescriptors:@[self.lastNameSort,self.firstNameSort]];
            self.legislatorsDictionary = [self partialIndexOfLastNameInitialFromLegislators:self.legislatorsArray];
        }
    
        self.sectionTitles = [[self.legislatorsDictionary allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    
        if (self.tvSegmentedControl.selectedSegmentIndex == 0) {
            self.legislatorsArray = [self.legislatorsArray sortedArrayUsingDescriptors:@[self.stateSort,self.lastNameSort,self.firstNameSort]];
            self.legislatorsDictionary = [self partialIndexOfStatesFromLegislators:self.legislatorsArray];
        }
        else {
            self.legislatorsArray = [self.legislatorsArray sortedArrayUsingDescriptors:@[self.lastNameSort,self.firstNameSort]];
            self.legislatorsDictionary = [self partialIndexOfLastNameInitialFromLegislators:self.legislatorsArray];
        }
    
        self.sectionTitles = [[self.legislatorsDictionary allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    
        [self.tableView reloadData];
        [Progress dismissGlobalHUD];
    });
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (!self.searchController.active)
        return [(NSDictionary*)[self.legislatorsDictionary objectForKey:[_sectionTitles objectAtIndex:section]] count];
    return [(NSDictionary*)[_filteredDictionary objectForKey:[_filteredSectionTitles objectAtIndex:section]] count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    self.tableView.backgroundView = nil;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    
    if (!self.searchController.active)
        return [_sectionTitles count];
    else return [_filteredSectionTitles count];
}

- (NSDictionary *)partialIndexOfStatesFromLegislators:(NSArray *)legislators {

    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    NSArray *value;
    NSString *key;
    
    for (Legislator *legislator in legislators) {
        
        key = legislator.state_name;
        
        value = result[key];
        if (value == nil) {
            result[key] = [NSArray arrayWithObject:legislator]; // Create new array
        } else {
            result[key] = [value arrayByAddingObject:legislator]; // Add to existing
        }
    }
    
    return [result copy];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    if (!self.searchController.active) {
        if (self.tvSegmentedControl.selectedSegmentIndex == 0)
            return [[[self partialIndex:_sectionTitles] allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        else
            return _sectionTitles;
    }
    else {
        if (self.tvSegmentedControl.selectedSegmentIndex == 0)
            return [[[self partialIndex:_filteredSectionTitles] allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        else
            return _filteredSectionTitles;
    }
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    
    NSArray *array;
    
    if (!self.searchController.active)
        array = _sectionTitles;
    else array = _filteredSectionTitles;
    
    for (int i = 0; i < [array count]; i++) {
        if ([[(NSString*)array[i] substringToIndex:1] isEqualToString:title])
            return i;
    }
    
    return 0;
}

- (NSDictionary *)partialIndex:(NSArray *)array {
    
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    NSArray *value;
    NSString *key;
    
    for (NSString *string in array) {
        key = [string substringToIndex:1];
        value = result[key];
        
        if (value == nil) {
            result[key] = [NSArray arrayWithObject:string]; // Create new array
        } else {
            result[key] = [value arrayByAddingObject:string]; // Add to existing
        }
    }
    
    return [result copy];
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    LegislatorTVCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LegislatorTVCell" forIndexPath:indexPath];
    
    NSArray *sectionLegislators;
    
    if (!self.searchController.active)
        sectionLegislators = [self.legislatorsDictionary objectForKey:[_sectionTitles objectAtIndex:indexPath.section]];
    else sectionLegislators = [_filteredDictionary objectForKey:[_filteredSectionTitles objectAtIndex:indexPath.section]];
    
    Legislator *legislator = [sectionLegislators objectAtIndex:indexPath.row];
    
    cell.name.text = [NSString stringWithFormat:@"%@, %@ (%@.)",legislator.last_name,legislator.first_name,legislator.title];
    
    if ([legislator.district isKindOfClass:[NSNull class]] || [legislator.district intValue] == 0) {
        cell.location.text = [NSString stringWithFormat:@"(%@) %@",legislator.party,legislator.state_name];
    }
    else {
        cell.location.text = [NSString stringWithFormat:@"(%@) %@ - District %@",legislator.party,legislator.state_name,legislator.district];
    }
    

    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    //cell.name.textColor = [UIColor grayColor];
    //cell.location.textColor = [UIColor grayColor];
    cell.name.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    cell.location.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    cell.name.adjustsFontSizeToFitWidth = YES;
    cell.location.adjustsFontSizeToFitWidth = YES;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    self.hud = [Progress showGlobalProgressHUDWithTitle:@"Loading..."];
    [self.hud addGestureRecognizer:_HUDSingleTap];
    
    if (!self.searchController.active) {
        _sectionLegislators = [self.legislatorsDictionary objectForKey:[_sectionTitles objectAtIndex:indexPath.section]];
    }
    else {
        _sectionLegislators = [_filteredDictionary objectForKey:[_filteredSectionTitles objectAtIndex:indexPath.section]];
    }
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self performSegueWithIdentifier:@"LegislatorDetail" sender:[self.sectionLegislators objectAtIndex:indexPath.row]];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    });
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (!self.searchController.active) {
        return [_sectionTitles objectAtIndex:section];
    }
    return [_filteredSectionTitles objectAtIndex:section];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"LegislatorDetail"] ||
        [segue.identifier isEqualToString:@"LegislatorFavoriteDetail"]) {
        LegislatorDetailVC *tvc = [segue destinationViewController];
        Legislator *legislator = (Legislator*)sender;
        tvc.legislator = legislator;
        
        if (self.favorite) {
            self.favorite = NO;
            tvc.favorite = YES;
        }
        
        tvc.title = [NSString stringWithFormat:@"%@, %@",legislator.last_name,legislator.first_name];
    }
    
    else if ([segue.identifier isEqualToString:@"Webpage"]) {
        WebpageViewController *vc = [segue destinationViewController];
        vc.website = [[NSURL alloc] initWithString:@"https://www.house.gov/representatives/find/"];
        vc.title = @"Find Representative";
    }
}

@end
