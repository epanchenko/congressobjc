//
//  WebpageViewController.h
//  Congress
//
//  Created by Eric Panchenko on 5/14/16.
//  Copyright © 2016 Eric Panchenko. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebpageViewController : UIViewController

@property (nonatomic, strong) NSURL *website;
@property (weak, nonatomic) IBOutlet UIWebView *webview;

@end
