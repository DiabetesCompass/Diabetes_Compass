//
//  TutorialTitleCell.m
//  Compass
//
//  Created by Jose Carrillo on 2/25/14.
//  Copyright (c) 2014 Clif Alferness. All rights reserved.
//

#import "TutorialTitleCell.h"
#import <RETableViewManager.h>

@implementation TutorialTitleCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


- (void)cellDidLoad
{
    [super cellDidLoad];
    self.actionBar = [[REActionBar alloc] initWithDelegate:self];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = [UIColor clearColor];
}



- (void)cellWillAppear
{
    [self updateActionBarNavigationControl];
    self.selectionStyle = self.section.style.defaultCellSelectionStyle;
    if (!self.titleLabel) {
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 35, 300, 20)];
        [self addSubview:self.titleLabel];
    }

    
    if ([self.item isKindOfClass:[NSString class]]) {
        self.titleLabel.text = (NSString *)self.item;
        self.titleLabel.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    } else {
        RETableViewItem *item = (RETableViewItem *)self.item;
        self.titleLabel.text = item.title;
        self.titleLabel.backgroundColor = [UIColor clearColor];
        self.accessoryType = item.accessoryType;
        self.accessoryView = item.accessoryView;
        self.titleLabel.textAlignment = item.textAlignment;
        if (self.selectionStyle != UITableViewCellSelectionStyleNone)
            self.selectionStyle = item.selectionStyle;
        self.imageView.image = item.image;
        self.imageView.highlightedImage = item.highlightedImage;
    }
    if (self.titleLabel.text.length == 0)
        self.titleLabel.text = @" ";
    
    
    self.userInteractionEnabled = NO;
    self.titleLabel.textColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.8];
    self.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:16];
}

+ (CGFloat)heightWithItem:(RETableViewItem *)item tableViewManager:(RETableViewManager *)tableViewManager
{
    return 60;
}

@end

