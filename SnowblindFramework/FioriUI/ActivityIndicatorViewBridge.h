//
//  ActivityIndicatorViewBridge.h
//  SAPMDCFramework
//
//  Copyright © 2017 SAP. All rights reserved.
//

#ifndef ActivityIndicatorBridge_h
#define ActivityIndicatorBridge_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ActivityIndicatorViewBridge : NSObject

/**
 Dismisses a SAPFiori.ModalProcessingIndicatorView
 */
-(void)dismiss;

/**
 Creates a new SAPFiori.ModalProcessingIndicatorView, configures it with the given parameters and displays it :(NSDictionary*)params;
 */
-(void)show: (NSDictionary*)params;

@end

#endif
