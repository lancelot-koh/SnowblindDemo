//
//  BannerMessageViewBridge.m
//  SAPMDCFramework
//
//  Copyright © 2017 SAP. All rights reserved.
//

#import "BannerMessageViewBridge.h"
#import <SAPMDC/SAPMDC-Swift.h>

@implementation BannerMessageViewBridge

-(void)displayBannerMessage:(NSDictionary*)params {
  [BannerMessageView displayBannerMsgWithParams:params];
}

@end
