//
//  BaseODataCruder.swift
//  SAPMDC
//
//  Created by Ouimet, Frederic on 5/19/17.
//  Copyright © 2017 SAP. All rights reserved.
//

import Foundation
import SAPOData
import SAPOfflineOData
@objc(BaseODataCruder)

public class BaseODataCruder: NSObject {

  private(set) var service: [String: Any]!
  private(set) var params: [String: Any]!
  private(set) var headers: HTTPHeaders!
  private(set) var serviceUrl: String!
  private(set) var offlineDataService: DataService<OfflineODataProvider>!
  private(set) var changeSetManager: ChangeSetManager!

  init(_ params: NSDictionary) throws {
    super.init()
    guard let params = params as? [String: Any] else {
      throw ODataErrors.genericError("\(CrudParamsHelper.MALFORMEDPARAM) bad parameter format")
    }
    self.params = params
    try self.setService()
    try self.setServiceUrl()
    self.setHeaders()
  }

  private func setService() throws {
    self.service = try CrudParamsHelper.getServiceFromParams(params)
  }

  private func setServiceUrl() throws {
    serviceUrl = try CrudParamsHelper.getServiceUrlFromService(service)
  }

  private func setHeaders() {
    self.headers = getHttpHeaders(headers: CrudParamsHelper.getHeadersFromParams(params))
  }

  // TODO: Some objects do not satisfy @objc, using Any? for now, possible refactoring
  func setOfflineService(offlineService: Any?) throws {
    guard let offlineService = offlineService as? DataService<OfflineODataProvider> else {
      throw ODataErrors.genericError("Wrong parameter in BaseODataCruder.initialize. Expected DataService<OfflineODataProvider>")
    }
    self.offlineDataService = offlineService
  }

  // TODO: Some objects do not satisfy @objc, using Any? for now, possible refactoring
  func setChangeSetManager(changeSetManager: Any?) throws {
    guard let changeSetManager = changeSetManager as? ChangeSetManager else {
      throw ODataErrors.genericError("Wrong parameter in BaseODataCruder.initialize. Expected ChangeSetManager")
    }
    self.changeSetManager = changeSetManager
  }

  // Headers are passed on to the odata request and can be parsed by the service
  // There are also some special headers that get parsed by the offline service, e.g. Nonmergable
  private func getHttpHeaders(headers: NSDictionary?) -> SAPOData.HTTPHeaders {
    let httpHeader = SAPOData.HTTPHeaders()
    guard let unwrappedHeaders = headers else {
      return httpHeader
    }
    for (key, value) in unwrappedHeaders {
      if let keyString = key as? String, let valueString = value as? String {
        httpHeader.setHeader(withName: keyString, value: valueString)
      }
    }
    return httpHeader
  }
  func getDataContext() -> DataContext {
    return DataContext(csdl: (offlineDataService.metadata))
  }
}
