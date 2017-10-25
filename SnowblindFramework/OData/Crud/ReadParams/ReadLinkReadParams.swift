//
//  ReadLinkReadParams.swift
//  SAPMDC
//
//  Created by Ouimet, Frederic on 5/19/17.
//  Copyright © 2017 SAP. All rights reserved.
//

import Foundation
@objc(ReadLinkReadParams)

public class ReadLinkReadParams: ReadParams {
  private(set) var readLink: String!

  init(entitySetName: String, readLink: String) {
    super.init(entitySetName: entitySetName)
    self.readLink = readLink
  }

  public override func isTargetCreatedInSameChangeSet() -> Bool {
    return readLink.hasPrefix(ChangeSetManager.UNPROCESSEDPREFIX)
  }
}
