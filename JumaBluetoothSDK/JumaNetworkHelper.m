//
//  JumaNetworkHelper.m
//  JumaBluetoothSDK
//
//  Created by 汪安军 on 15/9/14.
//  Copyright (c) 2015年 JUMA. All rights reserved.
//

#import "JumaNetworkHelper.h"
#import "JumaConfig.h"

static NSString * const BaseURL = @"http://117.121.38.2:81";
static NSString * const userIDAndpassword = @"id=Wang AnJun&pass=maishunan1992";

typedef NS_ENUM(NSUInteger, NSURLRequestHTTPMethod) {
    NSURLRequestHTTPMethodGET,
    NSURLRequestHTTPMethodPOST,
    NSURLRequestHTTPMethodPUT,
    NSURLRequestHTTPMethodDELETE
};

@interface JumaNetworkHelper ()

@end

@implementation JumaNetworkHelper

//    NSString *deviceID = @"11c5427986ce434fbbd95820c5b875e1";

static NSString *x_juma_token = @"50df519cbfa2a8b237e3b8511c9cdc07";

+ (NSDictionary *)tokenDict {
    return @{ @"x-juma-token" : x_juma_token };
}

#pragma mark - user

// ID:(NSString *)userID nickName:(NSString *)nikeName password:(NSString *)password
- (void)registerUserWithInfo:(NSDictionary *)registrationInfo {
    NSString *urlString = [BaseURL stringByAppendingString:@"/api/v1/account/register"];
    NSURLRequest *request = [JumaNetworkHelper requestWithURL:urlString
                                                   parameters:registrationInfo
                                                requestHeader:nil
                                                   httpMethod:NSURLRequestHTTPMethodPOST];
    
    [JumaNetworkHelper sendAsyncRequest:request queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, id responseObject, BOOL errorOccur) {
        
        JMLog(@"%s, %@", __func__, responseObject);
        x_juma_token = [[responseObject objectForKey:@"session"] objectForKey:@"token"];
    }];
}

- (void)userSignInWithInfo:(NSDictionary *)loginInfo {
    NSString *urlString = [BaseURL stringByAppendingString:@"/api/v1/account/sign_in"];
    NSURLRequest *request = [JumaNetworkHelper requestWithURL:urlString
                                                   parameters:loginInfo
                                                requestHeader:nil
                                                   httpMethod:NSURLRequestHTTPMethodPOST];
    [JumaNetworkHelper sendAsyncRequest:request queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, id responseObject, BOOL errorOccur) {
        
        JMLog(@"%s, %@", __func__, responseObject);
        x_juma_token = [[responseObject objectForKey:@"session"] objectForKey:@"token"];
    }];
}

- (void)userSignOut {
    NSString *urlString = [BaseURL stringByAppendingString:@"/api/v1/account/sign_out"];
    NSURLRequest *request = [JumaNetworkHelper requestWithURL:urlString
                                                   parameters:nil
                                                requestHeader:[JumaNetworkHelper tokenDict]
                                                   httpMethod:NSURLRequestHTTPMethodGET];
    [JumaNetworkHelper sendAsyncRequest:request queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, id responseObject, BOOL errorOccur) {
        JMLog(@"%s, %@", __func__, responseObject);
    }];
}

- (void)registerDeviceWithInfo:(NSDictionary *)deviceInfo {
    
}

- (void)updateDeviceWithInfo:(NSDictionary *)deviceInfo {
    
}

- (void)deleteDeviceWithID:(NSString *)deviceID {
    
}

- (void)getDeviceInfoWithID:(NSString *)deviceID {
    
    if (x_juma_token) {
        NSString *urlString = [BaseURL stringByAppendingFormat:@"/api/v1/device/one/%@", deviceID];
        NSURLRequest *request = [JumaNetworkHelper requestWithURL:urlString
                                                       parameters:nil
                                                    requestHeader:[JumaNetworkHelper tokenDict]
                                                       httpMethod:NSURLRequestHTTPMethodGET];
        [JumaNetworkHelper sendAsyncRequest:request queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, id responseObject, BOOL errorOccur) {
            JMLog(@"%s, %@", __func__, responseObject);
        }];
    }
    else {
        [self userSignInWithInfo:@{ @"id" : @"Wang AnJun", @"pass" : @"maishunan1992" }];
    }
}

- (void)getAllDeviceInfoWithID:(NSArray *)deviceIDs {
    
}

- (void)bindDeviceWithID:(NSString *)deviceID {
    
}

- (void)unbindDeviceWithID:(NSString *)deviceID {
    
}


- (NSData *)httpBodyWithDictionary:(NSDictionary *)dict {
    NSMutableString *string = @"".mutableCopy;
    [dict enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *obj, BOOL *stop) {
        [string appendFormat:@"&%@=%@", key, obj];
    }];
    [string deleteCharactersInRange:NSMakeRange(0, 1)];
    return [string dataUsingEncoding:NSUTF8StringEncoding];
}

- (void)registerDevice {
    
    // 生成网络请求
    NSString *urlString = [BaseURL stringByAppendingString:@"/api/v1/device/"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                       timeoutInterval:10.0];
    // 请求头
    [request addValue:@"cc51a8bfa7d73e92446cde6cace1bb1c" forHTTPHeaderField:@"x-juma-token"];
    
    // 请求体
    NSDictionary *dict = @{ @"id" : @"11c5427986ce434fbbd95820c5b875e1",
                            @"pid" : @"pid_xxx",
                            @"location" : @"location_xxx",
                            @"order" : @"order_xxx",
                            @"factory" : @"factory_xxx",
                            @"imei" : @"imei_xxx" };
    request.HTTPBody = [self httpBodyWithDictionary:dict];
    request.HTTPMethod = @"POST";
    
    // 返回数据 key = fba0409f9b031a1272457084ce915ddb
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        
        // 不能从服务器获得数据
        if (!data) {
            JMLog(@"登陆.connectionError = %@", connectionError);
            return;
        }
        
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&connectionError];
        JMLog(@"登陆.dict = %@", dict);
        
        // 解析服务器返回的结果时出错
        if (!dict) {
            JMLog(@"登陆.jsonParsing.error = %@", connectionError);
            return;
        }
        
        NSDictionary *session = dict[@"session"];
        NSString *token = session[@"token"];
        
        if (token) {
            JMLog(@"did get token: %@", token);
            [self checkWetherRegistered:token];
        }
        else {
            JMLog(@"登陆.没有返回 token");
        }
    }];
}

- (void)signIn {
    
    // 生成网络请求
    NSString *urlString = [BaseURL stringByAppendingString:@"/api/v1/account/sign_in"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                       timeoutInterval:10.0];
    request.HTTPBody = [@"id=yumingming&pass=968600" dataUsingEncoding:NSUTF8StringEncoding];
    request.HTTPMethod = @"POST";
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        
        // 不能从服务器获得数据
        if (!data) {
            JMLog(@"登陆.connectionError = %@", connectionError);
            return;
        }
        
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&connectionError];
        JMLog(@"登陆.dict = %@", dict);
        
        // 解析服务器返回的结果时出错
        if (!dict) {
            JMLog(@"登陆.jsonParsing.error = %@", connectionError);
            return;
        }
        
        NSDictionary *session = dict[@"session"];
        NSString *token = session[@"token"];
        
        if (token) {
            JMLog(@"did get token: %@", token);
            [self checkWetherRegistered:token];
        }
        else {
            JMLog(@"登陆.没有返回 token");
        }
    }];
}

- (void)chectAllDevicesWithToken:(NSString *)token {
    
    // 生成 HTTP 请求
    NSString *urlString = [BaseURL stringByAppendingFormat:@"/api/v1/device/all"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                       timeoutInterval:10.0];
    [request addValue:token forHTTPHeaderField:@"x-juma-token"];
    
    // 发送请求
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        
        
        // 不能从服务器获得数据
        if (!data) {
            JMLog(@"注册检测.connectionError = %@", connectionError);
            return;
        }
        
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&connectionError];
        JMLog(@"dict = %@, string = %@", dict, [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        
        // 解析服务器返回的结果时出错
        if (!dict) {
            JMLog(@"注册检测.jsonParsing.error = %@", connectionError);
            return;
        }
        
        //        NSString *returnedDeviceID = dict[@"device"];
        //
        //        // 返回的设备 ID 和发送的设备 ID 一致
        //        if ([returnedDeviceID isEqualToString:deviceID]) {
        //            JMLog(@"返回的设备 ID 和发送的设备 ID 一致");
        //        }
        //        else {
        //            JMLog(@"注册检测 returnedID = %@, sentID = %@", returnedDeviceID, deviceID);
        //        }
    }];
}

- (void)checkWetherRegistered:(NSString *)token {
    
    // 生成设备 ID
    NSString *deviceID = @"11c5427986ce434fbbd95820c5b875e1";
    
    // 生成 HTTP 请求
    NSString *urlString = [BaseURL stringByAppendingFormat:@"/api/v1/device/one/%@", deviceID];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                       timeoutInterval:10.0];
    [request addValue:token forHTTPHeaderField:@"x-juma-token"];
    
    // 发送请求
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        
        
        // 不能从服务器获得数据
        if (!data) {
            JMLog(@"注册检测.connectionError = %@", connectionError);
            return;
        }
        
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&connectionError];
        JMLog(@"dict = %@, string = %@", dict, [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        
        // 解析服务器返回的结果时出错
        if (!dict) {
            JMLog(@"注册检测.jsonParsing.error = %@", connectionError);
            return;
        }
        
        NSString *returnedDeviceID = dict[@"device"];
        
        // 返回的设备 ID 和发送的设备 ID 一致
        if ([returnedDeviceID isEqualToString:deviceID]) {
            JMLog(@"返回的设备 ID 和发送的设备 ID 一致");
        }
        else {
            JMLog(@"注册检测 returnedID = %@, sentID = %@", returnedDeviceID, deviceID);
        }
    }];
}

+ (NSMutableURLRequest *)requestWithURL:(NSString *)urlString
                             parameters:(NSDictionary *)parameters
                          requestHeader:(NSDictionary *)header
                             httpMethod:(NSURLRequestHTTPMethod)httpMethod {
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    
    // 设置请求头
    [header enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *obj, BOOL *stop) {
        [request addValue:obj forHTTPHeaderField:key];
    }];
    
    // 转换参数格式
    NSMutableString *parameterString = [NSMutableString string];
    [parameters enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *obj, BOOL *stop) {
        [parameterString appendFormat:@"&%@=%@", key, obj];
    }];
    
    if (NSURLRequestHTTPMethodGET == httpMethod) {
        request.HTTPMethod = @"GET";
        
        // query string
        if (parameterString.length) {
            
            if (!request.URL.query) {
                [parameterString replaceCharactersInRange:NSMakeRange(0, 1) withString:@"?"];
            }
            request.URL = [NSURL URLWithString:[urlString stringByAppendingString:parameterString]];
        }
        JMLog(@"%@, %@", request.HTTPMethod, request.URL);
    }
    else if (NSURLRequestHTTPMethodPOST == httpMethod) {
        request.HTTPMethod = @"POST";
        
        // http body
        if ([parameterString length]) {
            [parameterString deleteCharactersInRange:NSMakeRange(0, 1)];
            JMLog(@"%@, %@, body: %@", request.HTTPMethod, request.URL, parameterString);
            request.HTTPBody = [parameterString dataUsingEncoding:NSUTF8StringEncoding];
        }
    }
    else if (NSURLRequestHTTPMethodPUT == httpMethod) {
        request.HTTPMethod = @"PUT";
        
        // http body
        if ([parameterString length]) {
            [parameterString deleteCharactersInRange:NSMakeRange(0, 1)];
            JMLog(@"%@, %@, body: %@", request.HTTPMethod, request.URL, parameterString);
            request.HTTPBody = [parameterString dataUsingEncoding:NSUTF8StringEncoding];
        }
    }
    else if (NSURLRequestHTTPMethodDELETE == httpMethod) {
        request.HTTPMethod = @"DELETE";
        
    }
    
    return request;
}

+ (void)sendAsyncRequest:(NSURLRequest*) request
                   queue:(NSOperationQueue*) queue
       completionHandler:(void (^)(NSURLResponse* response, id responseObject, BOOL errorOccur)) handler {
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        
        if (!connectionError)
        {
            if (data)
            {
                id obj = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&connectionError];
                if (!connectionError)
                {
                    handler(response, obj, NO);
                }
                else
                {
                    NSLog(@"%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                    handler(response, nil, YES);
                }
            }
            else
            {
                handler(response, nil, NO);
            }
        }
        else
        {
            NSLog(@"%@", connectionError);
            handler(response, nil, YES);
        }
    }];
}

@end

///** 登陆服务器获取 token */
//- (void)signIn {
//    /*
//     "Accept-Language" = "zh-Hans;q=1, en;q=0.9";
//     "Content-Type" = "application/x-www-form-urlencoded; charset=utf-8";
//     "User-Agent" = "NSULRSession_Test/1 (iPhone; iOS 8.3; Scale/2.00)";
//     */
//    
//    // 生成网络请求
//    NSString *urlString = [BaseURL stringByAppendingString:@"/api/v1/account/sign_in"];
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]
//                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
//                                                       timeoutInterval:10.0];
//    request.HTTPBody = [userIDAndpassword dataUsingEncoding:NSUTF8StringEncoding];
//    request.HTTPMethod = @"POST";
//    
//    // 申请后台运行时间
//    [self beingBackgroundTask];
//    
//    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
//        
//        // 在连接过程中进行注册检查, state 应该是 connecting
//        if (JumaDeviceStateConnecting != _state) return;
//        
//        // 不能从服务器获得数据
//        if (!data) {
//            JMLog(@"登陆.connectionError = %@", connectionError);
//            return;
//        }
//        
//        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&connectionError];
//        JMLog(@"登陆.dict = %@", dict);
//        
//        // 解析服务器返回的结果时出错
//        if (!dict) {
//            JMLog(@"登陆.jsonParsing.error = %@", connectionError);
//            return;
//        }
//        
//        NSDictionary *session = dict[@"session"];
//        NSString *token = session[@"token"];
//        
//        if (token) {
//            [self didEstablishConnection];
//        }
//        else {
//            JMLog(@"登陆.没有返回 token");
//            NSString *desc = [NSString stringWithFormat:@"Your device is not registered in JUMA."];
//            self.canNotEstablishConnectionError = [NSError jumaSDK_errorWithDescription:desc];
//            [self disconnectFromManager];
//        }
//        
//        [self endBackgroundTask];
//    }];
//}
//
///** 把从 peripheral 获得的设备 ID 提交到服务器上, 检查设备是否注册过, 没有注册过的设备不允许连接 */
//- (void)checkWetherRegistered:(NSData *)data {
//    
//    // 检查类型
//    JumaDataType type = 0;
//    [data getBytes:&type length:sizeof(type)];
//    NSAssert(JumaDataType80 == type, @"注册检查时, peripheral 返回的数据的类型不是 0x80");
//    
//    // 检查数据长度
//    JumaDataLength len = 0;
//    [data getBytes:&len range:NSMakeRange(sizeof(type), sizeof(len))];
//    NSAssert(16 == len, @"注册检查时, peripheral 返回的数据长度不是 16");
//    
//    // 检查设备 ID 的长度
//    NSData *content = [data subdataFromIndex:sizeof(type) + sizeof(len)];
//    NSAssert(content.length == 16, @"注册检查时, peripheral 返回的设备 ID 的长度不是 16");
//    
//    // 生成设备 ID
//    NSString *deviceID = [content.description stringByReplacingOccurrencesOfString:@"<" withString:@""];
//    deviceID = [deviceID stringByReplacingOccurrencesOfString:@">" withString:@""];
//    deviceID = [deviceID stringByReplacingOccurrencesOfString:@" " withString:@""];
//    
//    // 生成 HTTP 请求
//    NSString *urlString = [BaseURL stringByAppendingFormat:@"/api/v1/device/one/%@", deviceID];
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]
//                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
//                                                       timeoutInterval:10.0];
//    [request addValue:@"a72afd46b2302c07f4ece03ba00797d1" forHTTPHeaderField:@"x-juma-token"];
//    
//    // 申请后台运行时间
//    [self beingBackgroundTask];
//    
//    // 发送请求
//    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
//        
//        // 在连接过程中进行注册检查, state 应该是 connecting
//        if (JumaDeviceStateConnecting != _state) return;
//        
//        // 不能从服务器获得数据
//        if (!data) {
//            JMLog(@"注册检测.connectionError = %@", connectionError);
//            return;
//        }
//        
//        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&connectionError];
//        JMLog(@"dict = %@, string = %@", dict, [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
//        
//        // 解析服务器返回的结果时出错
//        if (!dict) {
//            JMLog(@"注册检测.jsonParsing.error = %@", connectionError);
//            return;
//        }
//        
//        NSString *returnedDeviceID = dict[@"device"];
//        
//        // 返回的设备 ID 和发送的设备 ID 一致
//        if ([returnedDeviceID isEqualToString:deviceID]) {
//            [self didEstablishConnection];
//        }
//        else {
//            JMLog(@"注册检测 returnedID = %@, sentID = %@", returnedDeviceID, deviceID);
//            NSString *desc = [NSString stringWithFormat:@"Your device is not registered in JUMA."];
//            self.canNotEstablishConnectionError = [NSError jumaSDK_errorWithDescription:desc];
//            [self disconnectFromManager];
//        }
//        
//        [self endBackgroundTask];
//    }];
//}
