//
//  AmendmentsTVC.h
//  Congress
//
//  Created by Eric Panchenko on 6/11/17.
//  Copyright © 2017 Eric Panchenko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIAlertController+Blocks.h"
#import "Amendment.h"
#import "TVCMethods.h"
#import "LegislatorVoteCellTableViewCell.h"
#import "WebpageViewController.h"

@interface AmendmentsTVC : UITableViewController

@property (nonatomic, strong) NSArray *amendments;
@property (nonatomic, strong) TVCMethods *tvcMethods;

@end
