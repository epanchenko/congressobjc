//
//  ProgressTapGestureRecognizer.h
//  Congress
//
//  Created by Eric Panchenko on 7/17/16.
//  Copyright © 2016 Eric Panchenko. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProgressTapGestureRecognizer : UITapGestureRecognizer

@property (strong, nonatomic) UINavigationController* navigationController;

@end
