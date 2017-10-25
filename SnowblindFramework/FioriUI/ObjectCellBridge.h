//
//  ObjectCellBridge.h
//  SAPMDCFramework
//
//  Created by Mehta, Kunal on 10/19/16.
//  Copyright © 2016 SAP. All rights reserved.
//
#ifndef ObjectCellBridge_h
#define ObjectCellBridge_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ObjectCellBridge : NSObject

/**
 Creates a new object cell

 @return Object cell as UITableViewCell
 */
-(UITableViewCell*) create;

/**
 Populates cell properties

 @param params UITableViewCell and Property values to be populated
 */
-(void) populate: (NSDictionary*)params;

@end

#endif
