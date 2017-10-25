//
//  OAuthRequestorBridge.h
//  SAPMDCFramework
//
//  Created by Wonderley, Lucas on 3/22/17.
//  Copyright © 2017 SAP. All rights reserved.
//

#ifndef OauthRequestorBridge_h
#define OauthRequestorBridge_h

#import <Foundation/Foundation.h>
#import "BridgeCommon.h"

@interface OAuthRequestorBridge: NSObject

-(void) initialize: (NSDictionary*) params;

-(void) updateConnectionParams: (NSDictionary*) params;

-(void) sendRequest: (NSDictionary *) params
            resolve: (SnowblindPromiseResolveBlock) resolve
             reject: (SnowblindPromiseRejectBlock) reject;

@end

#endif /* OauthRequestorBridge_h */

