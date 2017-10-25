//
//  ODataUpdater.swift
//  SAPMDC
//
//  Created by Ouimet, Frederic on 5/19/17.
//  Copyright © 2017 SAP. All rights reserved.
//

import Foundation
import SAPOData

@objc(ODataUpdater)

public class ODataUpdater: BaseODataCruder {

  private var targetReadParams: ReadParams!
  private var properties: [String: Any]?
  private var linkCreators: [ODataLinkCreator]?
  private var linkUpdaters: [ODataLinkUpdater]?
  private var linkDeleters: [ODataLinkDeleter]?

  override init(_ params: NSDictionary) throws {
    try super.init(params)
    try setTargetReadParams()
    try setProperties()
    try setLinkCreators()
    try setLinkUpdaters()
    try setLinkDeleters()
  }

  private func setTargetReadParams() throws {
    targetReadParams = try ReadService.ReadParamsFactory.createReadParams(service)
  }

  private func setProperties() throws {
    if let properties = try CrudParamsHelper.getPropertiesFromService(service) {
      self.properties = properties
    }
  }

  private func setLinkCreators() throws {
    self.linkCreators = try CrudParamsHelper.getLinkCreatorsFromParams(params)
  }
  private func setLinkUpdaters() throws {
    self.linkUpdaters = try CrudParamsHelper.getLinkUpdatersFromParams(params)
  }
  private func setLinkDeleters() throws {
    self.linkDeleters = try CrudParamsHelper.getLinkDeletersFromParams(params)
  }

  public func execute(offlineService: Any?, changeSetManager: Any?) throws -> Any {
    try setOfflineService(offlineService: offlineService)
    try setChangeSetManager(changeSetManager: changeSetManager)

    let entityToUpdate = try ReadService.entityFromParams(targetReadParams, dataService: offlineDataService, changeSetManager: self.changeSetManager)
    try entityToUpdate.setProperties(properties)

    try executeLinkers(sourceEntity: entityToUpdate)

    print("Updating entity of type \(entityToUpdate.entityType.name)")
    try self.changeSetManager.updateEntity(entityToUpdate, headers: self.headers)
    return entityToUpdate.toJson(getDataContext()) as AnyObject
  }

  private func executeLinkers(sourceEntity: EntityValue) throws {
    try executeLinkCreators(sourceEntity: sourceEntity)
    try executeLinkUpdaters(sourceEntity: sourceEntity)
    try executeLinkDeleters(sourceEntity: sourceEntity)
  }

  private func executeLinkCreators(sourceEntity: EntityValue) throws {
    if let linkCreators = linkCreators {
      for linkCreator in linkCreators {
        if try linkCreator.execute(sourceEntity, offlineDataService: offlineDataService, changeSetManager: changeSetManager) != nil {
          throw ODataErrors.genericError("There cannot be a mandatory parent in the context of an update")
        }
      }
    }
  }

  private func executeLinkUpdaters(sourceEntity: EntityValue) throws {
    if let linkUpdaters = linkUpdaters {
      for linkUpdater in linkUpdaters {
        if try linkUpdater.execute(sourceEntity, offlineDataService: offlineDataService, changeSetManager: changeSetManager) != nil {
          throw ODataErrors.genericError("There cannot be a mandatory parent in the context of an update")
        }
      }
    }
  }

  private func executeLinkDeleters(sourceEntity: EntityValue) throws {
    if let linkDeleters = linkDeleters {
      for linkDeleter in linkDeleters {
        try linkDeleter.execute(sourceEntity, offlineDataService: offlineDataService, changeSetManager: changeSetManager)
      }
    }
  }
}
