//
//  SummaryViewController.h
//  Congress
//
//  Created by Eric Panchenko on 7/25/16.
//  Copyright © 2016 Eric Panchenko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"
#import "UIAlertController+Blocks.h"
#import "SlideNavigationController.h"

@interface SummaryViewController : UIViewController

@property (nonatomic, strong) NSString *summary;

@property (weak, nonatomic) IBOutlet UITextView *textView;

@end
