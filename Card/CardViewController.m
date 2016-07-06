//
//  CardViewController.m
//  Card
//
//  Created by Saran Pinpan on 7/5/2559 BE.
//  Copyright © 2559 Saran Pinpan. All rights reserved.
//

#import "CardViewController.h"
#import "CardCell.h"
#import "SuccessViewController.h"
#import "WebServiceHelper.h"
#import <AFNetworking/AFNetworking.h>

static NSString *const cardIdentifier = @"cardIdentifier";
static NSString *const defaultPIN = @"123456";

@interface CardViewController () {
    NSString *date;
    NSString *amount;
    NSString *cardID;
    int remainingPinEntries;
    
    SuccessViewController *successVC;
}

@property (strong, nonatomic) IBOutlet UITableView *cardTableView;
@property (strong, nonatomic) THPinViewController *pinViewController;

@end

@implementation CardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    UINavigationBar *bar = [self.navigationController navigationBar];
    bar.topItem.title = @"MY CARD";
    
    UIBarButtonItem *logout = [[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStylePlain target:self action:@selector(logoutPressed)];
    self.navigationItem.rightBarButtonItem = logout;
    
    [self initTableView];
    
    UIView *blank = [[UIView alloc] initWithFrame:CGRectZero];
    self.cardTableView.tableFooterView = blank;
    
    [self.cardTableView setShowsVerticalScrollIndicator:NO];
    
}

- (void)logoutPressed {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)initTableView {
    UINib *cardCell = [UINib nibWithNibName:@"CardCell" bundle:nil];
    [self.cardTableView registerNib:cardCell forCellReuseIdentifier:cardIdentifier];
    
    self.cardTableView.rowHeight = UITableViewAutomaticDimension;
    self.cardTableView.estimatedRowHeight = 0.67 * self.cardTableView.frame.size.width;
}

- (void)updateCardValueWithAmount:(NSString *)_amount date:(NSString *)_date cardID:(NSString *)_cardID {
    if (!_amount ||! _date || !_cardID) {
        return;
    }
    date = _date;
    amount = _amount;
    cardID = _cardID;
    [self.cardTableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CardCell *cell = [tableView dequeueReusableCellWithIdentifier:cardIdentifier];
    if (!cell) {
        cell = [[CardCell alloc] init];
    }
    
    if (indexPath.row == 0) {
        cell.amount.text = amount;
        cell.date.text = date;
        cell.cardID.text = cardID;
        cell.cardImage.image = [UIImage imageNamed:@"Card1"];
        
    }
    
    if (indexPath.row == 1) {
        cell.amount.text = @"฿800.00";
        cell.date.text = @"05/17";
        cell.cardID.text = @"4234 53xx xxxx 5678";
        cell.cardImage.image = [UIImage imageNamed:@"Card2"];
    }
    
    if (indexPath.row == 2) {
        cell.amount.text = @"฿11,800.00";
        cell.date.text = @"02/18";
        cell.cardID.text = @"7436 48xx xxxx 2234";
        cell.cardImage.image = [UIImage imageNamed:@"Card3"];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    long width = tableView.frame.size.width;
    long height = 0.67 * width;
    
    return height;
    
}

- (NSUInteger)pinLengthForPinViewController:(THPinViewController *)pinViewController {
    return 6;
}

- (void)showPinConfirmView {
    remainingPinEntries = 3;
    
    self.pinViewController = [[THPinViewController alloc] initWithDelegate:self];
    self.pinViewController.promptTitle = @"Enter PIN";
    self.pinViewController.promptColor = [UIColor darkTextColor];
    self.pinViewController.view.tintColor = [UIColor darkTextColor];
    self.pinViewController.hideLetters = YES;
    
    // for a solid color background, use this:
    self.pinViewController.backgroundColor = [UIColor whiteColor];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self.navigationController pushViewController:self.pinViewController animated:YES];
}

- (BOOL)pinViewController:(THPinViewController *)pinViewController isPinValid:(NSString *)pin {
    if ([pin isEqualToString:defaultPIN]) {
        [self showSuccessView];
        
        WebServiceHelper *helper = [WebServiceHelper sharedService];
        
        NSDictionary *parameterDic = [[NSDictionary alloc] initWithObjectsAndKeys:helper.token, pToken, helper.login, pMobilenumber, helper.amount, pAmount, @"true", pIsConfirm, helper.transactionID, pTransID, nil];
        
        [helper sendCompleteTransactionWithParams:parameterDic response:^(NSData *data) {
            NSDictionary *userInfo = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            NSLog(@"%@", userInfo);
            
            if ([userInfo objectForKey:pAmount]) {
                NSString *amounts = [NSString stringWithFormat:@"฿%.2f", [[userInfo objectForKey:pAmount] doubleValue]];
                NSMutableString *amountString = [[NSMutableString alloc] initWithString:amounts];
                if ([amountString length] > 6) {
                    [amountString insertString:@"," atIndex:[amountString length]-6];
                } if ([amountString length] > 10) {
                    [amountString insertString:@"," atIndex:[amountString length]-10];
                } if ([amountString length] > 14) {
                    [amountString insertString:@"," atIndex:[amountString length]-14];
                }
                
                [self updateCardValueWithAmount:amountString date:[userInfo objectForKey:pExpireDate] cardID:[userInfo objectForKey:@"card_no"]];
            }
        }];
    } else {
        remainingPinEntries--;
        if (remainingPinEntries == 0) {
            [self.navigationController popToRootViewControllerAnimated:YES];
            WebServiceHelper *helper = [WebServiceHelper sharedService];
            
            NSDictionary *parameterDic = [[NSDictionary alloc] initWithObjectsAndKeys:helper.token, pToken, helper.login, pMobilenumber, helper.amount, pAmount, @"false", pIsConfirm, helper.transactionID, pTransID, nil];
            
            [helper sendCompleteTransactionWithParams:parameterDic response:^(NSData *data) {}];
        }
    }
    return NO;
}

- (BOOL)userCanRetryInPinViewController:(THPinViewController *)pinViewController {
    return YES;
}

- (void)showSuccessView {
    successVC = [[SuccessViewController alloc] initWithNibName:@"SuccessViewController" bundle:nil];
    [self.navigationController pushViewController:successVC animated:YES];
}

@end
