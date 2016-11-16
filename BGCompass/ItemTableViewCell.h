//
//  ItemTableViewCell.h
//  CompassRose
//
//  Created by Jose Carrillo on 11/10/13.
//  Copyright (c) 2014 Clif Alferness. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ItemTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *infoNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UIButton *favoritesButton;

@end
