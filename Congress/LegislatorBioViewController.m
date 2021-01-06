//
//  LegislatorBioViewController.m
//  Congress
//
//  Created by Eric Panchenko on 9/21/15.
//  Copyright © 2015 Eric Panchenko. All rights reserved.
//

#import "LegislatorBioViewController.h"
#import "UIColor+Constants.h"

@interface LegislatorBioViewController ()

@end

@implementation LegislatorBioViewController


NSString *bioString;

- (void)viewDidLoad {
    [super viewDidLoad];

    self.progress = [[Progress alloc] init];
    
    _HUDSingleTap = [[ProgressTapGestureRecognizer alloc]initWithTarget:self.progress action:@selector(singleTap:)];
    _HUDSingleTap.navigationController = self.navigationController;
    
    self.hud = [Progress showGlobalProgressHUDWithTitle:@"Loading..."];
    [self.hud addGestureRecognizer:_HUDSingleTap];
    
    self.textView.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didChangePreferredContentSize:)
                                                 name:UIContentSizeCategoryDidChangeNotification object:nil];
    
    [self loadBiography];
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIContentSizeCategoryDidChangeNotification
                                                  object:nil];
}
    
- (void)didChangePreferredContentSize:(NSNotification *)notification
{
    self.textView.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
}

- (BOOL)slideNavigationControllerShouldDisplayLeftMenu {
    return NO;
}
    
- (void) loadBiography {
     
     NSURL *url = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"https://bioguideretro.congress.gov/Home/MemberDetails?memIndex=%@",self.bioguideid]];
    
     //https://github.com/nolanw/HTMLReader
          
     bioString = @"";
    
     NSURLSession *session = [NSURLSession sharedSession];
     [[session dataTaskWithURL:url completionHandler:
     ^(NSData *data, NSURLResponse *response, NSError *error) {
     
         if (!error) {
             NSString *contentType = nil;
             
             if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                 NSDictionary *headers = [(NSHTTPURLResponse *)response allHeaderFields];
                 contentType = headers[@"Content-Type"];
             }
             
             HTMLDocument *home = [HTMLDocument documentWithData:data contentTypeHeader:contentType];
             
             HTMLElement *paragraph = [home firstNodeMatchingSelector:@"biography"];
             
             bioString = [paragraph.textContent stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                          
             bioString = [[bioString stringByReplacingOccurrencesOfString:@"\n" withString:@" "] stringByReplacingOccurrencesOfString:@"   " withString:@" "];
             
             if (![bioString isEqualToString:@""]) {
                 bioString = [NSString stringWithFormat:@"%@\n\nSource: Biographical Directory of the U.S. Congress",bioString];
             }
             dispatch_async(dispatch_get_main_queue(), ^{
                 self.textView.text = bioString;
                 [Progress dismissGlobalHUD];
                 [self.textView flashScrollIndicators];                 
             });
         }
         else {
             dispatch_async(dispatch_get_main_queue(), ^{
                 [Progress dismissGlobalHUD];
                 
                 [UIAlertController showAlertInViewController:self withTitle:@"Error" message:[error localizedDescription] cancelButtonTitle:@"OK" destructiveButtonTitle:nil otherButtonTitles:nil tapBlock:^(UIAlertController *controller, UIAlertAction *action, NSInteger buttonIndex) {
                 }];
             });
         }
     }] resume];
 }


@end
