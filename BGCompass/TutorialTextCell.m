//
//  TutorialTextCell.m
//  Compass
//
//  Created by Jose Carrillo on 2/24/14.
//  Copyright (c) 2014 Clif Alferness. All rights reserved.
//

#import "TutorialTextCell.h"
#import "RETableViewManager.h"

@interface TutorialTextCell ()

@property (strong, readwrite, nonatomic) UITextField *textField;

@end

@implementation TutorialTextCell

+ (BOOL)canFocusWithItem:(RETableViewItem *)item
{
    return YES;
}

#pragma mark -
#pragma mark Lifecycle

- (void)cellDidLoad
{
    [super cellDidLoad];
    self.textLabel.backgroundColor = [UIColor clearColor];
    self.textLabel.textColor = [UIColor whiteColor];
    self.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.2];
    
    self.textField = [[UITextField alloc] initWithFrame:CGRectNull];
    self.textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.textField.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    self.textField.inputAccessoryView = self.actionBar;
    self.textField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.textField.delegate = self;
    
    [self.textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    self.textField.textColor = [UIColor whiteColor];
    
    [self.contentView addSubview:self.textField];
}

- (void)cellWillAppear
{
    [super cellWillAppear];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.textLabel.text = self.item.title.length == 0 ? @" " : self.item.title;
    self.textField.text = self.item.value;
    self.textField.placeholder = self.item.placeholder;
    self.textField.font = [UIFont systemFontOfSize:17];
    self.textField.autocapitalizationType = self.item.autocapitalizationType;
    self.textField.autocorrectionType = self.item.autocorrectionType;
    self.textField.spellCheckingType = self.item.spellCheckingType;
    self.textField.keyboardType = self.item.keyboardType;
    self.textField.keyboardAppearance = self.item.keyboardAppearance;
    self.textField.returnKeyType = self.item.returnKeyType;
    self.textField.enablesReturnKeyAutomatically = self.item.enablesReturnKeyAutomatically;
    self.textField.secureTextEntry = self.item.secureTextEntry;
    self.textField.clearButtonMode = self.item.clearButtonMode;
    self.textField.clearsOnBeginEditing = self.item.clearsOnBeginEditing;
    self.textField.textAlignment = NSTextAlignmentRight;

    self.actionBar.barStyle = self.item.keyboardAppearance == UIKeyboardAppearanceAlert ? UIBarStyleBlack : UIBarStyleDefault;
}

- (UIResponder *)responder
{
    return self.textField;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self layoutDetailView:self.textField minimumWidth:0];
    
    if ([self.tableViewManager.delegate respondsToSelector:@selector(tableView:willLayoutCellSubviews:forRowAtIndexPath:)])
        [self.tableViewManager.delegate tableView:self.tableViewManager.tableView willLayoutCellSubviews:self forRowAtIndexPath:[self.tableViewManager.tableView indexPathForCell:self]];
}

#pragma mark -
#pragma mark Text field events

- (void)textFieldDidChange:(UITextField *)textField
{
    self.item.value = textField.text;
    if (self.item.onChange)
        self.item.onChange(self.item);
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    NSIndexPath *indexPath = [self indexPathForNextResponder];
    if (indexPath) {
        textField.returnKeyType = UIReturnKeyNext;
    } else {
        textField.returnKeyType = self.item.returnKeyType;
    }
    [self updateActionBarNavigationControl];
    [self.parentTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.rowIndex inSection:self.sectionIndex] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    if (self.item.onBeginEditing)
        self.item.onBeginEditing(self.item);
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if (self.item.onEndEditing)
        self.item.onEndEditing(self.item);
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (self.item.onReturn)
        self.item.onReturn(self.item);
    if (self.item.onEndEditing)
        self.item.onEndEditing(self.item);
    NSIndexPath *indexPath = [self indexPathForNextResponder];
    if (!indexPath) {
        [self endEditing:YES];
        return YES;
    }
    RETableViewCell *cell = (RETableViewCell *)[self.parentTableView cellForRowAtIndexPath:indexPath];
    [cell.responder becomeFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (self.item.onChangeCharacterInRange)
        self.item.onChangeCharacterInRange(self.item, range, string);
    
    if (self.item.charactersLimit) {
        NSUInteger newLength = textField.text.length + string.length - range.length;
        return newLength <= self.item.charactersLimit;
    }
    
    return YES;
}


@end
