//
//  BindingLink.swift
//  SAPMDC
//
//  Created by Ouimet, Frederic on 5/23/17.
//  Copyright © 2017 SAP. All rights reserved.
//

import Foundation
import SAPOData
import SAPOfflineOData

public class BindingLink {

  let sourceNavigationProperty: Property!
  let sourceEntity: EntityValue
  let targetEntity: EntityValue
  let operation: ODataCrudOperation

  init(sourceNavigationProperty: Property, sourceEntity: EntityValue, targetEntity: EntityValue, operation: ODataCrudOperation) {
    self.sourceNavigationProperty = sourceNavigationProperty
    self.sourceEntity = sourceEntity
    self.targetEntity = targetEntity
    self.operation = operation
  }

  public func execute () throws {

    guard operation != .delete else {
      return  // Bind deletion is not supported by the OData SDK. Only referential constraints is currently used for deletion
    }

    // Update and create currently do the same thing
    if sourceNavigationProperty.type.isList {
      throw ODataErrors.genericError("Cannot link from \(sourceEntity.entityType.name) using property \(sourceNavigationProperty.name). many-to-one linking is not possible.")
    } else {
      print("Creating binding link between sourceEntity \(sourceEntity.entityType.name) and targetEntity \(targetEntity.entityType.name) " +
        "using navigation property from sourceEntity: \(sourceNavigationProperty.name)")
      sourceEntity.bindEntity(targetEntity, to: sourceNavigationProperty)
    }
  }
}
