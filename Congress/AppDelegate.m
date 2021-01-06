//
//  AppDelegate.m
//  Congress
//
//  Created by Eric Panchenko on 8/29/15.
//  Copyright (c) 2015 Eric Panchenko. All rights reserved.
//

#import "AppDelegate.h"
#import "RealmFunctions.h"
#import "FavoriteLegislator.h"
#import "LegislatorVotesTableViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)handleVotesShortcut {
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    [[SlideNavigationController sharedInstance] popToRootAndSwitchToViewController:[storyboard instantiateViewControllerWithIdentifier:@"votes"]
                                                             withSlideOutAnimation:NO
                                                                     andCompletion:nil];
}

-(void)handleVotesLegislatorShortcut:(int)number {
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];

    LegislatorVotesTableViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"legislatorvotes"];
    
    RLMResults<FavoriteLegislator *>* favLegislators = [RealmFunctions getFavoriteLegislators];
    
    vc.title = @"Votes";
    
    NSMutableArray *legislators = [[NSMutableArray alloc] init];

    [legislators addObject:[favLegislators[number - 1] legislator_id]];

    [DataManager fetchLegislators:[legislators copy] all:NO chamber:@"All" block:^(NSArray *scanResult, NSError *error) {
        
        if (!error) {
            Legislator *legislator = scanResult[0];
            NSLog(@"%@",legislator.bioguide_id);
            vc.bioguide_id = legislator.bioguide_id;
            vc.chamber = legislator.chamber;
            dispatch_async(dispatch_get_main_queue(), ^{
                [[SlideNavigationController sharedInstance] popToRootAndSwitchToViewController:[storyboard instantiateViewControllerWithIdentifier:@"votes"]
                                                                         withSlideOutAnimation:NO
                                                                                 andCompletion:nil];
                [[SlideNavigationController sharedInstance] popToRootAndSwitchToViewController:vc
                                                            withSlideOutAnimation:NO
                                                            andCompletion:nil];
            });
        }
    }];

}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
            
    if ([[NSUserDefaults standardUserDefaults] doubleForKey:@"Version"] < 2.0) {
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"menuRow"];
        [[NSUserDefaults standardUserDefaults] setDouble:2.0 forKey:@"Version"];
    }
    else if ([[NSUserDefaults standardUserDefaults] doubleForKey:@"Version"] == 2.0) {
        [[NSUserDefaults standardUserDefaults] setDouble:2.3 forKey:@"Version"];
        if ([[NSUserDefaults standardUserDefaults] integerForKey:@"menuRow"] == 1) {
            [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"menuRow"];
        }
    }
        
    AWSServiceManager.defaultServiceManager.defaultServiceConfiguration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionUSEast2 credentialsProvider:[[AWSCognitoCredentialsProvider alloc] initWithRegionType:AWSRegionUSEast2 identityPoolId:awsIdentity]];
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                             bundle: nil];
    
    LeftMenuViewController *leftMenu = (LeftMenuViewController*)[mainStoryboard
                                                                 instantiateViewControllerWithIdentifier: @"LeftMenuViewController"];
    
    [SlideNavigationController sharedInstance].leftMenu = leftMenu;
    [SlideNavigationController sharedInstance].menuRevealAnimationDuration = .18;
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    
    // Get our Realm file's parent directory
    NSString *folderPath = realm.configuration.fileURL.URLByDeletingLastPathComponent.path;
    
    // Disable file protection for this directory
    [[NSFileManager defaultManager] setAttributes:@{NSFileProtectionKey: NSFileProtectionNone}
                                     ofItemAtPath:folderPath error:nil];
    
    return true;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
}


@end
