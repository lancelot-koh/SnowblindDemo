//
//  SectionBridge.m
//  SAPMDCFramework
//
//  Created by Erickson, Ronnie on 2/6/17.
//  Copyright © 2017 SAP. All rights reserved.
//

#import "SectionBridge.h"
#import <SAPMDC/SAPMDC-Swift.h>

@implementation SectionBridge {
  CommonSection* section;
}

-(NSObject*) create:(NSDictionary *)params callback: (SectionDelegate *) callback {
  SectionDelegate *myCallback= callback;
  if (!myCallback) {
    // default delegate used just for logging the data (DEBUG)
    myCallback = [[SectionDelegate alloc] init];
  }

  section = [SectionFactory.sharedInstance createSectionWithParams: params callback: myCallback];
  return section;
}

-(void) setIndicatorState:(NSDictionary *)params {
   // this method only called when the section is an ObjectTableSection
   [(ObjectTableSection *)section setIndicatorStateWithParams: params];
}

-(void) redraw:(NSDictionary *)data {
  [section redrawWithData:data];
}

-(void) reloadData:(NSNumber*) itemCount {
  // convert to NSInteger
  [section reloadDataWithItemCount: [itemCount integerValue]];
}

-(void) reloadRow:(NSNumber*) index {
  // convert to NSInteger
  [section reloadRowWithIndex: [index integerValue]];
}

@end
