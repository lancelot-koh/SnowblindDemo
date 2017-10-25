//
//  SectionsTest.swift
//  SAPMDCFramework
//
//  Created by Thyagarajan, Ramesh on 2/8/17.
//  Copyright © 2017 SAP. All rights reserved.
//

import XCTest
import SAPFiori
@testable import SAPMDC

// swiftlint:disable line_length
// swiftlint:disable function_body_length

class SectionsTests: XCTestCase {

  let kvString = "[{\"key\":\"Artist\",\"value\":\"Pink Floyd\"},{\"key\":\"Year\",\"value\":\"1973\"}]"
  let itemsString = "[{\"AccessoryType\":\"disclosureIndicator\",\"Description\":\"WO with 2 operations\",\"Footnote\":\"REL  CSER MACM PRC  SETC\",\"Title\":\"000004000027\",\"Icons\":[],\"StatusText\":\"REL  CSER MACM PRC  SETC\",\"Subhead\":\"MECHANIK\",\"SubstatusText\":\"TEST-FLC-XY-00\"},{\"AccessoryType\":\"disclosureIndicator\",\"Description\":\"Transformer Overheating\",\"Footnote\":\"CRTD CSER MANC NMAT PRC\",\"Title\":\"000004000000\",\"Icons\":[],\"StatusText\":\"CRTD CSER MANC NMAT PRC\",\"Subhead\":\"MECHANIK\",\"SubstatusText\":\"TEST-FLC-XY-00\"},{\"AccessoryType\":\"disclosureIndicator\",\"Description\":\"Annual Relay Testing\",\"Footnote\":\"REL  CSER MACM PRC  SETC\",\"Title\":\"000004000025\",\"Icons\":[],\"StatusText\":\"REL  CSER MACM PRC  SETC\",\"Subhead\":\"MECHANIK\",\"SubstatusText\":\"TEST-FLC-XY-00\"},{\"AccessoryType\":\"disclosureIndicator\",\"Description\":\"For Demo From Jin\",\"Footnote\":\"REL  CSER PRC\",\"Title\":\"000004000009\",\"Icons\":[],\"StatusText\":\"REL  CSER PRC\",\"Subhead\":\"MECHANIK\",\"SubstatusText\":\"TEST-FLC-XY-00\"},{\"AccessoryType\":\"disclosureIndicator\",\"Description\":\"Pump Repair.\",\"Footnote\":\"REL  CSER MACM PRC  SETC\",\"Title\":\"000004000021\",\"Icons\":[],\"StatusText\":\"REL  CSER MACM PRC  SETC\",\"Subhead\":\"MECHANIK\",\"SubstatusText\":\"TEST-FLC-XY-00\"}]"
  var kvParams: [String: Any] = [:]
  var objTableParams: [String: Any] = [:]
  var emptyObjectTableParams: [String: Any] = [:]
  var objCollectionParams: [String: Any] = [:]
  var contactCellParams: [String: Any] = [:]
  let contactCellString = "[{\"Headline\":\"Theo Epstein\",\"Subheadline\":\"The Curse Breaker\",\"Description\":\"Wrigley Field, 1060 West Addison Street, Chicago IL\",\"ActivityItems\":[{\"ActivityType\":\"VideoCall\",\"ActivityValue\":\"630-667-7983\"},{\"ActivityType\":\"Email\",\"ActivityValue\":\"pathik.chitania@sap.com\"},{\"ActivityType\":\"Detail\",\"ActivityValue\":\"This is an alert\"}]},{\"Headline\":\"Theo Epstein\",\"Subheadline\":\"The Curse Breaker\",\"Description\":\"Wrigley Field, 1060 West Addison Street, Chicago IL\",\"ActivityItems\":[{\"ActivityType\":\"Phone\",\"ActivityValue\":\"630-667-7983\"},{\"ActivityType\":\"Email\",\"ActivityValue\":\"pathik.chitania@sap.com\"},{\"ActivityType\":\"Message\",\"ActivityValue\":\"630-667-7983\"}]}]"
  var buttonSectionParams: [String: Any] = [:]
  let buttonSectionString = "[{\"Title\":\"Button1\",\"OnPress\":\"/AssetWorkManager/Actions/Messages/Message1.action\",\"TextAlignment\":\"left\"}, {\"Title\":\"Button2\",\"OnPress\":\"/AssetWorkManager/Actions/Messages/Message2.action\",\"TextAlignment\":\"center\"}]"
  let searchParams: [String: Any] = [
    "Enabled": true,
    "Placeholder": "TEST PLACEHOLDER",
    "BarcodeScanner": true,
    "MinimumCharacterThreshold": 3,
    "Delay": 1000
  ]

  override func setUp() {
    super.setUp()
    // Put setup code here. This method is called before the invocation of each test method in the class.
    kvParams = [
      "type": "Section.Type.KeyValue",
      "usesHeader": true,
      "headerTitle": "MyHEADER",
      "headeStyle": FUISectionHeaderFooterStyle.title,
      "useHeaderTopPadding": true,
      "usesFooter": true,
      "footerTitle": "MyFOOTER",
      "footerAccessoryType": "detailButton",
      "footerAttributeLabel": "myLabel",
      "useFooterBottomPadding": false,
      "isDisclosureAccessoryHidden": false,
      "maxItemCount": 1,
      "keyValues": self.kvString
    ]

    objTableParams = [
      "type": "Section.Type.ObjectTable",
      "usesHeader": true,
      "headerTitle": "MyHEADER",
      "useHeaderTopPadding": true,
      "usesFooter": true,
      "footerTitle": "MyFOOTER",
      "footerAccessoryType": "detailButton",
      "footerAttributeLabel": "myLabel",
      "useFooterBottomPadding": false,
      "maxItemCount": 1,
      "items": self.itemsString,
      "Search": searchParams
    ]

    emptyObjectTableParams = [
      "type": "Section.Type.ObjectTable",
      "usesHeader": true,
      "headerTitle": "MyHEADER",
      "useHeaderTopPadding": true,
      "usesFooter": true,
      "footerTitle": "MyFOOTER",
      "footerAccessoryType": "detailButton",
      "footerAttributeLabel": "myLabel",
      "useFooterBottomPadding": false,
      "maxItemCount": 0,
      "emptySectionCaption": "MyEmptySectionCaption",
      "emptySectionStyle": "MyEmptySectionStyle"
    ]

    objCollectionParams = [
      "type": "Section.Type.ObjectCollection",
      "usesHeader": true,
      "headerTitle": "MyHEADER",
      "useHeaderTopPadding": true,
      "usesFooter": true,
      "footerTitle": "MyFOOTER",
      "footerAccessoryType": "detailButton",
      "footerAttributeLabel": "myLabel",
      "useFooterBottomPadding": false,
      "maxItemCount": 1,
      "items": self.itemsString
    ]

    contactCellParams = [
      "type": "Section.Type.ContactCell",
      "items": self.contactCellString
    ]

    buttonSectionParams = [
      "type": "Section.Type.ButtonTable",
      "items": self.buttonSectionString
    ]
  }

  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
  }

  func testSingleton() {
    let firstInstance = SectionFactory.sharedInstance
    let secondInstance = SectionFactory.sharedInstance

    XCTAssert(firstInstance == secondInstance)
  }

  func testCreateSectionKeyValue() {
    if let section = SectionFactory.sharedInstance.createSection(params: self.kvParams as NSDictionary, callback: SectionDelegate()) {
      XCTAssertTrue(section is KeyValueSection)
    } else {
      XCTFail()
    }
  }

  func testCreateSectionObjectTable() {
    if let section = SectionFactory.sharedInstance.createSection(params: self.objTableParams as NSDictionary, callback: SectionDelegate()) {
      XCTAssertTrue(section is ObjectTableSection)
    } else {
      XCTFail()
    }
  }

  func testCreateSectionObjectCollection() {
    if let section = SectionFactory.sharedInstance.createSection(params: self.objCollectionParams as NSDictionary, callback: SectionDelegate()) {
      XCTAssertTrue(section is ObjectCollectionSection)
    } else {
      XCTFail()
    }
  }

  func testCreateSectionContactCell() {
    if let section = SectionFactory.sharedInstance.createSection(params: self.contactCellParams as NSDictionary, callback: SectionDelegate()) {
      XCTAssertTrue(section is ContactCellSection)
    } else {
      XCTFail()
    }
  }

  func testCreateButtonSection() {
    if let section = SectionFactory.sharedInstance.createSection(params: self.buttonSectionParams as NSDictionary, callback: SectionDelegate()) {
      XCTAssertTrue(section is FUIViewSection)
      XCTAssertTrue(section is ButtonSection)
    } else {
      XCTFail()
    }
  }

  func testKVPairsCount() {
    let aSection = KeyValueSection(params: self.kvParams as NSDictionary, callback: SectionDelegate())
    XCTAssert(aSection.keyValues.count == 2, "Incorrect KV count retrieved")
  }

  func testSectionContent() {
    let aSection = KeyValueSection(params: self.kvParams as NSDictionary, callback: SectionDelegate())
    XCTAssert(aSection.keyValues[1].value == "1973", "Incorrect value retrieved")
  }

  func testSectionMaxItemCount() {
    let aSection = KeyValueSection(params: self.kvParams as NSDictionary, callback: SectionDelegate())
    XCTAssert(aSection.maxItemCount == 2, "Should equal size of key value data array")
  }

  func testSectionFooterTitle() {
    let aSection = KeyValueSection(params: self.kvParams as NSDictionary, callback: SectionDelegate())
    XCTAssert(aSection.footerTitle == "MyFOOTER", "Incorrect footer title")
  }

  func testSectionFooterAccessoryType() {
    let aSection = KeyValueSection(params: self.kvParams as NSDictionary, callback: SectionDelegate())
    XCTAssert(aSection.footerAccessoryType == "detailButton", "Incorrect footer accessory type")
  }

  func testSectionFooterAttributeLabel() {
    let aSection = KeyValueSection(params: self.kvParams as NSDictionary, callback: SectionDelegate())
    XCTAssert(aSection.footerAttributeLabel == "myLabel", "Incorrect footer attribute label")
  }

  func testSectionFooterStyle() {
    var aSection = KeyValueSection(params: self.kvParams as NSDictionary, callback: SectionDelegate())
    XCTAssertEqual(aSection.footerStyle, .title, "Default is .title")

    kvParams["footerStyle"] = "attribute"
    aSection = KeyValueSection(params: self.kvParams as NSDictionary, callback: SectionDelegate())
    XCTAssertEqual(aSection.footerStyle, .attribute, "'attribute' maps to .attribute")
    XCTAssertEqual(aSection.footerStyle.toFUIFooterStyle(), .attribute, ".attribute maps to FUI .attribute style")

    kvParams["footerStyle"] = "help"
    aSection = KeyValueSection(params: self.kvParams as NSDictionary, callback: SectionDelegate())
    XCTAssertEqual(aSection.footerStyle, .help, "'help' maps to .help")
    XCTAssertEqual(aSection.footerStyle.toFUIFooterStyle(), nil, ".help doesn't map to a FUI style")

    kvParams["footerStyle"] = "title"
    aSection = KeyValueSection(params: self.kvParams as NSDictionary, callback: SectionDelegate())
    XCTAssertEqual(aSection.footerStyle, .title, "'title' maps to .title")
    XCTAssertEqual(aSection.footerStyle.toFUIFooterStyle(), .title, ".title maps to FUI .title style")
}

  func testSectionHeaderTitle() {
    let aSection = KeyValueSection(params: self.kvParams as NSDictionary, callback: SectionDelegate())
    XCTAssert(aSection.headerTitle == "MyHEADER", "Incorrect header title")
  }

  func testSectionHeaderUseTopPadding() {
    let aSection = KeyValueSection(params: self.kvParams as NSDictionary, callback: SectionDelegate())
    XCTAssert(aSection.useHeaderTopPadding == true, "Incorrect header section useTopPadding")
  }

  func testSectionFooterUseBottomPadding() {
    let aSection = KeyValueSection(params: self.kvParams as NSDictionary, callback: SectionDelegate())
    XCTAssert(aSection.useFooterBottomPadding == false, "Incorrect header foot useBottomPadding")
  }

  func testObjectTableSearchSettings() {
    if let aSection: ObjectTableSection = SectionFactory.sharedInstance.createSection(params: self.objTableParams as NSDictionary,
                                                                                      callback: SectionDelegate()) as? ObjectTableSection {
      XCTAssert(aSection.search.enabled == true, "Search should be enabled")
      XCTAssert(aSection.search.barcodeScanner == true, "Search via barcode scan should be enabled")
      XCTAssert(aSection.search.placeholder == "TEST PLACEHOLDER", "Search placeholder text is incorrect")
      XCTAssert(aSection.search.delay == 1, "Search delay should be set to 1 second")
      XCTAssert(aSection.search.minimumCharacterThreshold == 3, "Search minimumCharacterThreshold should be set to 3")
    } else {
      XCTFail()
    }
  }

  func testEmptySectionSettingsWithItems() {
    if let section: ObjectTableSection = SectionFactory.sharedInstance.createSection(params: self.objTableParams as NSDictionary,
                                                                                      callback: SectionDelegate()) as? ObjectTableSection {
      XCTAssertNil(section.emptySectionCaption, "Empty section captioned should not be defined")
      XCTAssertFalse(section.usesEmptySectionRow(), "Does not use the empty section row if no caption")
      XCTAssertNil(section.emptySectionStyle, "Empty section captioned should not be defined")
      XCTAssertFalse(section.isSectionEmpty(), "Is not empty")
    } else {
      XCTFail()
    }
  }

  func testEmptySectionSettingsWithoutItems() {
    if let section: ObjectTableSection = SectionFactory.sharedInstance.createSection(params: self.emptyObjectTableParams as NSDictionary,
                                                                                     callback: SectionDelegate()) as? ObjectTableSection {
      XCTAssertEqual(section.emptySectionCaption, "MyEmptySectionCaption", "Empty section caption should match")
      XCTAssertTrue(section.usesEmptySectionRow(), "Does use the empty section row")
      XCTAssertEqual(section.emptySectionStyle, "MyEmptySectionStyle", "Empty section style should match")
      XCTAssertTrue(section.isSectionEmpty(), "It is empty")
    } else {
      XCTFail()
    }
  }
}
