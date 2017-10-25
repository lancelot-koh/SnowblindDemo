//
//  MockDataProvider.swift
//  SAPMDCFramework
//
//  Created by Wonderley, Lucas on 1/30/17.
//  Copyright © 2017 SAP. All rights reserved.
//

import Foundation
import SAPMDC
//swiftlint:disable function_parameter_count
class MockDataProvider: DataProvider {

  var params: NSDictionary?
  var entitySetStr: String?
  var propertiesArr: NSArray?
  var propertiesDict: NSDictionary?
  var keyProperties: NSArray?
  var queryString: String?
  public var createLinks: [[String: String]]? = []

  public func download(params: NSDictionary, success: @escaping (AnyObject?) -> Void, failure: @escaping (String?, String?, NSError?) -> Void) {
    self.params = params
    success(nil)
  }

  public func initOfflineStore(params: NSDictionary, success: @escaping (AnyObject?) -> Void, failure: @escaping (String?, String?, NSError?) -> Void) {
    self.params = params
    success(nil)
  }

  func close(params: NSDictionary, success: (AnyObject?) -> Void, failure: (String?, String?, NSError?) -> Void) {
    self.params = params
    success(nil)
  }

  func clear(params: NSDictionary, success: (AnyObject?) -> Void, failure: (String?, String?, NSError?) -> Void) {
    self.params = params
    success(nil)
  }

  public func upload(params: NSDictionary, success: @escaping (AnyObject?) -> Void, failure: @escaping (String?, String?, NSError?) -> Void) {
    self.params = params
    success(nil)
  }

  func create(params: NSDictionary, success: (AnyObject?) -> Void, failure: (String?, String?, NSError?) -> Void) -> Bool {
    self.params = params
    success(nil)
    return true
  }

  func open(params: NSDictionary, success: (AnyObject?) -> Void, failure: (String?, String?, NSError?) -> Void) -> Bool {
    self.params = params
    success(nil)
    return true
  }

  func read(entitySet: String, properties: NSArray, queryString: String?, success: (AnyObject?) -> Void,
            failure: (String?, String?, NSError?) -> Void) {
    self.entitySetStr = entitySet
    self.propertiesArr = properties
    self.queryString = queryString
    success(nil)
  }

  func updateEntity(odataUpdater: ODataUpdater) throws -> Any {
    return "entityString"
  }

  func createEntity(odataCreator: ODataCreator) throws -> Any {
    return "entityString"
  }

  func createMediaEntity(entitySetName: String, properties: NSDictionary, headers: NSDictionary?, isOnlineRequest: Bool,
                         media: NSArray, success: @escaping (AnyObject?) -> Void, failure: @escaping (String?, String?, NSError?) -> Void) {
    success(nil)
  }

  func createOpenService(serviceUrl: String ) -> Bool {
    if serviceUrl == "invalidService" {
      return false
    }
    return true
  }

  public func deleteEntity(odataDeleter: ODataDeleter) throws -> Any {
    return "entityString"
  }

  public func deleteMediaEntity(entitySetName: String, readLink: String) throws -> Any {
    return "entity"
  }

  public func beginChangeSet(success: @escaping (AnyObject?) -> Void, failure: @escaping (String?, String?, NSError?) -> Void) -> Void {
    success(nil)
  }

  public func cancelChangeSet(success: @escaping (AnyObject?) -> Void, failure: @escaping (String?, String?, NSError?) -> Void) -> Void {
    success(nil)
  }

  public func commitChangeSet(success: @escaping (AnyObject?) -> Void, failure: @escaping (String?, String?, NSError?) -> Void) -> Void {
    success(nil)
  }

  public func deleteMedia(entitySetName: String, properties: NSDictionary, queryString: String?,
                           success: @escaping (AnyObject?) -> Void,
                           failure: @escaping (String?, String?, NSError?) -> Void) {
    success(nil)
  }

  public func downloadMedia(entitySet: String, readLink: String?, success: @escaping (AnyObject?) -> Void, failure: @escaping (String?, String?, NSError?) -> Void) {
    success(nil)
  }

  public func isMediaLocal(entitySet: String, readLink: String?, success: @escaping (AnyObject?) -> Void, failure: @escaping (String?, String?, NSError?) -> Void) {
    success(nil)
  }

  func count(entitySet: String, properties: NSArray, queryString: String?, success: (AnyObject?) -> Void,
            failure: (String?, String?, NSError?) -> Void) {
    self.entitySetStr = entitySet
    self.propertiesArr = properties
    self.queryString = queryString
    success(0 as AnyObject)
  }
}
