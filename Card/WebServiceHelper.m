//
//  WebServiceHelper.m
//  Card
//
//  Created by Chonnawee on 7/6/2559 BE.
//  Copyright © 2559 Digio. All rights reserved.
//

#import "WebServiceHelper.h"
#import "Config.h"
#import <AFNetworking/AFNetworking.h>

@implementation WebServiceHelper

+ (WebServiceHelper *)sharedService {
    static WebServiceHelper *sharedService;
    @synchronized (self) {
        sharedService = [[self alloc] init];
    }
    return sharedService;
}

- (void)loginWithParams:(NSDictionary *)paramsDict response:(void (^)(NSData *))responseData {
    NSString *urlString = loginURL;
    
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"POST" URLString:urlString parameters:paramsDict error:nil];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        responseData(data);
    }];
    [dataTask resume];
}

- (void)sendCompleteTransactionWithParams:(NSDictionary *)paramsDict response:(void (^)(NSData *))responseData {
    NSString *urlString = sendTransactionURL;
    
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"POST" URLString:urlString parameters:paramsDict error:nil];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        responseData(data);
    }];
    [dataTask resume];
}


- (void)setLogin:(NSString *)login {
    [[NSUserDefaults standardUserDefaults] setObject:login forKey:loginKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)login {
    return [[NSUserDefaults standardUserDefaults] objectForKey:loginKey];
}

- (void)setToken:(NSString *)token {
    [[NSUserDefaults standardUserDefaults] setObject:token forKey:tokenKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)token {
    return [[NSUserDefaults standardUserDefaults] objectForKey:tokenKey];
}

- (void)setTransactionID:(NSString *)transactionID {
    [[NSUserDefaults standardUserDefaults] setObject:transactionID forKey:transIDKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)transactionID {
    return [[NSUserDefaults standardUserDefaults] objectForKey:transIDKey];
}

- (void)setAmount:(NSString *)amount {
    [[NSUserDefaults standardUserDefaults] setObject:amount forKey:amountKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)amount {
    return [[NSUserDefaults standardUserDefaults] objectForKey:amountKey];
}

@end
