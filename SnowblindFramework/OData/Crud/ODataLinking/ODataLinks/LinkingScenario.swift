//
//  LinkingScenario.swift
//  SAPMDC
//
//  Created by Ouimet, Frederic on 5/23/17.
//  Copyright © 2017 SAP. All rights reserved.
//

import Foundation
import SAPOData
import SAPOfflineOData

//swiftlint:disable large_tuple
class LinkingScenario {
  private let navigationProperty: Property
  private let sourceEntity: EntityValue
  private let targetEntity: EntityValue
  private let operation: ODataCrudOperation
  private let dataService: DataService<OfflineODataProvider>?
  private let canUseCreateRelatedEntity: Bool

  init(navigationProperty: Property, sourceEntity: EntityValue, targetEntity: EntityValue, operation: ODataCrudOperation, dataService: DataService<OfflineODataProvider>?, canUseCreateRelatedEntity: Bool = false) {
    self.navigationProperty = navigationProperty
    self.sourceEntity = sourceEntity
    self.targetEntity = targetEntity
    self.operation = operation
    self.dataService = dataService
    self.canUseCreateRelatedEntity = canUseCreateRelatedEntity
  }

  private func canCreateRelatedEntity() throws -> Bool {
    // The canUseCreateRelatedEntity flag is true unless createRelatedEntity was already
    // used to link to the entity. TODO: Refactor to make this more clear.
    return try canUseCreateRelatedEntity
      // It must be a create operation
      && operation == .create
      // SNOWBLIND-4807: The navigation property being posted to must be a collection.
      // Violating this would result in an Invalid Resource Path error.
      // See "How to Create Relationships With Offline OData"
      // in the "POST through a navigation property" section.
      && navigationProperty.partnerPropertyFromEntity(entity: targetEntity).type.isList
  }

  public func execute() throws -> ReferentialConstraintLink? {
    var linkToParentEntity: ReferentialConstraintLink?
    var shouldDoBinding = true

    if let refConstrs = try analyseReferentialConstraintScenario() {
      if refConstrs.forcesCreateRelatedEntity {
        linkToParentEntity = refConstrs
        // Do not bind an entity which will be used as a related parent
        shouldDoBinding = false
        print("Using createRelatedEntity, so skipping binding link between \(self.sourceEntity.entityType.name) and \(self.targetEntity.entityType.name)")
      } else {
        try refConstrs.execute()
      }
    }

    if shouldDoBinding {
      if let binding = try analyseBindingScenario() {
        try binding.execute()
      }
    }
    return linkToParentEntity
  }

  private func analyseBindingScenario() throws -> BindingLink? {

    guard operation != .delete else {
      return nil // Bind deletion is not supported by the OData SDK. Only referential constraints is currently used for deletion
    }

    if bothPending() {
      throw ODataErrors.genericError("Cannot link between two pending entities, i.e. two entities that have not yet been added to the offline store.")
    }

    if try canBindFromSourceToTarget() {
      return BindingLink(sourceNavigationProperty: navigationProperty, sourceEntity: sourceEntity, targetEntity: targetEntity, operation: operation)
    } else if try canBindFromTargetToSource() {
      return BindingLink(sourceNavigationProperty: try navigationProperty.partnerPropertyFromEntity(entity: targetEntity),
                         sourceEntity: targetEntity, targetEntity: sourceEntity, operation: operation)
    }
    return nil
  }

  private func analyseReferentialConstraintScenario() throws -> ReferentialConstraintLink? {

    guard let arranged = try arrange(entity1: sourceEntity, entity1NavProp: navigationProperty, entity2: targetEntity) else {
      return nil
    }

    let refLink = ReferentialConstraintLink(dependantNavigationProperty: arranged.dependantNavProp,
                                            dependantEntity: arranged.dependant, principalEntity: arranged.principal, operation: operation)

    if try !canCreateRelatedEntity() {
      return refLink
    }
    // The only way to link a many-to-many relationship or two
    // entities which are in an un-processed changeSet is to use createRelatedEntity.
    // We must also use createRelatedEntity if the principal is not known to the backend (it is local).
    // This is required to support merging transactions for child items
    // created outside of the parent's changeset.
    if try bothPending() || isRelationshipManyToMany() || !arranged.principal.isKnownToBackend() {
      print("Link between dependant \(arranged.dependant.entityType.name) and principal \(arranged.principal.entityType.name) " +
        "using navigation property from dependant: \(arranged.dependantNavProp.name) cannot be done using referential constraints, " +
        "and entities are either both pending, or have a strict relationship. \(arranged.principal.entityType.name) " +
        "should be used as a relatedParent for createRelatedEntity")

      // Flag this link so its execute() function does not get invoked, but it's returned to the calling class for createRelatedEntity(),
      // instead
      refLink.forcesCreateRelatedEntity = true
    }
    return refLink
  }

  // This comment is for the TWO next functions
  // For binding links, there are two conditions which make linking from one entity ("entity1") to another entity ("entity2") possible:
  // 1. entity2 is not pending
  // 2. In the Association, the entity1's navigation property is not of type "list", as "list" nav props cannot be the source of a binding link.
  private func canBindFromSourceToTarget() throws -> Bool {
    guard !ChangeSetManager.isPending(targetEntity) else {
      return false
    }
    return try canBindFromNavProp(navigationProperty)
  }

  private func canBindFromTargetToSource() throws -> Bool {
    guard !ChangeSetManager.isPending(sourceEntity) else {
      return false
    }
    return try canBindFromNavProp(navigationProperty.partnerPropertyFromEntity(entity: targetEntity))
  }

  // Verifies if a binding link can start from this navigation property.
  // To do so, check if:
  // 1. If the association has referential constraints, check
  //    that this property is the dependant, by checking if the
  //    referential constraints are located on it. A dependant cannot be of type
  //    "list", which makes the binding from it possible
  // 2. If no referential constraints in this association,
  //    check if the nav prop is of type "isList". If it is NOT,
  //    then a binding link can start from it
  private func canBindFromNavProp(_ navProp: Property) throws -> Bool {
    if try associationHasReferentialConstraints() {
      return isDependant(navProp)
    } else {
      return !navProp.type.isList
    }
  }

  // Verifies if this association has referential constrains by checking
  // both properties of the association
  private func associationHasReferentialConstraints() throws -> Bool {
    return try isDependant(navigationProperty) || isDependant(navigationProperty.partnerPropertyFromEntity(entity: targetEntity))
  }

  // The referential constraints are always located on the dependant, hence
  // if this property has them, it is the dependant
  private func isDependant(_ navProp: Property) -> Bool {
    return navProp.referentialConstraints.size != 0
  }

  // Returns true if both source AND target are part of an unprocessed changeSet
  private func bothPending() -> Bool {
    return ChangeSetManager.isPending(targetEntity) && ChangeSetManager.isPending(sourceEntity)
  }

  // Verifies if the cardinality of the association of this nav prop is of type
  // "many-to-many" by checking of both nav props from this association are of
  // type "isList"
  private func isRelationshipManyToMany() throws -> Bool {
    return try navigationProperty.type.isList
      && navigationProperty.partnerPropertyFromEntity(entity: targetEntity).type.isList
  }

  // Determine which of the entities to be linked is the dependant
  private func arrange(entity1: EntityValue, entity1NavProp: Property,
                       entity2: EntityValue) throws -> (dependant: EntityValue, dependantNavProp: Property, principal: EntityValue)? {
    guard try associationHasReferentialConstraints() else {
      return nil
    }
    if !isDependant(entity1NavProp) {
      return try (dependant: entity2, dependantNavProp: entity1NavProp.partnerPropertyFromEntity(entity: entity2), principal: entity1)
    } else {
      return (dependant: entity1, dependantNavProp: entity1NavProp, principal: entity2)
    }
  }
}
