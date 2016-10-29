//
//  ExpandedTrendView.h
//  Compass
//
//  Created by Jose Carrillo and Christopher Balcells on 12/8/13.
//  Copyright (c) 2013 Clif Alferness. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ExpandedTrendView : UIView
@property (weak, nonatomic) IBOutlet UIButton *trendsButton;
@property (weak, nonatomic) IBOutlet UILabel *trendTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *noDataLabel;
@property (weak, nonatomic) IBOutlet UILabel *warningLabel;

- (IBAction)clickedTrends:(id)sender;
@end
