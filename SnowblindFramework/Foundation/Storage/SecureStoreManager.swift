//
//  SecureStoreManager.swift
//  SAPMDCFramework
//
//  Created by Nunez Trejo, Manuel on 3/1/17.
//  Copyright © 2017 SAP. All rights reserved.
//

import Foundation
import SAPFoundation

// The Swift implementation for the SecureStore manager used
// by the App Modeler to store and retrieve strings securely.

// swiftlint:disable identifier_name
@objc public enum SBSecureStoreError: Int, Error {
  // This isn't really an error, but due to Swift-ObjC bridging when dealing
  // with exceptions, we must return a non-optional. So, get() will raise this
  // error to be caught by the caller and mean the key was not found and
  // translate it to value = null and no error.
  case KeyNotFound
}

@objc public class SecureStoreManager: NSObject {

  // This is initialized the first time the singleton is accessed
  var store: SecureKeyValueStore

  // The SDK team recommends keeping this in case the store needs
  // to be reset since that is only doable by removing the file
  var storeFullDatabasePath: String

  // Unit tests can change this static variable to create different stores
  // for testing. The client however, will have only one store, and this is
  // its name.
  static var defaultDataBaseFileName: String = "SnowblindSecureStore.db"

  // Singleton instance
  @objc public static let sharedInstance: SecureStoreManager = {
    let instance = SecureStoreManager()
    return instance
  }()

  // The path where we will store the Secure Store
  private class var fullDatabasePath: String {

    guard let cachesDirectoryUrl = try? FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false) else {
      return SecureStoreManager.defaultDataBaseFileName
    }

    let fullDatabasePath = cachesDirectoryUrl.appendingPathComponent(SecureStoreManager.defaultDataBaseFileName)

    return fullDatabasePath.path
  }

  init(fullDatabasePath: String = SecureStoreManager.fullDatabasePath) {
    store = SecureKeyValueStore(fullDatabasePath: fullDatabasePath)
    storeFullDatabasePath = fullDatabasePath
  }

  // MARK: - Store Lifecycle

  @objc public func open(with encryptionKey: String) throws {
    try store.open(with: encryptionKey)
    SecureOAuth2TokenStore.sharedInstance.syncInMemoryTokenToStore()
  }

  @objc public func isOpen() -> Bool {
    return store.isOpen()
  }

  @objc public func close() {
    store.close()
  }

  // This will close and delete the Secure Store file completely.
  //
  // After this call, the user is able to call open() again with
  // a new passcode and keep using the new Store.
  @objc public func reset() throws {
    if store.isOpen() {
      store.close()
    }
    try FileManager.default.removeItem(atPath: storeFullDatabasePath)
  }

  @objc public func changeEncryptionKey(with newEncryptionKey: String) throws {
    try store.changeEncryptionKey(with: newEncryptionKey)
  }

  // MARK: - Store value access

  @objc public func put(_ value: String, forKey key: String) throws {
    try store.put(value, forKey: key)
  }

  public func getString(_ forKey: String) throws -> String? {
    return try store.getString(forKey)
  }

  @objc public func getStringObjC(_ forKey: String) throws -> String {
    if let value = try getString(forKey) {
      return value
    }
    // This isn't really an error, but due to Swift-ObjC bridging when dealing
    // with exceptions, we must return a non-optional. So, get() will raise this
    // error to be caught by the caller and mean the key was not found and
    // translate it to value = null
    throw SBSecureStoreError.KeyNotFound
  }

  @objc public func remove(_ key: String) throws -> Void {
    _ = try store.remove(key)
  }

  @objc public func removeAll() throws {
    try store.removeAll()
  }
}
