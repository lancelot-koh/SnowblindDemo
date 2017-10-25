//
//  Property+PartnerPropertyFromEntity.swift
//  SAPMDC
//
//  Created by Ouimet, Frederic on 5/24/17.
//  Copyright © 2017 SAP. All rights reserved.
//

import Foundation
import SAPOData

extension Property {

  func partnerPropertyFromEntity(entity: EntityValue) throws -> Property {
    guard let odataAssociationPartnerPropName = self.partnerPath else {
      throw ODataErrors.genericError("Property with name \(self.name) does not participate in any OData Association. Cannot return partnerPath.")
    }
    return entity.entityType.property(withName: odataAssociationPartnerPropName)
  }
}
