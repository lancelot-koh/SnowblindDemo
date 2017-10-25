//
//  FormCellContainerBridge.h
//  SAPMDCFramework
//  Copyright © 2016 SAP. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "FormCellItemDelegate.h"

@interface FormCellContainerBridge : NSObject

/**
 Creates a new form cell container.
 @param params The NSDictionary* which contains two objects: numberOfSections, numberOfRowsInSection
 @return Object cell as UIViewController
 */
-(UIViewController*) createWithParams:(NSDictionary *)params;

/**
 Populates form cell container with a form cell and registers a delegate for it.
 @param params UIViewController and Property values to be populated
 @param bridge delegate for calling at data change in the cell
 */
-(void)populateController:(UIViewController *)controller withParams:(NSDictionary *)params andBridge: (FormCellItemDelegate *) bridge;

/**
 Update form cell with an array of udpated formCell values.
 @param params The NSArray* which contains NSDictionary that stores formCell property values
 @param row zero based row as in IndexPath
 @param section zero based section as in IndexPath
 */
-(void)updateCell:(UIViewController *)controller withParams:(NSDictionary*) params row: (NSNumber*) row section: (NSNumber*) section;

/**
 Update form cell with an array of udpated formCell values.
 @param params The NSArray* which contains NSDictionary that stores formCell property values
 @param style The NUI style class for the container, it might be nil
 */
-(void)updateCells:(UIViewController *)controller withParams:(NSArray*) params andStyle: (NSString*) style;

@end


