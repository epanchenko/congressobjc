//
//  ShowNoAnimationSegue.m
//  Congress
//
//  Created by Eric Panchenko on 9/11/16.
//  Copyright © 2016 Eric Panchenko. All rights reserved.
//

#import "ShowNoAnimationSegue.h"

@implementation ShowNoAnimationSegue

- (void)perform {
    
    [self.sourceViewController.navigationController pushViewController:self.destinationViewController animated:NO];
}

@end
