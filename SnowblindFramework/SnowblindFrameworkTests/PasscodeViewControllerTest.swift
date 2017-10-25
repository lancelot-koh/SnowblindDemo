//
//  PasscodeViewControllerTest.swift
//  SAPMDCFramework
//
//  Created by Sauve, Mathieu on 2017-04-20.
//  Copyright © 2017 SAP. All rights reserved.
//

import XCTest
import SAPMDC

class PasscodeViewControllerTest: XCTestCase {

  private var passcodePolicyParams: [String : Any] = [:]
  private var connectionSettingsParams: [String: Any] = [:]
  private var params: [String : Any] = [:]
  private var passcodeViewController: PasscodeViewController!

  override func setUp() {
    super.setUp()
    passcodePolicyParams = [
      "IsDigitsOnly": false,
      "MinLength": 4,
      "HasLower": true,
      "HasUpper": true,
      "HasSpecial": true,
      "AllowsTouchID": true,
      "RetryLimit": 6,
      "HasDigit": true,
      "MinUniquechars": 1
    ]
    connectionSettingsParams = [
      "AppId": "com.sap.sam.swa",
      "ClientId": "53f54c68-706c-4fdc-a58a-7f8af0821d75",
      "SapCloudPlatformEndpoint": "https://mobile-w70145a18.int.sap.hana.ondemand.com",
      "AuthorizationEndpointUrl": "https://oauthasservices-w70145a18.int.sap.hana.ondemand.com/oauth2/api/v1/authorize",
      "RedirectUrl": "https://oauthasservices-w70145a18.int.sap.hana.ondemand.com",
      "TokenUrl": "https://oauthasservices-w70145a18.int.sap.hana.ondemand.com/oauth2/api/v1/token"
    ]
    params = [
      "ApplicationDisplayName": "SAP Asset Manager",
      "ConnectionSettings": connectionSettingsParams,
      "PasscodePolicySettings": passcodePolicyParams
    ]

    passcodeViewController = PasscodeViewController()
    // This method should be private
    // passcodeViewController.storePasscodePolicy(self.params as NSDictionary)
    AppConfig.sharedInstance.passcodePolicySettings = passcodePolicyParams

  }

  override func tearDown() {
    super.tearDown()
    passcodePolicyParams = [:]
    params = [:]
  }

  func testPasscodePolicy() {
    let passcodePolicy = passcodeViewController.passcodePolicy()
    XCTAssertNotNil(passcodePolicy, "passcodePolicy should never be nil")
  }
}
