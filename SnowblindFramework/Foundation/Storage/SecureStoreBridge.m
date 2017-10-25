//
//  SecureStoreBridge.m
//  SAPMDCFramework
//
//  Created by Nunez Trejo, Manuel on 3/2/17.
//  Copyright © 2017 SAP. All rights reserved.
//
#import "SecureStoreBridge.h"
#import <Foundation/Foundation.h>
#import <SAPMDC/SAPMDC-Swift.h>


@implementation SecureStoreBridge

-(void) openWithEncryptionKey:(NSString*)key throwsError:(NSError**)error {
  [[SecureStoreManager sharedInstance] openWith:key error:error];
}

- (BOOL) isOpen {
  return [[SecureStoreManager sharedInstance] isOpen];
}

-(void) close {
  [[SecureStoreManager sharedInstance] close];
}

-(void) resetThrowsError:(NSError**)error {
    [[SecureStoreManager sharedInstance] resetAndReturnError:error];
}

-(void) changeEncryptionKeyTo: (NSString*)newEncryptionKey throwsError:(NSError**)error {
  [[SecureStoreManager sharedInstance] changeEncryptionKeyWith:newEncryptionKey error:error];
}

-(void) putString: (NSString *)value forKey:(NSString*)key throwsError:(NSError**)error {
  [[SecureStoreManager sharedInstance] put:value forKey:key error:error];
}

-(NSString*) getStringForKey: (NSString*)key throwsError:(NSError**)error {
  NSString* value = [[SecureStoreManager sharedInstance] getStringObjC:key error:error];
  NSError* errorObj = *error;
  if (errorObj && [errorObj.domain isEqualToString:SBSecureStoreErrorDomain]
      && errorObj.code == SBSecureStoreErrorKeyNotFound) {
    // There wasn't really an error, this key just doesn't have a value yet
    // See comments in SecureStore.swift as to why this is needed
    // (tl;dr: auto bridging limitations of Swift-Objective-c)
    *error = nil;
    value = nil;
  }
  return value;
}

-(void) removeKey: (NSString*)key throwsError:(NSError**)error {
  [[SecureStoreManager sharedInstance] remove:key error:error];
}

-(void) removeAllThrowsError:(NSError**)error {
  [[SecureStoreManager sharedInstance] removeAllAndReturnError:error];
}

@end
