//
//  ChangeSet+EntityWithReadLink.swift
//  SAPMDCFramework
//
//  Created by Ouimet, Frederic on 4/14/17.
//  Copyright © 2017 SAP. All rights reserved.
//

import Foundation
import SAPOData

extension ChangeSet {
  func entityWithReadLink(_ readLink: String) -> EntityValue? {
    for i in stride(from: 0, to: self.size, by: 1) {
      if self.isEntity(at:i) {
        let entity = self.entity(at:i)
        if entity.readLink == readLink {
          return entity
        }
      }
    }
    return nil
  }
}
