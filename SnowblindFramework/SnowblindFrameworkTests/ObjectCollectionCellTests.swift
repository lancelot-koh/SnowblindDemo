//
//  ObjectCollectionCellTests.swift
//  SAPMDCFramework
//
//  Created by Erickson, Ronnie on 2/20/17.
//  Copyright © 2017 SAP. All rights reserved.
//

import XCTest
import SAPFiori
@testable import SAPMDC

class ObjectCollectionCellTests: XCTestCase {

  override func setUp() {
    super.setUp()
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }

  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
  }

  func testPopulateValidParams() {
    let cell = FUIObjectCollectionViewCell()

    let params = [
      "StatusText": "complete",
      "SubstatusText": "Done",
      "Subhead": "Information Text",
      "Title": "Sample title",
      "Footnote": "My Footnote",
      "DetailImage": "icon.png"
      ] as [String : Any]

    ObjectCollectionCell.configureObjectCollectionCell(cell: cell, params: params as NSDictionary)

    XCTAssertTrue(cell.statusText == "complete")
    XCTAssertNil(cell.statusImage)
    XCTAssertTrue(cell.substatusText == "Done")
    XCTAssertNil(cell.substatusImage)
    XCTAssertTrue(cell.subheadlineText == "Information Text")
    XCTAssertTrue(cell.headlineText == "Sample title")
    XCTAssertNotNil(cell.detailImageView)
  }
}
