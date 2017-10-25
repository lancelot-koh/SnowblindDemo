//
//  ODataServiceUtilsTests.swift
//  SAPMDCFramework
//
//  Created by Thyagarajan, Ramesh on 3/14/17.
//  Copyright © 2017 SAP. All rights reserved.
//

import Foundation
import XCTest

@testable import SAPMDC

class DataServiceUtilsTests: XCTestCase {
  let key = DataServiceUtils.generateOfflineStoreEncryptionKey()
  let allChars = "abcdefghijklmnopqrstuvwxyz"
  let specials = "+-=?*/%&^$!@#_(){}\\|"
  let nums = "0123456789"

  func testEncryptionKeyGeneration() {
    XCTAssertNotNil(key)
  }

  func testEncryptionKeyLen() {
    XCTAssert((key?.characters.count)! >= 16)
  }

  func testEncryptionKeyContainsLowerCase() {
    let charset = CharacterSet(charactersIn: allChars)
    XCTAssertNotNil(key!.rangeOfCharacter(from: charset))
  }

  func testEncryptionKeyContainsUpperCase() {
    let charset = CharacterSet(charactersIn: allChars.uppercased())
    XCTAssertNotNil(key!.rangeOfCharacter(from: charset))
  }

  func testEncryptionKeyContainsNums() {
    let charset = CharacterSet(charactersIn: nums)
    XCTAssertNotNil(key!.rangeOfCharacter(from: charset))
  }

  func testEncryptionKeyContainsSpecials() {
    let charset = CharacterSet(charactersIn: specials)
    XCTAssertNotNil(key!.rangeOfCharacter(from: charset))
  }
}
