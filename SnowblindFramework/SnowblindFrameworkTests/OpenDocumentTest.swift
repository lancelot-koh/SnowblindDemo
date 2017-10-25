//
//  OpenDocumentTest.swift
//  SAPMDC
//
//  Copyright © 2017 SAP. All rights reserved.
//

import XCTest
import SAPFiori
@testable import SAPMDC

class OpenDocumentTest: XCTestCase {
  let resolveBlock = { (_: Any?) in }
  let rejectBlock = { (_: Optional<String>, _: Optional<String>, _: Optional<Error>) in }

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testExample() {
      OpenDocument.open(path: "", resolve: resolveBlock, reject: rejectBlock)
      OpenDocument.open(path: "res://testResourcePath", resolve: resolveBlock, reject: rejectBlock)
      OpenDocument.open(path: "res://testResourcePath.pdf", resolve: resolveBlock, reject: rejectBlock)
      OpenDocument.open(path: "test/file/Path.jpg", resolve: resolveBlock, reject: rejectBlock)
      OpenDocument.open(path: "test/file", resolve: resolveBlock, reject: rejectBlock)
      OpenDocument.open(path: "/test/file", resolve: resolveBlock, reject: rejectBlock)
      OpenDocument.open(path: "/", resolve: resolveBlock, reject: rejectBlock)
  }
}
