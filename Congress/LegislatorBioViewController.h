//
//  LegislatorBioViewController.h
//  Congress
//
//  Created by Eric Panchenko on 9/21/15.
//  Copyright © 2015 Eric Panchenko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HTMLReader.h"
#import "UIAlertController+Blocks.h"
#import "Progress.h"
#import "SlideNavigationController.h"


@interface LegislatorBioViewController : UIViewController<SlideNavigationControllerDelegate>
    
@property (weak, nonatomic) IBOutlet UITextView *textView;

@property (strong, nonatomic) NSString *bioguideid;
@property (strong, nonatomic) NSString *lastName;
@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic, strong) ProgressTapGestureRecognizer *HUDSingleTap;
@property (nonatomic, strong) Progress *progress;

- (void) loadBiography;
@end
