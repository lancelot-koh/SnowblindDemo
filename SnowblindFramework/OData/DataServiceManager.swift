//
//  DataServiceManager.swift
//  SnowblindClient
//
//  Created by Mehta, Kunal on 9/9/16.
//  Copyright © 2016 sap. All rights reserved.
//

import Foundation

@objc(DataServiceManager)
public class DataServiceManager: NSObject {
  // singleton
  @objc
  public static let sharedInstance = DataServiceManager()
  public override init() {
  }

  // actual data provider
  var dataProviders = [String: DataProvider]()
  @objc
  public func download(params: NSDictionary, resolve: @escaping SnowblindPromiseResolveBlock,
                             reject: @escaping SnowblindPromiseRejectBlock) -> Void {
    guard let serviceUrl = params["serviceUrl"] else {
      reject(nil, "serviceUrl missing from definition", nil)
      return
    }

    guard let serviceName = DataServiceUtils.getServiceName(serviceUrl: serviceUrl as? String) else {
      reject(nil, "serviceName missing from serviceUrl", nil)
      return
    }

    guard let provider = dataProviders[serviceName] else {
      reject(nil, "Offline OData Store needs to be initialized", nil)
      return
    }

    provider.download(params: params, success: { (obj: AnyObject?) in
      resolve(obj)
    }, failure: { (code: String?, message: String?, error: NSError?) in
      reject(code, message, error)
    })
  }
  @objc
  public func initOfflineStore(provider: DataProvider, params: NSDictionary, resolve: @escaping SnowblindPromiseResolveBlock,
                                     reject: @escaping SnowblindPromiseRejectBlock) -> Void {
    if let serviceUrl = params["serviceUrl"] {
      provider.initOfflineStore(params: params,
        success: { (obj: AnyObject?) in
          if let name = DataServiceUtils.getServiceName(serviceUrl: serviceUrl as? String) {
            print("DataServiceManager name == \(name)")
            self.dataProviders[name] = provider
            resolve(obj)
          } else {
            reject(nil, "Service name is invalid", nil)
          }
        },
        failure: { (code: String?, message: String?, error: NSError?) in
          reject(code, message, error)
        }
      )
    } else {
      let errorMsg = "Could not complete initOfflineStore action because the serviceUrl was not found."
      reject(nil, errorMsg, DataServiceUtils.getError(errorCode: DataServiceUtils.genericErrorCode, errorMessage: errorMsg))
    }
  }
  @objc
  public func close(params: NSDictionary, resolve: @escaping SnowblindPromiseResolveBlock, reject: @escaping SnowblindPromiseRejectBlock) -> Void {
    if let serviceUrl = params["serviceUrl"],
      let serviceName = DataServiceUtils.getServiceName(serviceUrl: serviceUrl as? String),
      let provider = dataProviders[serviceName] {
      provider.close(params: params, success: { (obj: AnyObject?) in
        resolve(obj)
      }, failure: { (code: String?, message: String?, error: NSError?) in
        reject(code, message, error)
      })
    } else {
      reject(nil, "Could not find service provider", nil)
      return
    }
  }
  @objc
  public func clear(params: NSDictionary, resolve: @escaping SnowblindPromiseResolveBlock, reject: @escaping SnowblindPromiseRejectBlock) -> Void {
    let serviceUrl =  params["serviceUrl"]
    let serviceName = DataServiceUtils.getServiceName(serviceUrl: serviceUrl as? String)
    if let serviceName = serviceName,
      let provider = dataProviders[serviceName] {
      provider.clear(params: params, success: { (obj: AnyObject?) in
        dataProviders.removeValue(forKey: serviceName)
        resolve(obj)
      }, failure: { (code: String?, message: String?, error: NSError?) in
          reject(code, message, error)
      })
    } else {
      var isForce = false
      if let paramsForce: Bool = params["force"] as? Bool {
        isForce = paramsForce
      }
      if !isForce {
        let errorMsg = "Could not find service provider, ensure it is initialized"
        reject(nil, errorMsg, DataServiceUtils.getError(errorCode: DataServiceUtils.genericErrorCode, errorMessage: errorMsg))
        return
      }
        ODataServiceProvider.clear(at: URL(fileURLWithPath:ODataServiceProvider.offlineODataDirectory()), withName: serviceName, success: { (obj: AnyObject?) in
          resolve(obj)
        }, failure: { (code: String?, message: String?, error: NSError?) in
          reject(code, message, error)
        })
    }
  }
  @objc
  public func upload(params: NSDictionary, resolve: @escaping SnowblindPromiseResolveBlock,
                           reject: @escaping SnowblindPromiseRejectBlock) -> Void {
    guard let serviceUrl = params["serviceUrl"] else {
      reject(nil, "serviceUrl missing from definition", nil)
      return
    }

    guard let serviceName = DataServiceUtils.getServiceName(serviceUrl: serviceUrl as? String) else {
      reject(nil, "serviceName missing from serviceUrl", nil)
      return
    }

    guard let provider = dataProviders[serviceName] else {
      reject(nil, "Offline OData Store needs to be initialized", nil)
      return
    }

    provider.upload(params: params, success: { (obj: AnyObject?) in
      resolve(obj)
    }, failure: { (code: String?, message: String?, error: NSError?) in
      reject(code, message, error)
    })
  }
  @objc
  public func create(provider: DataProvider, params: NSDictionary, resolve: SnowblindPromiseResolveBlock,
                           reject: SnowblindPromiseRejectBlock) -> Void {
    if let serviceUrl = params["serviceUrl"] {
      _ = provider.create(params: params,
        success: { (obj: AnyObject?) in
          if let name = DataServiceUtils.getServiceName(serviceUrl: serviceUrl as? String) {
            print("DataServiceManager name == \(name)")
            self.dataProviders[name] = provider
            resolve(obj)
          } else {
            reject(nil, "Service name is invalid", nil)
          }
        },
        failure: { (code: String?, message: String?, error: NSError?) in
          reject(code, message, error)
        }
      )
    } else {
      let errorMsg = "Could not complete create action because the serviceUrl was not found."
      reject(nil, errorMsg, DataServiceUtils.getError(errorCode: DataServiceUtils.genericErrorCode, errorMessage: errorMsg))
    }
  }
  @objc
  public func open(params: NSDictionary, resolve: SnowblindPromiseResolveBlock,
                         reject: SnowblindPromiseRejectBlock) -> Void {
    if let serviceUrl = params["serviceUrl"],
      let serviceName = DataServiceUtils.getServiceName(serviceUrl: serviceUrl as? String),
      let provider = dataProviders[serviceName] {
      _ = provider.open(params: params, success: { (obj: AnyObject?) in
        resolve(obj)
      }, failure: { (code: String?, message: String?, error: NSError?) in
        reject(code, message, error)
      })
    } else {
      reject(nil, "Could not find service provider", nil)
      return
    }
  }
  @objc
  public func read(params: NSDictionary, resolve: SnowblindPromiseResolveBlock,
                         reject: SnowblindPromiseRejectBlock) -> Void {
    if let serviceUrl = params["serviceUrl"] as? String,
      let entitySet = params["entitySet"] as? String,
      let properties = params["properties"] as? NSArray {
      if let serviceName = DataServiceUtils.getServiceName(serviceUrl: serviceUrl),
        let provider = dataProviders[serviceName] {
        var queryString: String?
        if let temp = params["queryOptions"] as? String, !temp.isEmpty {
          queryString = temp
        }
        let start = Date()
        provider.read(entitySet: entitySet, properties: properties, queryString: queryString, success: { (obj) in
          print("  Native read done (\(Date().timeIntervalSince(start) * 1000)ms)")
          print("    EntitySet = '\(entitySet)'")
          print("    QueryOptions = '\(String(describing:queryString))'")
          resolve(obj)
        }, failure: { (code, message, error) in
          reject(code, message, error)
        })
      } else {
        reject(nil, "Could not find service provider", nil)
      }

    } else {
      reject(nil, "Could not find service provider, entity set or properties", nil)
      return
    }
  }
  @objc
  public func createEntity(params: NSDictionary, resolve: @escaping SnowblindPromiseResolveBlock,
                                 reject: @escaping SnowblindPromiseRejectBlock) -> Void {
    do {
      let creator = try ODataCreator(params)

      let provider = try getProvider(forServiceUrl: creator.serviceUrl)

        resolve(try provider.createEntity(odataCreator: creator))

    } catch ODataErrors.genericError(let errorMsg) {
      reject(nil, "Create Entity failed, \(errorMsg)", DataServiceUtils.getError(errorCode: 410, errorMessage: errorMsg))
    } catch {
      reject(nil, "Create Entity failed", error as NSError?)
    }
  }
  @objc
  public func update(params: NSDictionary, resolve: @escaping SnowblindPromiseResolveBlock,
                           reject: @escaping SnowblindPromiseRejectBlock) -> Void {
    do {

      let updater = try ODataUpdater(params)

      let provider = try getProvider(forServiceUrl: updater.serviceUrl)

      resolve(try provider.updateEntity(odataUpdater: updater))

    } catch ODataErrors.genericError(let errorMsg) {
      reject(nil, "Update Entity failed, \(errorMsg)", DataServiceUtils.getError(errorCode: 410, errorMessage: errorMsg))
    } catch {
      reject(nil, "Update Entity failed", error as NSError?)
    }
  }
  @objc
  public func deleteEntity(params: NSDictionary, resolve: @escaping SnowblindPromiseResolveBlock,
                                 reject: @escaping SnowblindPromiseRejectBlock) -> Void {
    do {

      let deleter = try ODataDeleter(params)

      let provider = try getProvider(forServiceUrl: deleter.serviceUrl)

      resolve(try provider.deleteEntity(odataDeleter: deleter))

    } catch ODataErrors.genericError(let errorMsg) {
      reject(nil, "Delete Entity failed, \(errorMsg)", DataServiceUtils.getError(errorCode: 410, errorMessage: errorMsg))
    } catch {
      reject(nil, "Delete Entity failed", error as NSError?)
    }
  }

  private func getProvider(forServiceUrl serviceUrl: String) throws -> DataProvider {
    guard let serviceName = DataServiceUtils.getServiceName(serviceUrl: serviceUrl) else {
      throw ODataErrors.genericError("Could not extract Servie Name from serviceUrl: \(serviceUrl)")
    }
    guard let provider = dataProviders[serviceName] else {
      throw ODataErrors.genericError("No data provider exists for serviceName: \(serviceName)")
    }
    return provider
  }
  @objc
  public func createMedia(params: NSDictionary, resolve: @escaping SnowblindPromiseResolveBlock,
                                reject: @escaping SnowblindPromiseRejectBlock) -> Void {

    guard let mediaArray = params["media"] as? NSArray,
      mediaArray.count != 0,
      let serviceUrl = params["serviceUrl"] as? String,
      let entitySetName = params["entitySet"] as? String,
      !(entitySetName.isEmpty),
      let properties = params["properties"] as? NSDictionary,
      let headers = params["headers"] as? NSDictionary,
      let isOnlineRequest = params["isOnlineRequest"] as? Bool else {
        let errorMsg = "create Media Entity failed: invalid params"
        reject(String(DataServiceUtils.genericErrorCode), errorMsg, DataServiceUtils.getError(errorCode: DataServiceUtils.genericErrorCode, errorMessage: errorMsg))
        return
    }

    if let serviceName = DataServiceUtils.getServiceName(serviceUrl: serviceUrl),
      let provider = dataProviders[serviceName] {

      guard isOnlineRequest == true && provider.createOpenService(serviceUrl: serviceUrl) || isOnlineRequest == false else {
        let errorMsg = "Could not create and open online service"
        reject(String(DataServiceUtils.genericErrorCode), errorMsg, DataServiceUtils.getError(errorCode: DataServiceUtils.genericErrorCode, errorMessage: errorMsg))
        return
      }
      provider.createMediaEntity(entitySetName: entitySetName, properties: properties, headers: headers, isOnlineRequest: isOnlineRequest,
                                 media: mediaArray,
                                 success: { (obj) in resolve(obj) },
                                 failure: { (code, message, error) in reject(code, message, error)})

    } else {
      let errorMsg = "Could not find service provider"
      reject(String(DataServiceUtils.genericErrorCode), errorMsg, DataServiceUtils.getError(errorCode: DataServiceUtils.genericErrorCode, errorMessage: errorMsg))
      return
    }
  }
  @objc
  public func beginChangeSet(params: NSDictionary, resolve: @escaping SnowblindPromiseResolveBlock,
                                   reject: @escaping SnowblindPromiseRejectBlock) -> Void {

    let serviceUrl = params["serviceUrl"] as? String

    if let serviceName = DataServiceUtils.getServiceName(serviceUrl: serviceUrl),
      let provider = dataProviders[serviceName] {
      provider.beginChangeSet(success: { (status) in resolve(status) }, failure: { (code, message, error) in reject(code, message, error)})
    } else {
      let errorMsg = "Could not find service provider"
      reject(String(DataServiceUtils.genericErrorCode), errorMsg, DataServiceUtils.getError(errorCode: DataServiceUtils.genericErrorCode, errorMessage: errorMsg))
    }
  }
  @objc
  public func cancelChangeSet(params: NSDictionary, resolve: @escaping SnowblindPromiseResolveBlock,
                                    reject: @escaping SnowblindPromiseRejectBlock) -> Void {
    let serviceUrl = params["serviceUrl"] as? String

    if let serviceName = DataServiceUtils.getServiceName(serviceUrl: serviceUrl),
      let provider = dataProviders[serviceName] {
      provider.cancelChangeSet(success: { (status) in resolve(status) }, failure: { (code, message, error) in reject(code, message, error)})
    } else {
      let errorMsg = "Could not find service provider"
      reject(String(DataServiceUtils.genericErrorCode), errorMsg, DataServiceUtils.getError(errorCode: DataServiceUtils.genericErrorCode, errorMessage: errorMsg))
    }
  }
  @objc
  public func commitChangeSet(params: NSDictionary, resolve: @escaping SnowblindPromiseResolveBlock,
                                    reject: @escaping SnowblindPromiseRejectBlock) -> Void {
    let serviceUrl = params["serviceUrl"] as? String

    if let serviceName = DataServiceUtils.getServiceName(serviceUrl: serviceUrl),
      let provider = dataProviders[serviceName] {
      provider.commitChangeSet(success: { (status) in resolve(status) }, failure: { (code, message, error) in reject(code, message, error)})
    } else {
      let errorMsg = "Could not find service provider"
      reject(String(DataServiceUtils.genericErrorCode), errorMsg, DataServiceUtils.getError(errorCode: DataServiceUtils.genericErrorCode, errorMessage: errorMsg))
    }
  }
  @objc
  public func deleteMedia(params: NSDictionary, resolve: @escaping SnowblindPromiseResolveBlock,
                                 reject: @escaping SnowblindPromiseRejectBlock) -> Void {
      do {
        let params = try CrudParams(params, operation: .delete)
        let provider = try getProvider(forServiceUrl: params.serviceUrl)
        resolve(try provider.deleteMediaEntity(entitySetName: params.entitySetName, readLink: params.readLink!))
      } catch ODataErrors.genericError(let errorMsg) {
        reject(nil, "Delete Entity failed, \(errorMsg)", DataServiceUtils.getError(errorCode: 410, errorMessage: errorMsg))
      } catch {
        reject(nil, "Delete Entity failed", error as NSError?)
      }
  }
  @objc
  public func downloadMedia(params: NSDictionary, resolve: @escaping SnowblindPromiseResolveBlock,
                                    reject: @escaping SnowblindPromiseRejectBlock) -> Void {

    if let serviceUrl = params["serviceUrl"] as? String,
      let entitySet = params["entitySet"] as? String {
      if let serviceName = DataServiceUtils.getServiceName(serviceUrl: serviceUrl),
        let provider = dataProviders[serviceName] {
        let readLink = params["readLink"] as? String
        provider.downloadMedia(entitySet: entitySet, readLink: readLink, success: { (obj) in
          resolve(obj)
        }, failure: { (code, message, error) in
          reject(code, message, error)
        })
      } else {
        reject(nil, "Could not find service provider", nil)
      }

    } else {
      reject(nil, "Could not find service provider, entity set or properties", nil)
      return
    }
  }
  @objc
  public func isMediaLocal(params: NSDictionary, resolve: @escaping SnowblindPromiseResolveBlock,
                                  reject: @escaping SnowblindPromiseRejectBlock) -> Void {

    if let serviceUrl = params["serviceUrl"] as? String,
      let entitySet = params["entitySet"] as? String {
      if let serviceName = DataServiceUtils.getServiceName(serviceUrl: serviceUrl),
        let provider = dataProviders[serviceName] {
        let readLink = params["readLink"] as? String
        provider.isMediaLocal(entitySet: entitySet, readLink: readLink, success: { (obj) in
          resolve(obj)
        }, failure: { (code, message, error) in
          reject(code, message, error)
        })
      } else {
        reject(nil, "Could not find service provider", nil)
      }

    } else {
      reject(nil, "Could not find service provider, entity set or properties", nil)
      return
    }
  }
  @objc
  public func count(params: NSDictionary, resolve: SnowblindPromiseResolveBlock,
                         reject: SnowblindPromiseRejectBlock) -> Void {

    if let serviceUrl = params["serviceUrl"] as? String,
      let entitySet = params["entitySet"] as? String,
      let properties = params["properties"] as? NSArray {
      if let serviceName = DataServiceUtils.getServiceName(serviceUrl: serviceUrl),
        let provider = dataProviders[serviceName] {
        var queryString: String?
        if let temp = params["queryOptions"] as? String, !temp.isEmpty {
          queryString = temp
        }

        let start = Date()
        provider.count(entitySet: entitySet, properties: properties, queryString: queryString, success: { (result) in

          print("  Native count done (\(Date().timeIntervalSince(start) * 1000)ms)")
          print("    EntitySet = '\(entitySet)'")
          print("    QueryOptions = '\(String(describing:queryString))'")

          resolve(result)
        }, failure: { (code, message, error) in
          reject(code, message, error)
        })
      } else {
        reject(nil, "Could not find service provider", nil)
      }

    } else {
      reject(nil, "Could not find service provider, entity set or properties", nil)
      return
    }
  }
}
