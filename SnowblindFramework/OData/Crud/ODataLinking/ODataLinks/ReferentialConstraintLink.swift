//
//  ReferentialConstraintLink.swift
//  SAPMDC
//
//  Created by Ouimet, Frederic on 5/23/17.
//  Copyright © 2017 SAP. All rights reserved.
//

import Foundation
import SAPOData
import SAPOfflineOData

public class ReferentialConstraintLink {

  var dependantNavigationProperty: Property!
  var dependantEntity: EntityValue!
  var principalEntity: EntityValue!
  let operation: ODataCrudOperation
  var forcesCreateRelatedEntity = false

  init(dependantNavigationProperty: Property, dependantEntity: EntityValue, principalEntity: EntityValue, operation: ODataCrudOperation) {
    self.dependantNavigationProperty = dependantNavigationProperty
    self.dependantEntity = dependantEntity
    self.principalEntity = principalEntity
    self.operation = operation
  }

  public func execute () throws {
    switch operation {
    case .create, .update:
      try createLink()
    case .delete:
      try deleteLink()
    }
  }

  private func createLink() throws {
    print("Creating referential constraint link between dependant \(dependantEntity.entityType.name) and principal \(principalEntity.entityType.name) " +
      "using navigation property from dependant: \(dependantNavigationProperty.name)")
    let principalPropertyNamesByDependantPropertyNames = dependantNavigationProperty.referentialConstraints

    for dependantPropertyName in principalPropertyNamesByDependantPropertyNames.keys() {

      let principalPropertyName = principalPropertyNamesByDependantPropertyNames.value(forKey: dependantPropertyName)!
      let principalProp = principalEntity.entityType.property(withName: principalPropertyName)
      // If the referential constraint property exists on
      // the principal, copy it to the dependant. We allow constraints
      // to be missing on locals, although they shouldn't be missing on
      // entities from the backend.
      if let principalPropValue = principalProp.optionalValue(from: principalEntity) {
        let dependantProp = dependantEntity.entityType.property(withName: dependantPropertyName)
        dependantProp.setDataValue(in: dependantEntity, to: try DataServiceUtils.convert(value: principalPropValue as AnyObject, type: dependantProp.dataType.code))
      }
    }
  }

  private func deleteLink() throws {
    print("Deleting link between dependant \(dependantEntity.entityType.name) and principal \(principalEntity.entityType.name) " +
      " on dependant navigation property: \(dependantNavigationProperty.name)")
    let principalPropertyNamesByDependantPropertyNames = dependantNavigationProperty.referentialConstraints

    for dependantPropertyName in principalPropertyNamesByDependantPropertyNames.keys() {
      let dependantProp = dependantEntity.entityType.property(withName: dependantPropertyName)
      if dependantEntity.entityType.keyProperties.contains(where: { $0.name == dependantProp.name }) {
        print("Cannot delete a required property")
        throw ODataErrors.genericError("Cannot delete a required property")
      }
      dependantProp.setDataValue(in: dependantEntity, to: nil)
    }
  }
}
