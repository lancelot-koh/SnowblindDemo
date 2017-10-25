//
//  ODataLinker.swift
//  SAPMDC
//
//  Created by Ouimet, Frederic on 5/19/17.
//  Copyright © 2017 SAP. All rights reserved.
//

import Foundation
import SAPOData
import SAPOfflineOData
@objc(ODataLinker)
public class ODataLinker: NSObject {

  let PROPERTYKEY = "property"

  private var navigationPropertyName: String!
  private(set) var navigationProperty: Property!
  private var sourceEntitySetName: String!
  var targetReadParams: ReadParams!
  var targets: [EntityValue]!
  var operation: ODataCrudOperation!
  private var linkingScenarios: [LinkingScenario]!

  init(sourceEntitySetName: String, linkingParams: [String: String], operation: ODataCrudOperation) throws {
    super.init()
    self.sourceEntitySetName = sourceEntitySetName
    self.operation = operation
    try setNavigationPropertyName(linkingParams)
    try setTargetReadParams(linkingParams)
  }

  private func setNavigationPropertyName(_ linkingParams: [String: String]) throws {
    if let navigationPropertyName = linkingParams[PROPERTYKEY], !navigationPropertyName.isEmpty {
      self.navigationPropertyName = navigationPropertyName
    } else {
      throw ODataErrors.genericError("\(CrudParamsHelper.MALFORMEDPARAM) could not find \(PROPERTYKEY) value in linking instructions")
    }
  }

  private func setTargetReadParams(_ linkingParams: [String: String]) throws {
    try self.targetReadParams = ReadService.ReadParamsFactory.createReadParams(linkingParams)
  }

  public func execute(_ sourceEntity: EntityValue, dataService: DataService<OfflineODataProvider>?, changeSetManager: ChangeSetManager) throws {
    guard let dataService = dataService else {
      throw ODataErrors.genericError("offline dataService is nil")
    }
    try setNavigationProperty(dataService: dataService)
    try acquireTargets(dataService: dataService, changeSetManager: changeSetManager)
  }

  func setNavigationProperty(dataService: DataService<OfflineODataProvider>) throws {
    let entitySet = try dataService.entitySet(withName: sourceEntitySetName)
    navigationProperty = entitySet.entityType.property(withName: navigationPropertyName)
  }

  func acquireTargets(dataService: DataService<OfflineODataProvider>, changeSetManager: ChangeSetManager) throws {
    self.targets = try ReadService.entitiesFromParams(targetReadParams, dataService: dataService, changeSetManager: changeSetManager)
    guard targets.count > 0 else {
      throw ODataErrors.genericError("A query for link targets returned zero targets")
    }
  }
}
