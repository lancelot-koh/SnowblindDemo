//
//  EntityValue+ToJson.swift
//  SAPMDCFramework
//
//  Created by Ouimet, Frederic on 4/4/17.
//  Copyright © 2017 SAP. All rights reserved.
//

import Foundation
import SAPOData

extension EntityValue {
  func toJson(_ context: DataContext) -> String? {
    context.bindOptions = DataContext.sendToClient | DataContext.fullMetadata
    context.versionCode = DataVersion.ODATA_V4
    return (JsonValue.fromEntityValue(self, context: context)?.toString())
  }
}
