//
//  OAuthRequestorTest.swift
//  SAPMDCFramework
//
//  Created by Wonderley, Lucas on 3/27/17.
//  Copyright © 2017 SAP. All rights reserved.
//

import Foundation
import XCTest
import SAPFoundation
import SAPCommon

@testable import SAPMDC

class OAuthRequestorTests: XCTestCase {

  override func setUp() {
    super.setUp()
  }

  override func tearDown() {
    super.tearDown()
  }

  func testInitialize() {
    let params: NSDictionary = [
      "ApplicationID": "AID",
      "AuthorizationEndpointURL": "AEURL",
      "ClientID": "CID",
      "RedirectURL": "RURL",
      "TokenEndpointURL": "TEURL"
    ]
    let requestor = OAuthRequestor()
    XCTAssertNil(requestor.authenticator)
    XCTAssertNil(requestor.cpmsObserver)
    XCTAssertNil(requestor.oauthObserver)
    requestor.initialize(params: params)
    XCTAssertNotNil(requestor.authenticator)
    XCTAssertNotNil(requestor.cpmsObserver)
    XCTAssertNotNil(requestor.oauthObserver)
    XCTAssert(requestor.urlSession.isRegistered(requestor.cpmsObserver!))
    XCTAssert(requestor.urlSession.isRegistered(requestor.oauthObserver!))
    XCTAssertEqual(requestor.cpmsObserver!.applicationID, "AID")
  }

  func testSendRequestFailsIfNotInitialized() {
    let requestor = OAuthRequestor()
    var failed = false
    requestor.sendRequest(urlString: "url", success: { (_: HTTPURLResponse, _: Data) in
      XCTFail()
    }, failure: { (_: String?, _: String?, _: NSError?) in
      failed = true
    })
    XCTAssert(failed)
  }

  // Can't test the sending of the request because there
  // doesn't seem to be any way to mock SAPURLSession.
}
