//
//  ODataServiceManagerBridge.m
//  SnowblindClient
//
//  Copyright © 2016 sap. All rights reserved.
//

#import "ODataServiceManagerBridge.h"
#import <SAPMDC/SAPMDC-Swift.h>

@implementation ODataServiceManagerBridge

- (void) download: (NSDictionary*)params resolve: (SnowblindPromiseResolveBlock)resolve reject: (SnowblindPromiseRejectBlock)reject {
  [DataServiceManager.sharedInstance downloadWithParams: params resolve: resolve reject: reject];
}

- (void) initializeOfflineStore: (NSDictionary*)params resolve: (SnowblindPromiseResolveBlock)resolve reject: (SnowblindPromiseRejectBlock)reject {
  ODataServiceProvider * provider = [ODataServiceProvider new];
  [DataServiceManager.sharedInstance initOfflineStoreWithProvider: provider params: params resolve: resolve reject: reject];
}

- (void) closeOfflineStore: (NSDictionary*)params resolve: (SnowblindPromiseResolveBlock)resolve reject: (SnowblindPromiseRejectBlock)reject {
    [DataServiceManager.sharedInstance closeWithParams: params resolve:resolve reject: reject];
}

- (void) clearOfflineStore: (NSDictionary*)params resolve: (SnowblindPromiseResolveBlock)resolve reject: (SnowblindPromiseRejectBlock)reject {
    [DataServiceManager.sharedInstance clearWithParams: params resolve:resolve reject: reject];
}

- (void) upload: (NSDictionary*)params resolve: (SnowblindPromiseResolveBlock)resolve reject: (SnowblindPromiseRejectBlock)reject {
  [DataServiceManager.sharedInstance uploadWithParams: params resolve: resolve reject: reject];
}

- (void) create: (NSDictionary*)params resolve: (SnowblindPromiseResolveBlock)resolve reject: (SnowblindPromiseRejectBlock)reject {
  ODataServiceProvider * provider = [ODataServiceProvider new];
  [DataServiceManager.sharedInstance createWithProvider: provider params: params resolve: resolve reject: reject];
}

- (void) open: (NSDictionary*)params resolve: (SnowblindPromiseResolveBlock)resolve reject: (SnowblindPromiseRejectBlock)reject {
  [DataServiceManager.sharedInstance openWithParams: params resolve:resolve reject: reject];
}

- (void) read: (NSDictionary*)params resolve: (SnowblindPromiseResolveBlock)resolve reject: (SnowblindPromiseRejectBlock)reject {
  [DataServiceManager.sharedInstance readWithParams: params resolve: resolve reject: reject];
  // leave this code commented out for now - it causes a blank page to be rendered until the read completes
  //  dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
  //    [DataServiceManager.sharedInstance readWithParams: params resolve: resolve reject: reject];
  //  });
}

- (void) update: (NSDictionary*)params resolve: (SnowblindPromiseResolveBlock)resolve reject: (SnowblindPromiseRejectBlock)reject {
  [DataServiceManager.sharedInstance updateWithParams: params resolve: resolve reject: reject];
}

- (void) createEntity: (NSDictionary*)params resolve: (SnowblindPromiseResolveBlock)resolve reject: (SnowblindPromiseRejectBlock)reject {
  [DataServiceManager.sharedInstance createEntityWithParams: params resolve: resolve reject: reject];
}

- (void) deleteEntity: (NSDictionary*)params resolve: (SnowblindPromiseResolveBlock)resolve reject: (SnowblindPromiseRejectBlock)reject {
  [DataServiceManager.sharedInstance deleteEntityWithParams: params resolve: resolve reject: reject];
}

- (void) createMedia: (NSDictionary*)params resolve: (SnowblindPromiseResolveBlock)resolve reject: (SnowblindPromiseRejectBlock)reject {
  [DataServiceManager.sharedInstance createMediaWithParams: params resolve: resolve reject: reject];
}

- (void) beginChangeSet: (NSDictionary*)params resolve: (SnowblindPromiseResolveBlock)resolve reject: (SnowblindPromiseRejectBlock)reject {
  [DataServiceManager.sharedInstance beginChangeSetWithParams: params resolve: resolve reject: reject];
}

- (void) cancelChangeSet: (NSDictionary*)params resolve: (SnowblindPromiseResolveBlock)resolve reject: (SnowblindPromiseRejectBlock)reject {
  [DataServiceManager.sharedInstance cancelChangeSetWithParams: params resolve: resolve reject: reject];
}

- (void) commitChangeSet: (NSDictionary*)params resolve: (SnowblindPromiseResolveBlock)resolve reject: (SnowblindPromiseRejectBlock)reject {
  [DataServiceManager.sharedInstance commitChangeSetWithParams: params resolve: resolve reject: reject];
}

- (void) deleteMedia: (NSDictionary*)params resolve: (SnowblindPromiseResolveBlock)resolve reject: (SnowblindPromiseRejectBlock)reject {
  [DataServiceManager.sharedInstance deleteMediaWithParams: params resolve: resolve reject: reject];
}

- (void) downloadMedia: (NSDictionary*)params resolve: (SnowblindPromiseResolveBlock)resolve reject: (SnowblindPromiseRejectBlock)reject {
  [DataServiceManager.sharedInstance downloadMediaWithParams: params resolve: resolve reject: reject];
}

- (void) isMediaLocal: (NSDictionary*)params resolve: (SnowblindPromiseResolveBlock)resolve reject: (SnowblindPromiseRejectBlock)reject {
  [DataServiceManager.sharedInstance isMediaLocalWithParams: params resolve: resolve reject: reject];
}

- (void) count: (NSDictionary*)params resolve: (SnowblindPromiseResolveBlock)resolve reject: (SnowblindPromiseRejectBlock)reject {
  [DataServiceManager.sharedInstance countWithParams: params resolve: resolve reject: reject];
}

@end

