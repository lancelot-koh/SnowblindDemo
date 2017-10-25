//
//  SectionedTableBridge.m
//  SAPMDCFramework
//
//  Created by Erickson, Ronnie on 2/6/17.
//  Copyright © 2017 SAP. All rights reserved.
//

#import "SectionedTableBridge.h"
#import <SAPMDC/SAPMDC-Swift.h>

@implementation SectionedTableBridge

- (UIViewController*) create:(NSArray<CommonSection *>*) sections {
  SectionedTableViewController *controller = [[SectionedTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
  [controller initialize: sections];
  return controller;
}

@end
