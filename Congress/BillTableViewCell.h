//
//  BillTableViewCell.h
//  Congress
//
//  Created by Eric Panchenko on 8/5/16.
//  Copyright © 2016 Eric Panchenko. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BillTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *billNumber;
@property (weak, nonatomic) IBOutlet UILabel *title;

@end
