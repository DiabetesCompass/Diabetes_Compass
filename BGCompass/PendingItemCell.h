//
//  PendingItemCell.h
//  CompassRose
//
//  Created by Jose Carrillo on 11/15/13.
//  Copyright (c) 2014 Clif Alferness. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PendingItemCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *itemName;
@property (weak, nonatomic) IBOutlet UILabel *itemValue;
@property (weak, nonatomic) IBOutlet UIView *line;


@end
