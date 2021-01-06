//
//  WebpageViewController.m
//  Congress
//
//  Created by Eric Panchenko on 5/14/16.
//  Copyright © 2016 Eric Panchenko. All rights reserved.
//

#import "WebpageViewController.h"

@interface WebpageViewController ()

@end

@implementation WebpageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UILabel* tlabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0, self.navigationController.navigationBar.frame.size.width, self.navigationController.navigationBar.frame.size.height)];
    tlabel.text = self.navigationItem.title;
    tlabel.textAlignment = NSTextAlignmentCenter;
    //tlabel.textColor = [UIColor blackColor];
    tlabel.textColor = [UIColor colorNamed:@"BlackOrWhite"];
    tlabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size: 17.0];
    tlabel.backgroundColor = [UIColor clearColor];
    tlabel.adjustsFontSizeToFitWidth = YES;
    [tlabel setMinimumScaleFactor:10.0/tlabel.font.pointSize];
    self.navigationItem.titleView = tlabel;
    
    NSURLRequest *request = [NSURLRequest requestWithURL:self.website cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:30];
    
    [self.webview loadRequest:request];
}
    
@end
