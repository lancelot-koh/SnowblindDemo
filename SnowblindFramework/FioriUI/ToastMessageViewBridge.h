//
//  ToastMessageViewBridge.h
//  SAPMDCFramework
//
//  Copyright © 2017 SAP. All rights reserved.
//

#ifndef ToastMessageViewBridge_h
#define ToastMessageViewBridge_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ToastMessageViewBridge : NSObject

/**
 Creates a new toastMessageView, configures it with the given parameters and displays it
 */
-(void)displayToastMessage:(NSDictionary*)params;

@end

#endif
