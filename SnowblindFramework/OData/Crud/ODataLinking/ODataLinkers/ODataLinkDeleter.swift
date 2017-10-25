//
//  ODataLinkDeleter.swift
//  SAPMDC
//
//  Created by Ouimet, Frederic on 5/21/17.
//  Copyright © 2017 SAP. All rights reserved.
//

import Foundation
import SAPOData
import SAPOfflineOData
@objc(ODataLinkDeleter)

public class ODataLinkDeleter: ODataLinker {

  init(sourceEntitySetName: String, linkingParams: [String: String]) throws {
    try super.init(sourceEntitySetName: sourceEntitySetName, linkingParams: linkingParams, operation: .delete)
  }

  public func execute(_ sourceEntity: EntityValue, offlineDataService: DataService<OfflineODataProvider>?, changeSetManager: ChangeSetManager) throws {
    try super.execute(sourceEntity, dataService: offlineDataService, changeSetManager: changeSetManager)
    try performLinking(sourceEntity, dataService: offlineDataService)
  }

  private func performLinking(_ sourceEntity: EntityValue, dataService: DataService<OfflineODataProvider>?) throws {
    for target in targets {
      let scenario = LinkingScenario(navigationProperty: navigationProperty, sourceEntity: sourceEntity, targetEntity: target, operation: operation, dataService: dataService)
      _ = try scenario.execute()

    }
  }
}
