//
//  EntityValue+Edit.swift
//  SAPMDCFramework
//
//  Created by Ouimet, Frederic on 3/29/17.
//  Copyright © 2017 SAP. All rights reserved.
//

import Foundation
import SAPOData

extension EntityValue {

  func setProperties(_ properties: [String: Any]?) throws {
    if let properties = properties {
      for (key, value) in properties {
        let prop = self.entityType.property(withName: key)
        self.setDataValue(for: prop, to: try DataServiceUtils.convert(value: value as AnyObject, type: prop.dataType.code))
      }
    }
  }

  func isKnownToBackend() -> Bool {
    return self.readLink != nil && !self.readLink!.contains("lodata_sys_eid")
  }
}
