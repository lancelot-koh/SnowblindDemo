//
//  ContactCellTests.swift
//  SAPMDCFramework
//
//  Created by Chitania, Pathik on 4/8/17.
//  Copyright © 2017 SAP. All rights reserved.
//

import XCTest
import SAPFiori
@testable import SAPMDC

class ContactCellTests: XCTestCase {

  override func setUp() {
      super.setUp()
      // Put setup code here. This method is called before the invocation of each test method in the class.
  }

  override func tearDown() {
      // Put teardown code here. This method is called after the invocation of each test method in the class.
      super.tearDown()
  }

  func testConfigureContactCell() {

    let cell = SAPFiori.FUIContactCell()
    let controller = SectionedTableViewController()

    let params = [
      "Headline": "Headline Sample",
      "Subheadline": "Subheadline Sample",
      "Description": "Description Sample",
      "ActivityItems": [
        [
          "ActivityType": "VideoCall",
          "ActivityValue": "630-667-7983"
        ],
        [
          "ActivityType": "Email",
          "ActivityValue": "pathik.chitania@sap.com"
        ],
        [
          "ActivityType": "Detail",
          "ActivityValue": "This is an alert"
        ]
      ]
    ] as NSDictionary
    ContactCell.configureContactCell(cell: cell, params: params, viewController: controller)

    XCTAssertTrue(cell.headlineText == params["Headline"] as? String)
    XCTAssertTrue(cell.subheadlineText == params["Subheadline"] as? String)
    XCTAssertTrue(cell.descriptionText == params["Description"] as? String)
    XCTAssertTrue(cell.activityControl.activityItems.count == 3)
  }

}
