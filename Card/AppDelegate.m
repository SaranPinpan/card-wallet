//
//  AppDelegate.m
//  Card
//
//  Created by Saran Pinpan on 7/5/2559 BE.
//  Copyright © 2559 Saran Pinpan. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "CardViewController.h"
#import <AFNetworking/AFNetworking.h>
#import "WebServiceHelper.h"

@interface AppDelegate () {
    ViewController *vc;
    CardViewController *cardVC;
    UINavigationController *navVC;
}

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    vc = [[ViewController alloc] initWithNibName:@"ViewController" bundle:nil];
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.rootViewController = vc;
    [self.window makeKeyAndVisible];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(registerNotification) name:@"notify" object:nil];
    
    //    [self registerForPushNotification:application];
    
    return YES;
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    NSLog(@"Receive Message");
    
    if (userInfo) {
        
        NSDictionary *data = [userInfo objectForKey:pAps];
        NSString *cardData = [data objectForKey:pAlert];
        NSString *transationID = [userInfo objectForKey:pTransID];
        NSString *amountLong = [userInfo objectForKey:pAmount];
        
        [WebServiceHelper sharedService].transactionID = transationID;
        [WebServiceHelper sharedService].amount = amountLong;
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:cardData preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"Confirm" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [cardVC showPinConfirmView];
        }];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            WebServiceHelper *helper = [WebServiceHelper sharedService];
            
            NSDictionary *parameterDic = [[NSDictionary alloc] initWithObjectsAndKeys:helper.token, pToken, helper.login, pMobilenumber, helper.amount, pAmount, [NSNumber numberWithBool:NO], pIsConfirm, helper.transactionID, pTransID, nil];
            
            [helper sendCompleteTransactionWithParams:parameterDic response:^(NSData *data) {}];
        }];
        
        [alert addAction:confirm];
        [alert addAction:cancel];
        
        [cardVC presentViewController:alert animated:YES completion:nil];
    }
}

- (void)registerForPushNotification:(UIApplication*)application {
    UIUserNotificationSettings *userNoti = [UIUserNotificationSettings settingsForTypes: UIUserNotificationTypeSound | UIUserNotificationTypeAlert categories:nil];
    [application registerUserNotificationSettings:userNoti];
}

- (void)registerNotification {
    [self registerForPushNotification:[UIApplication sharedApplication]];
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    if (notificationSettings.types != UIUserNotificationTypeNone) {
        [application registerForRemoteNotifications];
    }
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSString * deviceTokenString = [[[[deviceToken description]
                                      stringByReplacingOccurrencesOfString: @"<" withString: @""]
                                     stringByReplacingOccurrencesOfString: @">" withString: @""]
                                    stringByReplacingOccurrencesOfString: @" " withString: @""];
    
    NSLog(@"The generated device token string is : %@",deviceTokenString);
    
    [WebServiceHelper sharedService].login = vc.emailField.text;
    [WebServiceHelper sharedService].token = deviceTokenString;
    
    NSDictionary *parameterDic = [[NSDictionary alloc] initWithObjectsAndKeys:[WebServiceHelper sharedService].login, pMobilenumber, [WebServiceHelper sharedService].token, pToken, nil];
    
    [[WebServiceHelper sharedService] loginWithParams:parameterDic response:^(NSData *data) {
        if (data) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            NSLog(@"Data : %@", dict);
            BOOL success = [[dict objectForKey:@"success"] boolValue];
            
            if (!success) {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:[dict objectForKey:@"error"] preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *okBtn = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [alert dismissViewControllerAnimated:YES completion:nil];
                }];
                
                [alert addAction:okBtn];
                [vc presentViewController:alert animated:YES completion:nil];
            } else {
                NSArray *cardDatas = [dict objectForKey:pCards];
                
                if (cardDatas.count > 0) {
                    NSDictionary *cardData = [cardDatas objectAtIndex:0];
                    
//                    NSString *cardNo = [cardData objectForKey:pCardNo];
                    NSString *card = [cardData objectForKey:pCardNo];
                    NSMutableString *cardNo = [[NSMutableString alloc] initWithString:card];
                    [cardNo insertString:@" " atIndex:[card length]-4];
                    [cardNo insertString:@" " atIndex:[card length]-8];
                    [cardNo insertString:@" " atIndex:[card length]-12];
                    
                    NSString *expireDate = [cardData objectForKey:pExpireDate];
                    
                    NSString *amountLong = [NSString stringWithFormat:@"%.2f",[[cardData objectForKey:pAmount] doubleValue]];
//                    NSString *amount = [@"฿" stringByAppendingString:amountLong];
                    NSMutableString *amount = [[NSMutableString alloc] initWithString:amountLong];
                    if ([amount length] > 6) {
                        [amount insertString:@"," atIndex:[amount length]-6];
                    } if ([amount length] > 10) {
                        [amount insertString:@"," atIndex:[amount length]-10];
                    } if ([amount length] > 14) {
                        [amount insertString:@"," atIndex:[amount length]-14];
                    }
                    
                    cardVC = [[CardViewController alloc] initWithNibName:@"CardViewController" bundle:nil];
                    
                    navVC = [[UINavigationController alloc] initWithRootViewController:cardVC];
                    
                    [vc presentViewController:navVC animated:YES completion:nil];
                    [cardVC updateCardValueWithAmount:amount date:expireDate cardID:cardNo];
                }
            }
        }
    }];
    
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
