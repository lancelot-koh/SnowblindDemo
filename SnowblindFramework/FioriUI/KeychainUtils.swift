//
//  KeychainUtils.swift
//  SAPMDC
//
//  Created by Hably, Alexandra on 2017. 09. 27..
//  Copyright © 2017. SAP. All rights reserved.
//

import Foundation

class KeychainUtils {

  // Note:
  // Simulator: The "Keychain Sharing" capability for the app needs to be turned on
  // in order for all these operations to be successful. (reason: Apple bug on Simulator)
  // Device: On device there are no issues.

  // Singleton
  public static let sharedInstance = KeychainUtils()
  private init() {}

  // MARK: - Public functions
  public func loadKeychainInt(key: String) -> Int? {
    let s = loadKeychainString(key: key)
    if s != nil {
      return Int.init(s!)
    }
    return nil
  }

  public func removeKeychainValue(key: String) {
    let keychainQuery: NSMutableDictionary = NSMutableDictionary(
      objects: [kSecClassGenericPassword as NSString, key],
      forKeys: [kSecClass as NSString, kSecAttrAccount as NSString])
    SecItemDelete(keychainQuery)
  }

  public func saveKeychainInt(key: String, value: Int) {
    let s = String(value)
    saveKeychainString(key: key, value: s)
  }

  // MARK: - Private helpers
  // Load Data from Keychain
  private func loadKeychainData(key: String) -> Data? {
    var keychainQuery: [String: AnyObject] = [String: AnyObject]()
    keychainQuery[kSecClass as String] = kSecClassGenericPassword
    keychainQuery[kSecAttrAccount as String] = key as AnyObject
    keychainQuery[kSecMatchLimit as String] = kSecMatchLimitOne
    keychainQuery[kSecReturnData as String] = kCFBooleanTrue
    var resultValue: AnyObject?
    let result = withUnsafeMutablePointer(to: &resultValue) {
      SecItemCopyMatching(keychainQuery as CFDictionary, UnsafeMutablePointer($0))
    }
    if result == noErr {
      return resultValue as? Data
    }
    return nil
  }

  // Load String from Keychain
  private func loadKeychainString(key: String) -> String? {
    let data = loadKeychainData(key: key)
    if data != nil {
      return String(data: data!, encoding: .utf8)
    }
    return nil
  }

  // Save Data to Keychain
  private func saveKeychainData(key: String, data: Data) {
    removeKeychainValue(key: key)
    var keychainQuery: [String: AnyObject] = [String: AnyObject]()
    keychainQuery[kSecClass as String] = kSecClassGenericPassword
    keychainQuery[kSecAttrAccount as String] = key as AnyObject
    keychainQuery[kSecValueData as String] = data as AnyObject
    keychainQuery[kSecAttrAccessible as String] = kSecAttrAccessibleAlwaysThisDeviceOnly
    let result = SecItemAdd(keychainQuery as CFDictionary, nil)
    if result != noErr {
      print("Failed to do save to key chain - error \(result)")
    }
  }

  // Save String to Keychain
  private func saveKeychainString(key: String, value: String) {
    let data = value.data(using: .utf8)
    saveKeychainData(key: key, data: data!)
  }

}
