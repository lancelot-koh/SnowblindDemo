//  SecureStoreBridge.h
//  SAPMDCFramework
//
//  Created by Nunez Trejo, Manuel on 3/2/17.
//  Copyright © 2017 SAP. All rights reserved.
//

#ifndef SecureStoreBridge_h
#define SecureStoreBridge_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface SecureStoreBridge: NSObject

-(void) openWithEncryptionKey:(NSString*)key throwsError:(NSError**)error;
- (BOOL) isOpen;
-(void) close;
-(void) resetThrowsError:(NSError**)error;
-(void) changeEncryptionKeyTo: (NSString*)newEncryptionKey throwsError:(NSError**)error;
-(void) putString: (NSString *)value forKey:(NSString*)key throwsError:(NSError**)error;
-(NSString*) getStringForKey: (NSString*)key throwsError:(NSError**)error;
-(void) removeKey: (NSString*)key throwsError:(NSError**)error;
-(void) removeAllThrowsError:(NSError**)error;

@end

#endif /* SecureStoreBridge_h */
