//
//  FavoritesViewController.h
//  
//
//  Created by ERIC on 9/3/16.
//
//

#import <UIKit/UIKit.h>
#import "DataManager.h"
#import "RealmFunctions.h"
#import "SlideNavigationController.h"

@interface FavoritesViewController : UIViewController<UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating, UITableViewDataSource, UITableViewDelegate, SlideNavigationControllerDelegate>

@property (nonatomic, strong) UISearchController *searchController;

@end
