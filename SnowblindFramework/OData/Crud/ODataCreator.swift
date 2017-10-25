//
//  ODataCreator.swift
//  SAPMDC
//
//  Created by Ouimet, Frederic on 5/19/17.
//  Copyright © 2017 SAP. All rights reserved.
//

import Foundation
import SAPOData
import SAPOfflineOData

@objc(ODataCreator)

public class ODataCreator: BaseODataCruder {

  private var properties: [String: Any]!
  private var entitySetName: String!
  private var linkCreators: [ODataLinkCreator]?

  override init(_ params: NSDictionary) throws {
    try super.init(params)
    try setEntitySetName()
    try setProperties()
    try setLinkCreators()
  }

  private func setEntitySetName() throws {
    self.entitySetName = try CrudParamsHelper.getEntitySetNameFromService(service)
  }

  private func setProperties() throws {
    if let properties = try CrudParamsHelper.getPropertiesFromService(service) {
      self.properties = properties
    } else {
      throw ODataErrors.genericError("\(CrudParamsHelper.MALFORMEDPARAM). Properties cannot be empty for operation create.")
    }
  }

  private func setLinkCreators() throws {
    self.linkCreators = try CrudParamsHelper.getLinkCreatorsFromParams(params)
  }

  // At create time, some links may have characteristics which forces them to be used with createRelatedEntity:
  // 1. the link's target has been created in the same changeSet, i.e. it has a pending_* readLink
  // 2. the link's target cannot be linked using referential constraints (i.e. the involved properties are not set
  //    because it has not gone through the backend, yet) AND it is in a strict relationship with the current entity
  // The goal is to analyse which link qualifies, and to throw an error if more than one do, as createRelatedEntity can only be used once
  public func execute(offlineService: Any?, changeSetManager: Any?) throws -> Any {
    try setOfflineService(offlineService: offlineService)
    try setChangeSetManager(changeSetManager: changeSetManager)

    let entityToCreate = try initNewEntity()
    try entityToCreate.setProperties(properties)

    // MandatoryParentLinker will be returned by a link which does not have its principal's referential constraints set, but is in a strict relationship
    // this one needs to be used with createRelatedEntity
    if let linkToParentEntity = try executeLinkCreators(entityToCreate) {
      try createUsingCreateRelatedEntity(entityToCreate, linkToParentEntity: linkToParentEntity)
    } else {
      print("Creating entity \(entityToCreate.entityType.name)")
      try self.changeSetManager.createEntity(entityToCreate, headers: self.headers)
    }
    return entityToCreate.toJson(getDataContext()) as AnyObject
  }

  private func createUsingCreateRelatedEntity(_ entityToCreate: EntityValue, linkToParentEntity: ReferentialConstraintLink) throws {
    let relatedParent = linkToParentEntity.principalEntity!
    let navigationPropertyFromRelatedParent = try linkToParentEntity.dependantNavigationProperty.partnerPropertyFromEntity(entity: relatedParent)

    print("Creating entity \(entityToCreate.entityType.name) using createRelatedEntity with navigation property: \(navigationPropertyFromRelatedParent.type.name) " +
      "from related parent of type \(relatedParent.entityType.name)")

    try self.changeSetManager.createRelatedEntity(entityToCreate, in: relatedParent,
                                                  property: navigationPropertyFromRelatedParent, headers: self.headers)
  }

  private func initNewEntity() throws -> EntityValue {
    guard let entitySet: EntitySet = try self.offlineDataService?.entitySet(withName: entitySetName) else {
      throw ODataErrors.genericError("Create entity failed: entity set \(entitySetName) does not exist in service")
    }
    let newEntity = EntityValue.ofType(entitySet.entityType)
    return newEntity
  }

  private func executeLinkCreators(_ sourceEntity: EntityValue) throws -> ReferentialConstraintLink? {
    var linkToParentEntity: ReferentialConstraintLink?

    if let linkCreators = self.linkCreators {
      for linkCreator in linkCreators {
        // Can only use createRelatedEntity to create the parent once.
        let canUseCreateRelatedEntity = linkToParentEntity == nil
        if let link = try linkCreator.execute(sourceEntity, offlineDataService: offlineDataService, changeSetManager: changeSetManager, canUseCreateRelatedEntity: canUseCreateRelatedEntity) {
          // Make sure that no more than one linker returns a link which requires to be a relatedParent
          if linkToParentEntity != nil {
            throw ODataErrors.genericError("Two links forced the usage of createRelatedEntity, which is not possible")
          } else {
            linkToParentEntity = link
          }
        }
      }
    }
    return linkToParentEntity
  }
}
