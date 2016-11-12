//
//  EditItemViewController.h
//  BG Compass
//
//  Created by Jose Carrillo and Christopher Balcells on 3/1/14.
//  Copyright (c) 2014 Clif Alferness. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ANBlurredImageView.h"
#import <RMDateSelectionViewController.h>

@interface EditItemViewController : UIViewController <UITextFieldDelegate>

@property (nonatomic, strong) id item;
@property (nonatomic, assign) BOOL editingMode;
@property (nonatomic, assign) BOOL blurBackground;
@property (weak, nonatomic) IBOutlet UITextField *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *valueTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *valueUnitsLabel;
@property (weak, nonatomic) IBOutlet UITextField *valueField;
@property (weak, nonatomic) IBOutlet UILabel *carbsTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *carbsUnitsLabel;
@property (weak, nonatomic) IBOutlet UITextField *carbsField;

@property(strong, nonatomic) ANBlurredImageView* blur;
@property (weak, nonatomic) IBOutlet UIButton *dateButton;

- (IBAction)doneClicked:(id)sender;
- (IBAction)dateClicked:(id)sender;
@end
