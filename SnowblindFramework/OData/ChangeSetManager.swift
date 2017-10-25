//
//  ChangeSetManager.swift
//  SAPMDCFramework
//
//  Created by Ouimet, Frederic on 4/18/17.
//  Copyright © 2017 SAP. All rights reserved.
//

import Foundation
import SAPOData
import SAPOfflineOData

public class ChangeSetManager {

  private var pendingChangeSet: ChangeSet?
  private var pendingEntityReadLinkOrdinalSuffix = 0
  private var service: DataService<OfflineODataProvider>?
  static let UNPROCESSEDPREFIX = "pending_"

  // Terminology: a pending entity is an entity that has been instantiated and added to a pending changeSet.
  // An entity does not "really" exist until it has been added to the offline store, i.e. until the changeSet has been
  // processed with processBatch().  It's only at that point that the entity is given a "real" readLink.
  // Until that point, we set it with a temporary, ordinal readLink, in order to be able to access it within the changeSet

  init(_ service: DataService<OfflineODataProvider>?) {
    self.service = service
    self.pendingEntityReadLinkOrdinalSuffix = 0
    self.pendingChangeSet = nil
  }

  func beginChangeSet() throws {
    guard pendingChangeSet == nil else {
      throw ODataErrors.genericError("ChangeSet set already exists")
    }
    pendingChangeSet = ChangeSet()
    pendingEntityReadLinkOrdinalSuffix = 0
  }

  func cancelChangeSet() {
    pendingChangeSet = nil
    pendingEntityReadLinkOrdinalSuffix = 0
  }

  func commitChangeSet() throws {

    guard let changeSet = pendingChangeSet else {
      throw ODataErrors.genericError("Cannot commit empty changeSet")
    }

    defer {
      pendingChangeSet = nil
      pendingEntityReadLinkOrdinalSuffix = 0
    }
    try processBatchWithChangeSet(changeSet)
  }

  func createEntity(_ entity: EntityValue, headers: HTTPHeaders) throws {
    if let changeSet = pendingChangeSet {
      pendingEntityReadLinkOrdinalSuffix += 1
      entity.readLink = ChangeSetManager.UNPROCESSEDPREFIX + "\(pendingEntityReadLinkOrdinalSuffix)"
      changeSet.createEntity(entity, headers: headers)
    } else {
      let changeSet = ChangeSet()
      changeSet.createEntity(entity, headers: headers)
      try processBatchWithChangeSet(changeSet)
    }
  }

  func createRelatedEntity(_ entity: EntityValue, in parentEntity: EntityValue,
                           property parentNavProp: Property, headers: HTTPHeaders) throws {
    if let changeSet = pendingChangeSet {
      pendingEntityReadLinkOrdinalSuffix += 1
      entity.readLink = ChangeSetManager.UNPROCESSEDPREFIX + "\(pendingEntityReadLinkOrdinalSuffix)"
      changeSet.createRelatedEntity(entity, in: parentEntity, property: parentNavProp, headers: headers)
    } else {
      let changeSet = ChangeSet()
      changeSet.createRelatedEntity(entity, in: parentEntity, property: parentNavProp, headers: headers)
      try processBatchWithChangeSet(changeSet)
    }
  }

  func updateEntity(_ entity: EntityValue, headers: HTTPHeaders) throws {
    if let changeSet = pendingChangeSet {
      changeSet.updateEntity(entity, headers: headers)
    } else {
      let changeSet = ChangeSet()
      changeSet.updateEntity(entity, headers: headers)
      try processBatchWithChangeSet(changeSet)
    }
  }

  func deleteEntity(_ entity: EntityValue, headers: HTTPHeaders) throws {
    if let changeSet = pendingChangeSet {
      changeSet.deleteEntity(entity, headers: headers)
    } else {
      let changeSet = ChangeSet()
      changeSet.deleteEntity(entity, headers: headers)
      try processBatchWithChangeSet(changeSet)
    }
  }

  private func processBatchWithChangeSet(_ changeSet: ChangeSet) throws {

    let requestBatch = RequestBatch()
    requestBatch.addChanges(changeSet)
    try service?.processBatch(requestBatch)

    if let error = changeSet.error {
      throw DataServiceUtils.getError(errorCode: error.status, dataServiceError: error)
    }
  }

  func pendingEntityFromPendingChangeSet(withReadLink readLink: String) -> EntityValue? {
    guard readLink.hasPrefix(ChangeSetManager.UNPROCESSEDPREFIX) else {
      return nil
    }
    return pendingChangeSet?.entityWithReadLink(readLink)
  }

  static func isPending(_ entity: EntityValue) -> Bool {
    guard let readLink = entity.readLink else {
      return true
    }
    return readLink.hasPrefix(ChangeSetManager.UNPROCESSEDPREFIX) ? true : false
  }

}
