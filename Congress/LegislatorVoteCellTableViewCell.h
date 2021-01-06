//
//  LegislatorVoteCellTableViewCell.h
//  Congress
//
//  Created by Eric Panchenko on 6/4/16.
//  Copyright © 2016 Eric Panchenko. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LegislatorVoteCellTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *billTitle;
@property (weak, nonatomic) IBOutlet UILabel *question;

@property (weak, nonatomic) IBOutlet UILabel *resultLabel;



@end
