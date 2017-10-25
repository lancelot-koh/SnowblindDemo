//
//  PasscodeInputScreenBridge.m
//  SAPMDCFramework
//
//  Created by Thyagarajan, Ramesh on 3/18/17.
//  Copyright © 2017 SAP. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PasscodeInputScreenBridge.h"
#import <SAPMDC/SAPMDC-Swift.h>

@implementation PasscodeInputScreenBridge

- (UIViewController*) create:(NSDictionary *)params callback: (PasscodeInputScreenDelegate *) callback {
    NSString *action = params[@"Action"];
    PasscodeInputScreenDelegate* myCallback = callback;
    if(!myCallback) {
        myCallback = [[PasscodeInputScreenDelegate alloc]init];
    }

    PasscodeViewController* controller = [[PasscodeViewController alloc] init];
//    [controller initialize: params callback: myCallback];
    if ([action isEqualToString:@"Change"]) {
      [controller showPasscodeChangeScreen:params callback: myCallback];
    } else {
      [controller showInputScreen:params callback: myCallback];
    }
    return controller;
}

@end
