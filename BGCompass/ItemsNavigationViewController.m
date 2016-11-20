//
//  ItemsNavigationViewController.m
//  CompassRose
//
//  Created by Jose Carrillo and Christopher Balcells on 11/21/13.
//  Copyright (c) 2013 Clif Alferness. All rights reserved.
//

#import "ItemsNavigationViewController.h"
#import "ItemsNavigationTransitionControllerDelegate.h"

@interface ItemsNavigationViewController ()

@property(strong, nonatomic) ItemsNavigationTransitionControllerDelegate *transitionController;

@end

@implementation ItemsNavigationViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.transitionController = [ItemsNavigationTransitionControllerDelegate new];
    self.delegate = self.transitionController;
    [self.navigationBar setTintColor:[UIColor whiteColor]];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}


@end
