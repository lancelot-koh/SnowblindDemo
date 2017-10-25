//
//  MockDataService.swift
//  SAPMDCFramework
//
//  Created by Asche, Christopher on 1/30/17.
//  Copyright © 2017 SAP. All rights reserved.
//

import Foundation
import SAPOData

class MockDataService<DataProvider: OnlineODataProvider>: DataService<DataProvider> {
  override func loadEntity(_ entity: SAPOData.EntityValue, query: SAPOData.DataQuery?) throws {
    // we're good
  }
}
