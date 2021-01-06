//
//  LegislatorVoterDetailGrpah1TableViewCell.m
//  Congress
//
//  Created by Eric Panchenko on 6/18/16.
//  Copyright © 2016 Eric Panchenko. All rights reserved.
//

#import "LegislatorVoterDetailGraphTableViewCell.h"

@implementation LegislatorVoterDetailGraphTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)prepareForReuse {
    
    [super prepareForReuse];
    
    for (UIView *view in [self.graphImageView subviews]) {
        [view removeFromSuperview];
    }
}

@end
