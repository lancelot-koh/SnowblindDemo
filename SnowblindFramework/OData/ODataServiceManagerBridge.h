//
//  ODataServiceManagerBridge.h
//  SnowblindClient
//
//  Copyright © 2016 sap. All rights reserved.
//

#ifndef ODataServiceManagerBridge_h
#define ODataServiceManagerBridge_h

#import <Foundation/Foundation.h>
#import "BridgeCommon.h"

@interface ODataServiceManagerBridge : NSObject

- (void) download: (NSDictionary*)params resolve: (SnowblindPromiseResolveBlock)resolve reject: (SnowblindPromiseRejectBlock)reject;
- (void) initializeOfflineStore: (NSDictionary*)params resolve: (SnowblindPromiseResolveBlock)resolve reject: (SnowblindPromiseRejectBlock)reject;
- (void) closeOfflineStore: (NSDictionary*)params resolve: (SnowblindPromiseResolveBlock)resolve reject: (SnowblindPromiseRejectBlock)reject;
- (void) clearOfflineStore: (NSDictionary*)params resolve: (SnowblindPromiseResolveBlock)resolve reject: (SnowblindPromiseRejectBlock)reject;
- (void) upload: (NSDictionary*)params resolve: (SnowblindPromiseResolveBlock)resolve reject: (SnowblindPromiseRejectBlock)reject;
- (void) create: (NSDictionary*)params resolve: (SnowblindPromiseResolveBlock)resolve reject: (SnowblindPromiseRejectBlock)reject;
- (void) open: (NSDictionary*)params resolve: (SnowblindPromiseResolveBlock)resolve reject: (SnowblindPromiseRejectBlock)reject;
- (void) read: (NSDictionary*)params resolve: (SnowblindPromiseResolveBlock)resolve reject: (SnowblindPromiseRejectBlock)reject;
- (void) update: (NSDictionary*)params resolve: (SnowblindPromiseResolveBlock)resolve reject: (SnowblindPromiseRejectBlock)reject;
- (void) createEntity: (NSDictionary*)params resolve: (SnowblindPromiseResolveBlock)resolve reject: (SnowblindPromiseRejectBlock)reject;
- (void) deleteEntity: (NSDictionary*)params resolve: (SnowblindPromiseResolveBlock)resolve reject: (SnowblindPromiseRejectBlock)reject;
- (void) createMedia: (NSDictionary*)params resolve: (SnowblindPromiseResolveBlock)resolve reject: (SnowblindPromiseRejectBlock)reject;
- (void) beginChangeSet: (NSDictionary*)params resolve: (SnowblindPromiseResolveBlock)resolve reject: (SnowblindPromiseRejectBlock)reject;
- (void) cancelChangeSet: (NSDictionary*)params resolve: (SnowblindPromiseResolveBlock)resolve reject: (SnowblindPromiseRejectBlock)reject;
- (void) commitChangeSet: (NSDictionary*)params resolve: (SnowblindPromiseResolveBlock)resolve reject: (SnowblindPromiseRejectBlock)reject;
- (void) deleteMedia: (NSDictionary*)params resolve: (SnowblindPromiseResolveBlock)resolve reject: (SnowblindPromiseRejectBlock)reject;
- (void) downloadMedia: (NSDictionary*)params resolve: (SnowblindPromiseResolveBlock)resolve reject: (SnowblindPromiseRejectBlock)reject;
- (void) isMediaLocal: (NSDictionary*)params resolve: (SnowblindPromiseResolveBlock)resolve reject: (SnowblindPromiseRejectBlock)reject;
- (void) count: (NSDictionary*)params resolve: (SnowblindPromiseResolveBlock)resolve reject: (SnowblindPromiseRejectBlock)reject;
@end


#endif /* ODataServiceManagerBridge_h */
