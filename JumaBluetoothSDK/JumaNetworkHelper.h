//
//  JumaNetworkHelper.h
//  JumaBluetoothSDK
//
//  Created by 汪安军 on 15/9/14.
//  Copyright (c) 2015年 JUMA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JumaNetworkHelper : NSObject

- (void)registerUserWithInfo:(NSDictionary *)registrationInfo;
- (void)userSignInWithInfo:(NSDictionary *)loginInfo;
- (void)userSignOut;

- (void)registerDeviceWithInfo:(NSDictionary *)deviceInfo;
- (void)updateDeviceWithInfo:(NSDictionary *)deviceInfo;
- (void)deleteDeviceWithID:(NSString *)deviceID;
- (void)getDeviceInfoWithID:(NSString *)deviceID;
- (void)getAllDeviceInfoWithID:(NSArray *)deviceIDs;
- (void)bindDeviceWithID:(NSString *)deviceID;
- (void)unbindDeviceWithID:(NSString *)deviceID;

@end
