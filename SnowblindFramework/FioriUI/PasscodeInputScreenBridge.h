//
//  PasscodeInputScreenBridge.h
//  SAPMDCFramework
//
//  Created by Thyagarajan, Ramesh on 3/18/17.
//  Copyright © 2017 SAP. All rights reserved.
//

#ifndef PasscodeInputScreenBridge_h
#define PasscodeInputScreenBridge_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "PasscodeInputScreenDelegate.h"

@interface PasscodeInputScreenBridge : NSObject

/**
 Creates a new PasscodeInputScreenBridge

 @return PasscodeInputScreenBridge UIViewController
  */
- (UIViewController*) create:(NSDictionary *)params callback: (PasscodeInputScreenDelegate*) callback;

@end

#endif /* PasscodeInputScreenBridge_h */
