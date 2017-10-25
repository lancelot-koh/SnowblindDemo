//
//  ObjectCellBridge.m
//  SAPMDCFramework
//
//  Created by Mehta, Kunal on 10/19/16.
//  Copyright © 2016 SAP. All rights reserved.
//

#import "ObjectCellBridge.h"
#import <SAPMDC/SAPMDC-Swift.h>

@implementation ObjectCellBridge

- (UITableViewCell*) create {
  printf("Object cell create");
  return [ObjectCellSwift create];
}

-(void)populate:(NSDictionary *)params {
  [ObjectCellSwift populateWithParams:params];
}

@end
