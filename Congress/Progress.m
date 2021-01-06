//
//  Progress.m
//  Congress
//
//  Created by ERIC on 9/12/15.
//  Copyright © 2015 Eric Panchenko. All rights reserved.
//

#import "Progress.h"

@implementation Progress

+ (void)dismissGlobalHUD {
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD hideHUDForView:window animated:YES];
    });
}

+ (MBProgressHUD *)showGlobalProgressHUDWithTitle:(NSString *)title {
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    
    __block MBProgressHUD *hud;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD hideHUDForView:window animated:YES];
        hud = [MBProgressHUD showHUDAddedTo:window animated:YES];
        hud.label.text = title;
    });
    
    return hud;
}

- (void)singleTap:(ProgressTapGestureRecognizer*)tapGR {

    dispatch_async(dispatch_get_main_queue(), ^{
        [Progress dismissGlobalHUD];
        [tapGR.navigationController popViewControllerAnimated:YES];
    });
    
}



@end
