//
//  ContactTableViewController.m
//  Congress
//
//  Created by ERIC on 5/18/16.
//  Copyright © 2016 Eric Panchenko. All rights reserved.
//

#import "ContactTableViewController.h"
#import "UIColor+Constants.h"
#import "TVCMethods.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>

@interface ContactTableViewController ()

@property (nonatomic,strong) TVCMethods *tvcMethods;
@end

@implementation ContactTableViewController

int websiteRow = 1,  phoneRow = 0, twitterRow = 2, youtubeRow = 3, facebookRow = 4;

NSURL *callURL;
long iosVersion;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.estimatedRowHeight = 50.0f;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    self.tvcMethods = [[TVCMethods alloc] init];
    self.tvcMethods.tableView = self.tableView;
    
    [[NSNotificationCenter defaultCenter] addObserver:self.tvcMethods
                                             selector:@selector(didChangePreferredContentSize:)
                                                 name:UIContentSizeCategoryDidChangeNotification object:nil];
    
    iosVersion = [[NSProcessInfo processInfo] operatingSystemVersion].majorVersion;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIContentSizeCategoryDidChangeNotification
                                                  object:nil];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == phoneRow) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PhoneCell" forIndexPath:indexPath];
        
        NSLocale *currentLocale = [NSLocale currentLocale];  // get the current locale.
        NSString *countryCode = [currentLocale objectForKey:NSLocaleCountryCode];
        
        cell.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
        
        if (self.phone == (id)[NSNull null] || self.phone.length == 0 ) {
            cell.textLabel.text = @"Phone";
        }
        else {
            cell.textLabel.text = [NSString stringWithFormat:@"Phone %@",self.phone];
        }
        
        BOOL makePhoneCall = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tel://"]];
       
        if (makePhoneCall) {
            // Device supports phone calls, lets confirm it can place one right now
            NSString *mnc = [[[[CTTelephonyNetworkInfo alloc] init] subscriberCellularProvider] mobileNetworkCode];
            if (([mnc length] == 0) || ([mnc isEqualToString:@"65535"])) {
                // Device cannot place a call at this time.  SIM might be removed.
                makePhoneCall = NO;
            }
        }
        
        if ((!([self.phone length] > 0
              && [countryCode isEqualToString:@"US"]))
            || !(makePhoneCall)) {
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.textLabel.enabled = NO;
            cell.userInteractionEnabled = false;
        }
        else {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        
        return cell;
    }
    else if (indexPath.row == websiteRow) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WebsiteCell" forIndexPath:indexPath];
        
        cell.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
        cell.textLabel.text = @"Website";
        
        if (self.website == (id)[NSNull null] || self.website.length == 0) {
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.textLabel.enabled = NO;
            cell.userInteractionEnabled = false;
        }
        else {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        
        return cell;
    }
    else if (indexPath.row == youtubeRow) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"YoutubeCell" forIndexPath:indexPath];
        
        cell.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
        cell.textLabel.text = @"YouTube";
        
        if (self.youtube_account == (id)[NSNull null] || self.youtube_account.length == 0) {
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.textLabel.enabled = NO;
            cell.userInteractionEnabled = false;
        }

        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        return cell;
    }
    else if (indexPath.row == twitterRow) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TwitterCell" forIndexPath:indexPath];
        
        cell.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
        cell.textLabel.text = [NSString stringWithFormat:@"Twitter @%@",self.twitter_account];
        
        if (self.twitter_account == (id)[NSNull null] || self.twitter_account.length == 0) {
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.textLabel.enabled = NO;
            cell.userInteractionEnabled = false;
        }

        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        return cell;
    }
    else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FacebookCell" forIndexPath:indexPath];
        
        cell.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
        cell.textLabel.text = @"Facebook";
        
        if (self.facebook_account == (id)[NSNull null] || self.facebook_account.length == 0) {
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.textLabel.enabled = NO;
            cell.userInteractionEnabled = false;
        }

        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        return cell;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == phoneRow) {
        
        if (!(self.phone == (id)[NSNull null] || self.phone.length == 0)) {
            
            NSString *phoneStr = [NSString stringWithFormat:@"1-%@",self.phone];
            
            callURL = [NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",phoneStr]];
            
            if ([[UIApplication sharedApplication] canOpenURL:callURL]) {
                UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
                
                [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                    
                    // Cancel button tappped.
                    [self dismissViewControllerAnimated:YES completion:^{
                    }];
                }]];
                
                [actionSheet addAction:[UIAlertAction actionWithTitle:[NSString stringWithFormat:@"Call %@",self.phone] style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                    
                    [[UIApplication sharedApplication] openURL:callURL];
                    
                    [self dismissViewControllerAnimated:YES completion:^{
                    }];
                }]];
                
                [self presentViewController:actionSheet animated:YES completion:nil];
            }
            else {                
                [UIAlertController showAlertInViewController:self withTitle:@"Error" message:@"Cannot make phone call." cancelButtonTitle:@"OK" destructiveButtonTitle:nil otherButtonTitles:nil tapBlock:^(UIAlertController *controller, UIAlertAction *action, NSInteger buttonIndex) {
                }];
            }
        }
    }

    else if (indexPath.row == websiteRow) {
        if (!(self.website == (id)[NSNull null] || self.website.length == 0)) {
            callURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@",self.website]];
            if (iosVersion >= 9) {
                [[UIApplication sharedApplication] openURL:callURL];
            }
            else {
                [self performSegueWithIdentifier:@"Webpage" sender:nil];
            }
        }
    }
    else if (indexPath.row == facebookRow) {
        if (!(self.facebook_account == (id)[NSNull null] || self.facebook_account.length == 0)) {
            callURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://facebook.com/%@",self.facebook_account]];
            if (iosVersion >= 9) {
                [[UIApplication sharedApplication] openURL:callURL];
            }
            else {
                [self performSegueWithIdentifier:@"Webpage" sender:nil];
            }
        }
    }
    else if (indexPath.row == youtubeRow) {
        if (!(self.youtube_account == (id)[NSNull null] || self.youtube_account.length == 0)) {
            callURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://youtube.com/%@",self.youtube_account]];
            if (iosVersion >= 9) {
                [[UIApplication sharedApplication] openURL:callURL];
            }
            else {
                [self performSegueWithIdentifier:@"Webpage" sender:nil];
            }
        }
    }
    else if (indexPath.row == twitterRow) {
        if (!(self.twitter_account == (id)[NSNull null] || self.twitter_account.length == 0)) {
            callURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://twitter.com/%@",self.twitter_account]];
            if (iosVersion >= 9) {
                [[UIApplication sharedApplication] openURL:callURL];
            }
            else {
                [self performSegueWithIdentifier:@"Webpage" sender:nil];
            }
        }
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"Webpage"]) {
        WebpageViewController *vc = [segue destinationViewController];
        vc.website = callURL;
        vc.title = @"Website";
    }
}


@end
