//
//  CollapsedTrendView.h
//  Compass
//
//  Created by Jose Carrillo and Chris Balcells on 12/8/13.
//  Copyright (c) 2013 Clif Alferness. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CollapsedTrendView : UIView
@property (weak, nonatomic) IBOutlet UILabel *trendTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *valueLabel;

@property (assign, nonatomic) BOOL expandable;

@end
