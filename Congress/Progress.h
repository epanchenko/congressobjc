//
//  Progress.h
//  Congress
//
//  Created by ERIC on 9/12/15.
//  Copyright © 2015 Eric Panchenko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MBProgressHUD.h"
#import "ProgressTapGestureRecognizer.h"

@interface Progress : NSObject
+ (MBProgressHUD *)showGlobalProgressHUDWithTitle:(NSString *)title;
+ (void)dismissGlobalHUD;
- (void)singleTap:(ProgressTapGestureRecognizer*)tapGR;
@end
