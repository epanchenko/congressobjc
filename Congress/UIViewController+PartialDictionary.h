//
//  UIViewController+PartialDictionary.h
//  Congress
//
//  Created by Eric Panchenko on 9/6/15.
//  Copyright (c) 2015 Eric Panchenko. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (PartialDictionary)

- (NSDictionary *)partialIndexOfLastNameInitialFromLegislators:(NSArray *)legislators;
@end
