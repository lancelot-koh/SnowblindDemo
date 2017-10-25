//
//  ReadParams.swift
//  SAPMDC
//
//  Created by Ouimet, Frederic on 5/19/17.
//  Copyright © 2017 SAP. All rights reserved.
//

import Foundation
@objc(ReadParams)

public class ReadParams: NSObject {

  private(set) var entitySetName: String!

  init(entitySetName: String) {
    self.entitySetName = entitySetName
  }

  // This is overriden in sub classes
  public func isTargetCreatedInSameChangeSet() -> Bool {
    return false
  }
}
