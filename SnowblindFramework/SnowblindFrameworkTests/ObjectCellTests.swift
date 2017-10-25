//
//  ObjectCellTests.swift
//  SAPMDCFramework
//
//  Created by Mehta, Kunal on 10/24/16.
//  Copyright © 2016 SAP. All rights reserved.
//

import XCTest
import SAPFiori
@testable import SAPMDC

class ObjectCellTests: XCTestCase {

  override func setUp() {
    super.setUp()
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }

  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
  }

  func testCreateCell() {
    XCTAssertTrue(ObjectCell.create() is SAPFiori.FUIObjectTableViewCell)
  }

  func testPopulateEmptyParams() {
    let params = NSMutableDictionary()
    ObjectCell.populate(params: params)
    XCTAssertTrue(params.count == 0)
  }

  func testPopulateValidParams() {
    let cell = ObjectCell.create()

    let params = [
      "AccessoryType": "disclosureIndicator",
      "StatusText": "complete",
      "SubstatusText": "Done",
      "Subhead": "Information Text",
      "Title": "Sample title",
      "DetailImage": "icon.png",
      "Description": "This is a very long Description",
      "PreserveIconStackSpacing": false,
      "cell": cell
      ] as [String : Any]
    ObjectCell.populate(params: params as NSDictionary)

    if let objCell = cell as? SAPFiori.FUIObjectTableViewCell {
      XCTAssertTrue(objCell.accessoryType == .disclosureIndicator)
      XCTAssertNotNil(objCell.accessoryView)
      XCTAssertTrue(objCell.statusText == "complete")
      XCTAssertNil(objCell.statusImage)

      XCTAssertTrue(objCell.substatusText == "Done")
      XCTAssertNil(objCell.substatusImage)

      XCTAssertTrue(objCell.subheadlineText == "Information Text")
      XCTAssertTrue(objCell.headlineText == "Sample title")
      XCTAssertNotNil(objCell.detailImageView)
      XCTAssertTrue(objCell.descriptionText == "This is a very long Description")
      XCTAssertFalse(objCell.preserveIconStackSpacing)
    } else {
      XCTFail()
    }

  }

}
