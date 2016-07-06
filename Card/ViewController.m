//
//  ViewController.m
//  Card
//
//  Created by Saran Pinpan on 7/5/2559 BE.
//  Copyright © 2559 Saran Pinpan. All rights reserved.
//

#import "ViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "CardViewController.h"
#import <AFNetworking/AFNetworking.h>

@interface ViewController () 

@property (strong, nonatomic) IBOutlet UIView *loginView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activity;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGFloat borderWidth = 2.0f;
    
//    self.frame = CGRectInset(self.frame, -borderWidth, -borderWidth);
//    self.layer.borderColor = [UIColor yellowColor].CGColor;
//    self.layer.borderWidth = borderWidth;
    
    self.loginView.frame = CGRectInset(self.loginView.frame, -borderWidth, -borderWidth);
    self.loginView.layer.borderColor = [[UIColor colorWithRed:153.0f/255.0f green:153.0f/255.0f blue:153.0f/255.0f alpha:1.0] CGColor];
    self.loginView.layer.borderWidth = 0.5;
    self.loginView.layer.cornerRadius = 5;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(callCard) name:@"test" object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self dismissIndicator];
}

- (void)dismissIndicator {
    [self.loginBtn setTitle:@"LOGIN" forState:UIControlStateNormal];
    [self.activity stopAnimating];
}

- (void)callCard {
    CardViewController *cardVC = [[CardViewController alloc] initWithNibName:@"CardViewController" bundle:nil];
    
    UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:cardVC];
    
    [self presentViewController:navVC animated:YES completion:nil];
}

- (IBAction)loginBtnPressed:(id)sender {
    if ((self.emailField.text.length > 0) && (self.passwordField.text.length > 0)) {
        [self.loginBtn setTitle:@"" forState:UIControlStateNormal];
        [self.activity startAnimating];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"notify" object:self];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [_emailField resignFirstResponder];
    [_passwordField resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.emailField) {
        [self.passwordField becomeFirstResponder];
    }
    if (textField == self.passwordField) {
        [self.passwordField resignFirstResponder];
        [self loginBtnPressed:nil];
    }
    return YES;
}

@end
