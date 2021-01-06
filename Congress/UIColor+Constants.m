//
//  UIColor+Constants.m
//  Congress
//
//  Created by ERIC on 6/18/16.
//  Copyright © 2016 Eric Panchenko. All rights reserved.
//

#import "UIColor+Constants.h"

@implementation UIColor (Constants)

+(UIColor *)otherColor:(int)row {
    
    if (row == 0) {
        return [UIColor colorWithRed:0.58 green:0.57 blue:0.61 alpha:1];
    }
    else if (row == 1) {
        return [UIColor orangeColor];
    }
    else if (row == 2) {
        return [UIColor brownColor];
    }
    else {
        return [UIColor colorWithRed:0.945 green:0.56 blue:0.777 alpha:1.0];
    }
}

@end
