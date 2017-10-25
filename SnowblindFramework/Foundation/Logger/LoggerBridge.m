//
//  LoggerBridge.m
//  SAPMDCFramework
//
//  Copyright © 2017. SAP. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LoggerBridge.h"
#import <SAPMDC/SAPMDC-Swift.h>

@implementation LoggerBridge

-(void)logMessage:(NSString *)message withSeverity:(NSString *)severity{
  [LoggerManagerSwift log:message withSeverity:severity];
}

- (void)addLocalFileHandlerWithFileName:(NSString *)fileName andMaxFileSize:(NSInteger)maxFileSizeInMegaBytes throwsError:(NSError **) error{
    [LoggerManagerSwift addLocalFileHandlerWithFileName:fileName maxFileSize:maxFileSizeInMegaBytes error: error];
}

-(void)activateLogLevel:(NSString *)severity {
  [LoggerManagerSwift activateLogLevelWithSeverity:severity];
}

- (void) attachUploaderToRootLoggerThrowsError:(NSError **) error  {
  [LoggerManagerSwift attachUploaderToRootLoggerAndReturnError:error];
}

- (void) uploadLogsToURL:(NSString *)url forAppID:(NSString*)appID resolve:(SnowblindPromiseResolveBlock)resolve reject:(SnowblindPromiseRejectBlock)reject {
    [LoggerManagerSwift uploadLogsWithBackendURL: url applicationID:appID resolve:resolve reject:reject];
}

@end

