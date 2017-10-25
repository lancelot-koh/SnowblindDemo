//
//  ActivityIndicatorViewBridge.m
//  SAPMDCFramework
//
//  Copyright © 2017 SAP. All rights reserved.
//

#import "ActivityIndicatorViewBridge.h"
#import <SAPMDC/SAPMDC-Swift.h>

@implementation ActivityIndicatorViewBridge

-(void)dismiss {

  [ActivityIndicatorViewSwift dismiss];
}

-(void)show:(NSDictionary*)params {

  [ActivityIndicatorViewSwift showWithParams:params];
}
@end
