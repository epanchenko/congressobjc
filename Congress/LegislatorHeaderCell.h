//
//  LegislatorHeaderCell.h
//  Congress
//
//  Created by Eric Panchenko on 9/7/15.
//  Copyright (c) 2015 Eric Panchenko. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LegislatorHeaderCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *legislatorImageView;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (weak, nonatomic) IBOutlet UILabel *name2Label;
@property (weak, nonatomic) IBOutlet UILabel *roleLabel;
@property (weak, nonatomic) IBOutlet UILabel *nextElectionLabel;

@end
