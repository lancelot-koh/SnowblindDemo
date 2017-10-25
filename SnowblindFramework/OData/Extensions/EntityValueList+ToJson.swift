//
//  EntityValueList+ToJson.swift
//  SAPMDCFramework
//
//  Created by Ouimet, Frederic on 3/27/17.
//  Copyright © 2017 SAP. All rights reserved.
//

import Foundation
import SAPOData

extension EntityValueList {
  func toJson(_ context: DataContext) -> String {
    context.bindOptions = DataContext.sendToClient | DataContext.fullMetadata
    context.versionCode = DataVersion.ODATA_V4
    return (JsonValue.fromEntityList(self, context: context).toString())
  }
}
