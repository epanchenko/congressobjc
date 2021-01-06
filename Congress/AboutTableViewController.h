//
//  AboutTableViewController.h
//  Congress
//
//  Created by Eric Panchenko on 10/12/17.
//  Copyright © 2017 Eric Panchenko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebpageViewController.h"
#import "TVCMethods.h"
#import "SlideNavigationController.h"

@interface AboutTableViewController : UITableViewController<SlideNavigationControllerDelegate>

@property (nonatomic, strong) TVCMethods *tvcMethods;

@end
