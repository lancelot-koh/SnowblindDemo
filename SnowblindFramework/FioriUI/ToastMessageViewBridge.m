//
//  ToastMessageViewBridge.m
//  SAPMDCFramework
//
//  Copyright © 2017 SAP. All rights reserved.
//

#import "ToastMessageViewBridge.h"
#import <SAPMDC/SAPMDC-Swift.h>

@implementation ToastMessageViewBridge

-(void)displayToastMessage:(NSDictionary*)params {

  [ToastMessageViewSwift displayToastMsgWithParams:params];
}
@end
