//
//  DataProvider.swift
//  SnowblindClient
//
//  Created by Mehta, Kunal on 9/9/16.
//  Copyright © 2016 sap. All rights reserved.
//

import Foundation
//swiftlint:disable function_parameter_count
@objc(DataProvider)
public protocol DataProvider {
  /// Offline specific methods
  func download(params: NSDictionary, success: @escaping (AnyObject?) -> Void, failure: @escaping (String?, String?, NSError?) -> Void)
  func initOfflineStore(params: NSDictionary, success: @escaping (AnyObject?) -> Void, failure: @escaping (String?, String?, NSError?) -> Void)
  func upload(params: NSDictionary, success: @escaping (AnyObject?) -> Void, failure: @escaping (String?, String?, NSError?) -> Void)
  func close(params: NSDictionary, success: (AnyObject?) -> Void, failure: (String?, String?, NSError?) -> Void)
  func clear(params: NSDictionary, success: (AnyObject?) -> Void, failure: (String?, String?, NSError?) -> Void)
  /// Online specific methods
  func create(params: NSDictionary, success: (AnyObject?) -> Void, failure: (String?, String?, NSError?) -> Void) -> Bool
  func open(params: NSDictionary, success: (AnyObject?) -> Void, failure: (String?, String?, NSError?) -> Void) -> Bool
  /// Common CRUD methods
  func read(entitySet: String, properties: NSArray, queryString: String?, success: (AnyObject?) -> Void,
            failure: (String?, String?, NSError?) -> Void)
  func createEntity(odataCreator: ODataCreator) throws -> Any
  func updateEntity(odataUpdater: ODataUpdater) throws -> Any
  func deleteEntity(odataDeleter: ODataDeleter) throws -> Any
  func deleteMediaEntity(entitySetName: String, readLink: String) throws -> Any
  func createMediaEntity(entitySetName: String, properties: NSDictionary, headers: NSDictionary?,
                         isOnlineRequest: Bool, media: NSArray,
                         success: @escaping (AnyObject?) -> Void, failure: @escaping (String?, String?, NSError?) -> Void)
  func createOpenService(serviceUrl: String ) -> Bool
  func downloadMedia(entitySet: String, readLink: String?, success: @escaping (AnyObject?) -> Void, failure: @escaping (String?, String?, NSError?) -> Void)
  func isMediaLocal(entitySet: String, readLink: String?, success: @escaping (AnyObject?) -> Void, failure: @escaping (String?, String?, NSError?) -> Void)
  // Change Set methods
  func beginChangeSet(success: @escaping (AnyObject?) -> Void, failure: @escaping (String?, String?, NSError?) -> Void) -> Void
  func cancelChangeSet(success: @escaping (AnyObject?) -> Void, failure: @escaping (String?, String?, NSError?) -> Void) -> Void
  func commitChangeSet(success: @escaping (AnyObject?) -> Void, failure: @escaping (String?, String?, NSError?) -> Void) -> Void
  func count(entitySet: String, properties: NSArray, queryString: String?, success: (AnyObject?) -> Void,
            failure: (String?, String?, NSError?) -> Void)
}
