//
//  SummaryViewController.m
//  Congress
//
//  Created by Eric Panchenko on 7/25/16.
//  Copyright © 2016 Eric Panchenko. All rights reserved.
//

#import "SummaryViewController.h"

@interface SummaryViewController ()

@end

@implementation SummaryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UILabel* tlabel=[[UILabel alloc] initWithFrame:CGRectMake(0,0, self.navigationController.navigationBar.frame.size.width, self.navigationController.navigationBar.frame.size.height)];
    tlabel.text = self.navigationItem.title;
    tlabel.textAlignment = NSTextAlignmentCenter;
    //tlabel.textColor = [UIColor blackColor];
    tlabel.textColor = [UIColor colorNamed:@"BlackOrWhite"];
    tlabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size: 17.0];
    tlabel.backgroundColor = [UIColor clearColor];
    tlabel.adjustsFontSizeToFitWidth = YES;
    [tlabel setMinimumScaleFactor:10.0/tlabel.font.pointSize];
    self.navigationItem.titleView = tlabel;
    
    self.textView.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didChangePreferredContentSize:)
                                                 name:UIContentSizeCategoryDidChangeNotification object:nil];
    
    [self fetchData];
    
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIContentSizeCategoryDidChangeNotification
                                                  object:nil];
}

- (void)didChangePreferredContentSize:(NSNotification *)notification {
    self.textView.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
}

- (void)fetchData {    
    self.textView.text = [NSString stringWithFormat:@"%@%@",self.summary,@"\n\nSource: Library of Congress"];
}


@end
