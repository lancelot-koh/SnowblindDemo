//
//  PasscodeInputScreenDelegate.h
//  SAPMDCFramework
//
//  Created by Thyagarajan, Ramesh on 3/18/17.
//  Copyright © 2017 SAP. All rights reserved.
//

#ifndef PasscodeInputScreenDelegate_h
#define PasscodeInputScreenDelegate_h

@interface PasscodeInputScreenDelegate : NSObject

- (void)finishedOnboardingWithParams:(NSDictionary<NSString *, NSString *> * _Nonnull) offlineStoreEncKey;
- (void)setOnboardingStage:(NSString * _Nonnull) stage;
- (void)resetClient;
- (void)cancelPasscode;

@end

#endif /* PasscodeInputScreenDelegate_h */
