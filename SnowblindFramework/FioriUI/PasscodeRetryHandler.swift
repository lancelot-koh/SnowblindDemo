//
//  PasscodeRetryHandler.swift
//  SAPMDC
//
//  Copyright © 2016 - 2017 SAP SE or an SAP affiliate company. All rights reserved.
//
//  No part of this publication may be reproduced or transmitted in any form or for any purpose
//  without the express permission of SAP SE. The information contained herein may be changed
//  without prior notice.
//

import Foundation
import SAPCommon

// Note:
// Simulator: The "Keychain Sharing" capability for the app needs to be turned on
// in order for all these operations to be successful. (reason: Apple bug on Simulator)
// Device: On device there are no issues.

class PasscodeRetryHandler {

  private init() {}

  // For storing passcode retry limit and retries remaining
  fileprivate static let kAppPasscodeRetryLimit = "--passcodeRetryLimit"
  fileprivate static let kAppPasscodeRetriesRemaining = "--passcodeRetriesRemaining"

  // MARK: - Passcode Retry Limits handling functions
  public static func setPasscodeRetryLimit(_ retryLimit: Int) {
    PasscodeRetryHandler.saveRetryLimitToKeyChain(retryLimit)
    PasscodeRetryHandler.saveRetriesRemainingToKeyChain(retryLimit)
  }

  public static func decrementPasscodeRetriesRemaining() -> Int {
    var retriesRemaining = PasscodeRetryHandler.loadRetriesRemainingFromKeyChain()
    if retriesRemaining > 0 {
      retriesRemaining -= 1
      saveRetriesRemainingToKeyChain(retriesRemaining)
    }
    return retriesRemaining
  }

  public static func isPasscodeRetryLimitReached() -> Bool {
    let retryLimit = PasscodeRetryHandler.loadRetryLimitFromKeyChain()
    if retryLimit <= 0 {
      return false
    }
    let retriesRemaining = PasscodeRetryHandler.loadRetriesRemainingFromKeyChain()
    return retriesRemaining <= 0
  }

  public static func resetPasscodeRetriesRemaining() {
    let retryLimit = PasscodeRetryHandler.loadRetryLimitFromKeyChain()
    saveRetriesRemainingToKeyChain(retryLimit)
  }

  public static func clearPasscodeRetryStorage() {
    PasscodeRetryHandler.removeRetryLimitFromKeyChain()
    PasscodeRetryHandler.removeRetriesRemainingFromKeyChain()
  }

  // MARK: - Keychain methods
  private static func loadRetryLimitFromKeyChain() -> Int {
    if let retryLimit = KeychainUtils.sharedInstance.loadKeychainInt(key: PasscodeRetryHandler.kAppPasscodeRetryLimit) {
      return retryLimit
    }
    return -1
  }

  private static func saveRetryLimitToKeyChain(_ retryLimit: Int) {
    KeychainUtils.sharedInstance.saveKeychainInt(key: PasscodeRetryHandler.kAppPasscodeRetryLimit, value: retryLimit)
  }

  private static func removeRetryLimitFromKeyChain() {
    KeychainUtils.sharedInstance.removeKeychainValue(key: PasscodeRetryHandler.kAppPasscodeRetryLimit)
  }

  private static func loadRetriesRemainingFromKeyChain() -> Int {
    if let retriesRemaining = KeychainUtils.sharedInstance.loadKeychainInt(key: PasscodeRetryHandler.kAppPasscodeRetriesRemaining) {
      return retriesRemaining
    }
    return -1
  }

  private static func saveRetriesRemainingToKeyChain(_ retriesRemaining: Int) {
    KeychainUtils.sharedInstance.saveKeychainInt(key: PasscodeRetryHandler.kAppPasscodeRetriesRemaining, value: retriesRemaining)
  }

  private static func removeRetriesRemainingFromKeyChain() {
    KeychainUtils.sharedInstance.removeKeychainValue(key: PasscodeRetryHandler.kAppPasscodeRetriesRemaining)
  }

}
