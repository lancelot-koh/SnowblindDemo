//
//  CrudParamsHelper.swift
//  SAPMDC
//
//  Created by Ouimet, Frederic on 5/19/17.
//  Copyright © 2017 SAP. All rights reserved.
//

import Foundation

public class CrudParamsHelper {
  // Keys from NativeScript side
  private static let SERVICEKEY = "service"
  private static let PROPERTYKEY = "property"
  private static let SERVICEURLKEY = "serviceUrl"
  private static let ENTITYSETNAMEKEY = "entitySet"
  private static let ENTITYPROPERTIESKEY = "properties"
  private static let CREATELINKS = "createLinks"
  private static let UPDATELINKS = "updateLinks"
  private static let DELETELINKS = "deleteLinks"
  private static let HEADERSKEY = "headers"

  public static let MALFORMEDPARAM = "Malformed parameter:"

  public static func getHeadersFromParams(_ params: [String: Any]) -> NSDictionary? { // TODO: why not swift dict?
    if let headers = params[HEADERSKEY] as? NSDictionary {
      return headers
    } else {
      return nil
    }
  }

  public static func getServiceFromParams(_ params: [String: Any]) throws -> [String: Any] {
    if let service = params[SERVICEKEY] as? [String: Any], !service.isEmpty {
      return service
    } else {
      throw ODataErrors.genericError("\(MALFORMEDPARAM) \(SERVICEKEY)")
    }
  }

  public static func getServiceUrlFromService(_ params: [String: Any]) throws -> String {

    if let serviceUrl = params[SERVICEURLKEY] as? String, !serviceUrl.isEmpty {
      return serviceUrl
    } else {
      throw ODataErrors.genericError("\(MALFORMEDPARAM) \(SERVICEURLKEY)")
    }
  }

  public static func getEntitySetNameFromService(_ params: [String: Any]) throws -> String {
    if let entitySet = params[ENTITYSETNAMEKEY] as? String, !entitySet.isEmpty {
      return entitySet
    } else {
      throw ODataErrors.genericError("\(MALFORMEDPARAM) \(ENTITYSETNAMEKEY)")
    }
  }

  public static func getPropertiesFromService(_ params: [String: Any]) throws -> [String: Any]? {
    // TODO: validate that this unwrap validation works as intended
    guard let properties = params[ENTITYPROPERTIESKEY] as? [String: Any]? else {
      throw ODataErrors.genericError("\(MALFORMEDPARAM) \(ENTITYPROPERTIESKEY)")
    }

    if let properties = properties, !properties.isEmpty {
      return properties
    } else {
      return nil
    }
  }

  public static func getLinkCreatorsFromParams(_ params: [String: Any]) throws -> [ODataLinkCreator]? {

    guard let linkCreatorParams = params[CREATELINKS] as? [[String: String]], !linkCreatorParams.isEmpty else {
      return nil
    }

    var linkCreators = [ODataLinkCreator]()
    let service = try self.getServiceFromParams(params)
    let entitySetName = try self.getEntitySetNameFromService(service)

    for linkCreatorParam in linkCreatorParams {
      let linkCreator = try ODataLinkCreator(sourceEntitySetName: entitySetName, linkingParams: linkCreatorParam)
      linkCreators.append(linkCreator)
    }
    return linkCreators
  }

  public static func getLinkUpdatersFromParams(_ params: [String: Any]) throws -> [ODataLinkUpdater]? {

    guard let linkUpdaterParams = params[UPDATELINKS] as? [[String: String]], !linkUpdaterParams.isEmpty else {
      return nil
    }

    var linkUpdaters = [ODataLinkUpdater]()
    let service = try self.getServiceFromParams(params)
    let entitySetName = try self.getEntitySetNameFromService(service)

    for linkUpdaterParam in linkUpdaterParams {
      let linkUpdater = try ODataLinkUpdater(sourceEntitySetName: entitySetName, linkingParams: linkUpdaterParam)
      linkUpdaters.append(linkUpdater)
    }
    return linkUpdaters
  }

  public static func getLinkDeletersFromParams(_ params: [String: Any]) throws -> [ODataLinkDeleter]? {

    guard let linkDeleterParams = params[DELETELINKS] as? [[String: String]], !linkDeleterParams.isEmpty else {
      return nil
    }

    var linkDeleters = [ODataLinkDeleter]()
    let service = try self.getServiceFromParams(params)
    let entitySetName = try self.getEntitySetNameFromService(service)

    for linkDeleterParam in linkDeleterParams {
      let linkDeleter = try ODataLinkDeleter(sourceEntitySetName: entitySetName, linkingParams: linkDeleterParam)
      linkDeleters.append(linkDeleter)
    }
    return linkDeleters
  }
}
