//
//  SecureStoreManagerTests.swift
//  SAPMDCFramework
//
//  Created by Nunez Trejo, Manuel on 3/1/17.
//  Copyright © 2017 SAP. All rights reserved.
//

import XCTest
import Foundation
import SAPFoundation
@testable import SAPMDC

class SecureStoreManagerTests: XCTestCase {

  let testStoreDataBaseName = "SecureStoreManagerTestStore.db"
  let testStoreEncryptionKey = "abc123"

  override func setUp() {
    super.setUp()
    // Let the tests use their own secure store so they are isolated
    SecureStoreManager.defaultDataBaseFileName = testStoreDataBaseName
    do {
      try SecureStoreManager.sharedInstance.open(with: testStoreEncryptionKey)
    } catch {
      XCTFail("Cannot open the store for testing")
    }
  }

  override func tearDown() {
    do {
      try SecureStoreManager.sharedInstance.reset()
    } catch {
      XCTFail("Cannot reset the store")
    }
    super.tearDown()
  }

  func testIsOpen() {
    // We open the store in setUp()
    XCTAssertTrue(SecureStoreManager.sharedInstance.isOpen(), "Store should be open")
    // We reset and close the store in tearDown()
  }

  func testChangeKey() {
    do {
      let newKey = "AnotherKey123"
      try SecureStoreManager.sharedInstance.changeEncryptionKey(with: newKey)
      SecureStoreManager.sharedInstance.close()
      try SecureStoreManager.sharedInstance.open(with: newKey)
      XCTAssertTrue(SecureStoreManager.sharedInstance.isOpen(), "Store should be open")

      // Since the store persists, and there is no way to remove it,
      // Change it back before leaving for the other tests
      try SecureStoreManager.sharedInstance.changeEncryptionKey(with: testStoreEncryptionKey)
    } catch {
      XCTFail("Unexpected exception in test")
    }
  }

  func testPut() {
    do {
      try SecureStoreManager.sharedInstance.put("Value", forKey: "Key")
      XCTAssertEqual(try SecureStoreManager.sharedInstance.getString("Key"), "Value")

      try SecureStoreManager.sharedInstance.put("Another Value", forKey: "Key")
      XCTAssertEqual(try SecureStoreManager.sharedInstance.getString("Key"), "Another Value")
    } catch {
      XCTFail("Unexpected exception in test")
    }
  }

  func testGet() {
    do {
      // Not found in Swift
      let value = try SecureStoreManager.sharedInstance.getString("BadKey")
      XCTAssertNil(value, "Store should not contain this key")

      // Not found for ObjC
      do {
        _ = try SecureStoreManager.sharedInstance.getStringObjC("BadKey")
      } catch SBSecureStoreError.KeyNotFound {
        // All good
      } catch {
        XCTFail("Unexpected exception in test")
      }

      // Found
      try SecureStoreManager.sharedInstance.put("Value", forKey: "Key")
      XCTAssertEqual(try SecureStoreManager.sharedInstance.getString("Key"), "Value")
    } catch {
      XCTFail("Unexpected exception in test")
    }
  }

  func testRemove() {
    do {
      try SecureStoreManager.sharedInstance.remove("BadKey")
      try SecureStoreManager.sharedInstance.put("Value", forKey: "Key")
      try SecureStoreManager.sharedInstance.remove("Key")
      XCTAssertNil(try SecureStoreManager.sharedInstance.getString("Key"), "Store should not contain this key")
    } catch {
      XCTFail("Unexpected exception in test")
    }
  }

  func testRemoveAll() {
    do {
      try SecureStoreManager.sharedInstance.put("Value1", forKey: "Key1")
      try SecureStoreManager.sharedInstance.put("Value2", forKey: "Key2")
      try SecureStoreManager.sharedInstance.removeAll()
      XCTAssertNil(try SecureStoreManager.sharedInstance.getString("Key1"), "Store should not contain  Key1")
      XCTAssertNil(try SecureStoreManager.sharedInstance.getString("Key2"), "Store should not contain Key2 either")
    } catch {
      XCTFail("Unexpected exception in test")
    }
  }
}
