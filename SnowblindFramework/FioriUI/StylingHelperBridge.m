//
//  StylingHelperBridge.m
//  SAPMDCFramework
//
//  Created by Kannar, Janos on 23/03/17.
//  Copyright © 2017 SAP. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SAPMDC/SAPMDC-Swift.h>

#import "StylingHelperBridge.h"

@implementation StylingHelperBridge

+(void) applySDKTheme:(NSString *)file {
    [StylingHelper applySDKThemeWithFile:file];
}

@end
