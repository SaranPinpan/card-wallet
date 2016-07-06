//
//  WebServiceHelper.h
//  Card
//
//  Created by Chonnawee on 7/6/2559 BE.
//  Copyright © 2559 Digio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"

@interface WebServiceHelper : NSObject

+ (WebServiceHelper *)sharedService;

- (void)loginWithParams:(NSDictionary *)paramsDict response:(void (^)(NSData *))responseData;

- (void)sendCompleteTransactionWithParams:(NSDictionary *)paramsDict response:(void (^)(NSData *))responseData;

@property (nonatomic, copy) NSString *login;
@property (nonatomic, copy) NSString *token;
@property (nonatomic, copy) NSString *transactionID;
@property (nonatomic, copy) NSString *amount;

@end
