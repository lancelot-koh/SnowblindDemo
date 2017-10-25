//
//  ODataDeleter.swift
//  SAPMDC
//
//  Created by Ouimet, Frederic on 5/19/17.
//  Copyright © 2017 SAP. All rights reserved.
//

import Foundation
@objc(ODataDeleter)

public class ODataDeleter: BaseODataCruder {

  private var targetReadParams: ReadParams!

  override init(_ params: NSDictionary) throws {
    try super.init(params)
    try setTargetReadParams()
  }

  private func setTargetReadParams() throws {
    targetReadParams = try ReadService.ReadParamsFactory.createReadParams(service)
  }

  public func execute(offlineService: Any?, changeSetManager: Any?) throws -> Any {
    try setOfflineService(offlineService: offlineService)
    try setChangeSetManager(changeSetManager: changeSetManager)

    let entityToDelete = try ReadService.entityFromParams(targetReadParams, dataService: offlineDataService, changeSetManager: self.changeSetManager)

    print("Deleting entity of type \(entityToDelete.entityType.name)")
    try self.changeSetManager.deleteEntity(entityToDelete, headers: self.headers)

    return entityToDelete.toJson(getDataContext()) as AnyObject
  }
}
