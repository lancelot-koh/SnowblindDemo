//
//  LoggerBridge.h
//  SAPMDCFramework
//
//  Copyright © 2017. SAP. All rights reserved.
//

#ifndef LoggerBridge_h
#define LoggerBridge_h

#import <Foundation/Foundation.h>
#import "BridgeCommon.h"

@interface LoggerBridge : NSObject

/* Logs a message */
-(void) logMessage: (NSString*)message withSeverity:(NSString *)severity;

/* Sets log level */
-(void) activateLogLevel: (NSString*)severity;

/* Adds local file handler to root logger */
- (void) addLocalFileHandlerWithFileName: (NSString *)fileName andMaxFileSize:(NSInteger)maxFileSizeInMegaBytes throwsError:(NSError **) error;

/* Attach the uploader to the root logger */
- (void) attachUploaderToRootLoggerThrowsError:(NSError **) error;

/* Uploads the current set of logs to the backend URL with app ID, since the last upload */
- (void) uploadLogsToURL:(NSString *)url forAppID:(NSString*)appID  resolve: (SnowblindPromiseResolveBlock)resolve reject: (SnowblindPromiseRejectBlock)reject;

@end

#endif /* LoggerBridge_h */
