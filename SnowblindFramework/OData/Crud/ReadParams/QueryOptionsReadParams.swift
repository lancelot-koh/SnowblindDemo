//
//  QueryOptionsReadParams.swift
//  SAPMDC
//
//  Created by Ouimet, Frederic on 5/19/17.
//  Copyright © 2017 SAP. All rights reserved.
//

import Foundation
@objc(QueryOptionsReadParams)

public class QueryOptionsReadParams: ReadParams {
  private(set) var queryOptions: String!

  init(entitySetName: String, queryOptions: String) {
    super.init(entitySetName: entitySetName)
    self.queryOptions = queryOptions
  }
}
