//
//  ODataLinkCreator.swift
//  SAPMDC
//
//  Created by Ouimet, Frederic on 5/21/17.
//  Copyright © 2017 SAP. All rights reserved.
//

import Foundation
import SAPOData
import SAPOfflineOData
@objc(ODataLinkCreator)

public class ODataLinkCreator: ODataLinker {

  override init(sourceEntitySetName: String, linkingParams: [String: String], operation: ODataCrudOperation = .create) throws {
    try super.init(sourceEntitySetName: sourceEntitySetName, linkingParams: linkingParams, operation: operation)
  }

  public func execute(_ sourceEntity: EntityValue, offlineDataService: DataService<OfflineODataProvider>?,
                      changeSetManager: ChangeSetManager, canUseCreateRelatedEntity: Bool = false) throws -> ReferentialConstraintLink? {
    try super.execute(sourceEntity, dataService: offlineDataService, changeSetManager: changeSetManager)
    return try performLinking(sourceEntity, dataService: offlineDataService, canUseCreateRelatedEntity: canUseCreateRelatedEntity)
  }

  private func performLinking(_ sourceEntity: EntityValue, dataService: DataService<OfflineODataProvider>?, canUseCreateRelatedEntity: Bool) throws -> ReferentialConstraintLink? {
    var linkToParentEntity: ReferentialConstraintLink?
    for target in targets {
      let scenario = LinkingScenario(navigationProperty: navigationProperty, sourceEntity: sourceEntity, targetEntity: target, operation: operation, dataService: dataService, canUseCreateRelatedEntity: canUseCreateRelatedEntity)
      if let link = try scenario.execute() {
        // Make sure that the linker does not have more than one link which requires to be a relatedParent
        if linkToParentEntity != nil {
          throw ODataErrors.genericError("Two links forced the usage of createRelatedEntity, which is not possible")
        } else {
          linkToParentEntity = link
        }
      }
    }
    return linkToParentEntity
  }

  public func isTargetCreatedInSameChangeSet() -> Bool {
    return targetReadParams.isTargetCreatedInSameChangeSet()
  }
}
