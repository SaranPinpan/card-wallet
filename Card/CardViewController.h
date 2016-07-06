//
//  CardViewController.h
//  Card
//
//  Created by Saran Pinpan on 7/5/2559 BE.
//  Copyright © 2559 Saran Pinpan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <THPinViewController/THPinViewController.h>

@interface CardViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, THPinViewControllerDelegate>

- (void)updateCardValueWithAmount:(NSString *)amount date:(NSString *)date cardID:(NSString *)cardID;

- (void)showPinConfirmView;

@end
