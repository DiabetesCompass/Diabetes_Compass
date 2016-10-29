//
//  UPCScannerViewController.h
//  BGCompass
//
//  Created by Christopher Balcells on 4/1/14.
//  Copyright (c) 2014 Clif Alferness. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UPCScannerViewController;

@protocol UPCScannerInfoDelegate <NSObject>
- (void) fromViewController:(UPCScannerViewController *)controller withBarCode:(NSString *) barCode;
@end

@interface UPCScannerViewController : UIViewController<UIAlertViewDelegate>

@property (nonatomic, weak) id <UPCScannerInfoDelegate> delegate;


- (IBAction)cancelAction:(id)sender;

@end
