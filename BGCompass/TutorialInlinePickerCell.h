//
//  TutorialInlinePickerCell.h
//  Compass
//
//  Created by Jose Carrillo on 2/25/14.
//  Copyright (c) 2014 Clif Alferness. All rights reserved.
//

#import <RETableViewCell.h>
#import <REInlinePickerItem.h>

@interface TutorialInlinePickerCell : RETableViewCell <UIPickerViewDataSource, UIPickerViewDelegate>

@property (strong, readwrite, nonatomic) REInlinePickerItem *item;

@end
