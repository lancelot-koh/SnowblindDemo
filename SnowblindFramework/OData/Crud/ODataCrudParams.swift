//
//  ODataCrudParams.swift
//  SAPMDCFramework
//
//  Created by Ouimet, Frederic on 3/29/17.
//  Copyright © 2017 SAP. All rights reserved.
//

import Foundation
@objc(CrudParams)
public class CrudParams: NSObject {

  // Keys from NativeScript side
  static let ENTITYSETNAMEKEY = "entitySet"
  static let READLINKKEY = "readLink"

  let SERVICEKEY = "service"
  let SERVICEURLKEY = "serviceUrl"
  static let MALFORMEDPARAM = "Malformed parameter:"

  private(set) var service: [String: Any]?
  private(set) var serviceUrl: String!
  private(set) var entitySetName: String!
  private(set) var readLink: String?
  private(set) var operation: ODataCrudOperation

  private(set) var readLinkReadParams: ReadLinkReadParams!

  init(_ params: NSDictionary, operation: ODataCrudOperation) throws {
    guard let params = params as? [String: Any] else {
      throw ODataErrors.genericError("\(CrudParams.MALFORMEDPARAM) bad parameter format")
    }

    self.operation = operation
    super.init()
    try setService(params)
    try setServiceUrl(service!)
    try setEntitySetName(service!)
    try setReadLink(service!)
  }

  private func setService(_ params: [String: Any]) throws {
    if let value = params[SERVICEKEY] as? [String: Any] {
      service = value
    } else {
      throw ODataErrors.genericError("\(CrudParams.MALFORMEDPARAM) \(SERVICEKEY)")
    }
  }

  private func setServiceUrl(_ params: [String: Any]) throws {
    if let value = params[SERVICEURLKEY] as? String, !value.isEmpty {
      serviceUrl = value
    } else {
      throw ODataErrors.genericError("\(CrudParams.MALFORMEDPARAM) \(SERVICEURLKEY)")
    }
  }

  private func setEntitySetName(_ params: [String: Any]) throws {
    if let value = params[CrudParams.ENTITYSETNAMEKEY] as? String, !value.isEmpty {
      entitySetName = value
    } else {
      throw ODataErrors.genericError("\(CrudParams.MALFORMEDPARAM) \(CrudParams.ENTITYSETNAMEKEY)")
    }
  }

  private func setReadLink(_ params: [String: Any]) throws {
    guard operation != ODataCrudOperation.create else {
      return
    }
    if let value = params[CrudParams.READLINKKEY] as? String, value.characters.count > 0 {
      readLink = value
    } else {
      throw ODataErrors.genericError("\(operation.rawValue) parameters require readLink. it is nil")
    }
  }

}
