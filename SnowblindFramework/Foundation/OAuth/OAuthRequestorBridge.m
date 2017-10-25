//
//  OAuthRequestorBridge.m
//  SAPMDCFramework
//
//  Created by Wonderley, Lucas on 3/22/17.
//  Copyright © 2017 SAP. All rights reserved.
//

#import "OAuthRequestorBridge.h"
#import <Foundation/Foundation.h>
#import <SAPMDC/SAPMDC-Swift.h>


@implementation OAuthRequestorBridge

-(void) initialize: (NSDictionary*) params {
  [OAuthRequestor.sharedInstance initializeWithParams:params];
}

-(void) updateConnectionParams: (NSDictionary*) params {
  [OAuthRequestor.sharedInstance updateWithParams:params];
}

-(void) sendRequest: (NSDictionary*) params
            resolve: (SnowblindPromiseResolveBlock) resolve
             reject: (SnowblindPromiseRejectBlock) reject {
  [OAuthRequestor.sharedInstance sendRequestWithParams:params resolve:resolve reject:reject];
}

@end
