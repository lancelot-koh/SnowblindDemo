//
//  OpenDocumentBridge.m
//  SAPMDC
//
//  Created by Koncsek, Endre Daniel on 7/26/17.
//  Copyright © 2017 SAP. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "OpenDocumentBridge.h"
#import <SAPMDC/SAPMDC-Swift.h>

@implementation OpenDocumentBridge

-(void)openDocument:(NSString *)path resolve: (SnowblindPromiseResolveBlock)resolve reject: (SnowblindPromiseRejectBlock)reject {
  [OpenDocumentSwift openWithPath:path resolve: resolve reject: reject];
}

@end
