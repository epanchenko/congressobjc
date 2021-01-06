//
//  MenuViewController.m
//  SlideMenu
//
//  Created by Aryan Gh on 4/24/13.
//  Copyright (c) 2013 Aryan Ghassemi. All rights reserved.
//

#import "LeftMenuViewController.h"


@implementation LeftMenuViewController

#pragma mark - UIViewController Methods -

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self.slideOutAnimationEnabled = YES;
	
	return [super initWithCoder:aDecoder];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	    
	self.tableView.separatorColor = [UIColor lightGrayColor];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    self.tableView.separatorStyle = UITableViewStylePlain;
    self.tableView.scrollEnabled = NO;
}

#pragma mark - UITableView Delegate & Datasource -

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    int fontSize;
    
    if (IS_IPHONE_SMALL)
        fontSize = 17;
    else
        fontSize = 19;
    
    cell.textLabel.font = [UIFont fontWithDescriptor:[cell.textLabel.font.fontDescriptor fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold]
                                                size:fontSize];
}
    
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return 6;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 20)];
	view.backgroundColor = [UIColor clearColor];
	return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"leftMenuCell"];
    
	switch (indexPath.row)
	{
		case 0:
			cell.textLabel.text = @"Legislators";
			break;
			
		case 1:
			cell.textLabel.text = @"Nominations";
			break;
			
		case 2:
			cell.textLabel.text = @"Committees";
			break;
            
        case 3:
            cell.textLabel.text = @"Votes";
            break;
            
        case 4:
            cell.textLabel.text = @"Favorites";
            break;
            
        case 5:
            cell.textLabel.text = @"Data Sources";
            break;
	}
	
	cell.backgroundColor = [UIColor clearColor];
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
															 bundle: nil];
	
	UIViewController *vc;
	
    switch (indexPath.row) {
        case 0:
            vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"legislators"];
            break;
        case 1:
            vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"nominations"];
            break;
        case 2:
            vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"committees"];
            break;
        case 3:
            vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"votes"];
            break;
        case 4:
            vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"favorites"];
            break;
        case 5:
            vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"about"];
            break;
    }
	
	[[SlideNavigationController sharedInstance] popToRootAndSwitchToViewController:vc
															 withSlideOutAnimation:self.slideOutAnimationEnabled
																	 andCompletion:nil];
}

@end
