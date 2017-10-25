//
//  SectionBridge.h
//  SAPMDCFramework
//
//  Created by Erickson, Ronnie on 2/6/17.
//  Copyright © 2017 SAP. All rights reserved.
//

#ifndef SectionBridge_h
#define SectionBridge_h

#import <Foundation/Foundation.h>
#import "SectionDelegate.h"

@class CommonSection;

@interface SectionBridge : NSObject

/**
 * Creates a new Section and returns the SectionBridge
 *
 * @return SectionBridge
 */
-(NSObject*) create:(NSDictionary *)params callback: (SectionDelegate *) callback;

-(void) setIndicatorState:(NSDictionary*)params;

/**
 * Called to redraw the section
 */
-(void) redraw:(NSDictionary *)data;

/**
 * Called to reload the data for the section
 */
-(void) reloadData:(NSNumber*) itemCount;

/**
 * Called to redraw a row
 */
-(void) reloadRow:(NSNumber*) index;

@end

#endif /* SectionBridge_h */
