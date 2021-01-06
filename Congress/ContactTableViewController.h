//
//  ContactTableViewController.h
//  Congress
//
//  Created by ERIC on 5/18/16.
//  Copyright © 2016 Eric Panchenko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIAlertController+Blocks.h"
#import "WebpageViewController.h"

@interface ContactTableViewController : UITableViewController

@property (nonatomic, strong) NSString *phone;
@property (nonatomic, strong) NSString *website;
@property (nonatomic, strong) NSString *facebook_account;
@property (nonatomic, strong) NSString *youtube_account;
@property (nonatomic, strong) NSString *twitter_account;

@end
