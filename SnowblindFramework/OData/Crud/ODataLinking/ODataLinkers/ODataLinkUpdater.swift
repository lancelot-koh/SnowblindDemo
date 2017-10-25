//
//  ODataLinkUpdater.swift
//  SAPMDC
//
//  Created by Ouimet, Frederic on 5/21/17.
//  Copyright © 2017 SAP. All rights reserved.
//

import Foundation
import SAPOData
import SAPOfflineOData
@objc(ODataLinkUpdater)

// The behavior of LinkUpdater is currently the same as LinkCreator
// Currently, the backend does not support $links. As a result, we use a mix of binding and referential constraints for the
// linking, which has for consequence that link creation and update are currently interchangeable. If $links get supported,
// we might update the app, and those will not be interchangeable anymore, breaking metadata that uses creates to do updates.
// Keeping updates provides backward compatibility.

public class ODataLinkUpdater: ODataLinkCreator {
  init(sourceEntitySetName: String, linkingParams: [String: String]) throws {
    try super.init(sourceEntitySetName: sourceEntitySetName, linkingParams: linkingParams, operation: .update)
  }
}
