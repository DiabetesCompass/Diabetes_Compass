//
//  TutorialTextCell.h
//  Compass
//
//  Created by Jose Carrillo on 2/24/14.
//  Copyright (c) 2014 Clif Alferness. All rights reserved.
//

#import "RETableViewCell.h"
#import "TutorialTextItem.h"

@interface TutorialTextCell : RETableViewCell <UITextFieldDelegate>

@property (strong, readwrite, nonatomic) TutorialTextItem *item;
@property (strong, readonly, nonatomic) UITextField *textField;

@end
