//
//  AppConfig.swift
//  SAPMDCFramework
//
//  Created by Rafay, Muhammad on 2/23/17.
//  Copyright © 2017 SAP. All rights reserved.
//

import Foundation
import SAPFoundation

class AppConfig {
  static let sharedInstance = AppConfig()
  private init() {
    print("Initializing App Config")
  }
  var oauth2Token: String!
  var passCode: String!
  var passcodeSource: Int = 0
  // Onboarding flag is always false unless we go through welcome screen
  var isOnboarding = false
  var data = [String: Any]()
  var passcodePolicySettings = [String: Any]()
  var encryptDatabase: Bool = true
}
