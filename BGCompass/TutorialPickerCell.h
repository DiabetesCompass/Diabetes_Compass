//
//  TutorialPickerCell.h
//  Compass
//
//  Created by Jose Carrillo on 2/25/14.
//  Copyright (c) 2014 Clif Alferness. All rights reserved.
//

#import "RETableViewCell.h"
#import <REPickerItem.h>

@interface TutorialPickerCell : RETableViewCell <UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate>

@property (strong, readonly, nonatomic) UITextField *textField;
@property (strong, readonly, nonatomic) UILabel *valueLabel;
@property (strong, readonly, nonatomic) UILabel *placeholderLabel;
@property (strong, readonly, nonatomic) UIPickerView *pickerView;
@property (strong, readwrite, nonatomic) REPickerItem *item;

@end