//
//  BridgeCommon.h
//  SAPMDCFramework
//
//  Created by Erickson, Ronnie on 9/28/16.
//  Copyright © 2016 SAP. All rights reserved.
//

#ifndef BridgeCommon_h
#define BridgeCommon_h

/**
 * Block that bridge modules use to resolve the JS promise waiting for a result.
 * Nil results are supported and are converted to JS's undefined value.
 */
typedef void (^SnowblindPromiseResolveBlock)(id result);

/**
 * Block that bridge modules use to reject the JS promise waiting for a result.
 * The error may be nil but it is preferable to pass an NSError object for more
 * precise error messages.
 */
typedef void (^SnowblindPromiseRejectBlock)(NSString *code, NSString *message, NSError *error);

#endif /* BridgeCommon_h */
