//
//  AppDelegate.h
//  Congress
//
//  Created by Eric Panchenko on 8/29/15.
//  Copyright (c) 2015 Eric Panchenko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"
#import "Vote.h"
#import <AWSCore/AWSCore.h>
#import <AWSCognito/AWSCognito.h>
#import "SlideNavigationController.h"
#import "LeftMenuViewController.h"


@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@end

