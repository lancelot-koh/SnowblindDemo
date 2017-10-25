//
//  WelcomeScreenBridge.m
//  SAPMDCFramework
//
//  Created by Thyagarajan, Ramesh on 2/18/17.
//  Copyright © 2017 SAP. All rights reserved.
//

#import "WelcomeScreenBridge.h"
#import <SAPMDC/SAPMDC-Swift.h>

@implementation WelcomeScreenBridge

- (UIViewController*) create:(NSDictionary *)params callback: (WelcomeScreenDelegate *) callback {
  WelcomeScreenDelegate* myCallback = callback;
  if(!myCallback) {
    myCallback = [[WelcomeScreenDelegate alloc]init];
  }
  WelcomeScreenViewController* controller = [[WelcomeScreenViewController alloc] init];
  [controller initialize: params callback: myCallback];
  return controller;
}

- (void) update:(NSDictionary *)params {
  [WelcomeScreenViewController update: params];
}

@end
