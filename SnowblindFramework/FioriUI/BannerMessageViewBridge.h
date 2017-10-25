//
//  BannerMessageViewBridge.h
//  SAPMDCFramework
//
//  Copyright © 2017 SAP. All rights reserved.
//

#ifndef BannerMessageViewBridge_h
#define BannerMessageViewBridge_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface BannerMessageViewBridge : NSObject

/**
 Creates a new BannerMessageView, configures it with the given parameters and displays it
 */
-(void)displayBannerMessage:(NSDictionary*)params;

@end

#endif
