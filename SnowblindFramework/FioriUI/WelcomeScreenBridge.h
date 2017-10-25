//
//  WelcomeScreenBridge.h
//  SAPMDCFramework
//
//  Created by Thyagarajan, Ramesh on 2/18/17.
//  Copyright © 2017 SAP. All rights reserved.
//

#ifndef WelcomeScreenBridge_h
#define WelcomeScreenBridge_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "WelcomeScreenDelegate.h"

@interface WelcomeScreenBridge : NSObject

/**
 Creates a new WelcomeScreenBridge

 @return WelcomeScreenBridge UIViewController
 */

-(UIViewController*) create:(NSDictionary *)params callback: (WelcomeScreenDelegate*) callback;

/**
 Updates welcome screen activate button state
 
 @param params UITableViewCell and Property values to be populated
 */
-(void) update: (NSDictionary*)params;

@end

#endif /* WelcomeScreenBridge_h */
