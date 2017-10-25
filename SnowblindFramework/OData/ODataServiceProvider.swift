//
//  ODataServiceProvider.swift
//  SnowblindClient
//
//  Created by Mehta, Kunal on 9/9/16.
//  Copyright © 2016 sap. All rights reserved.
//

import Foundation
import SAPFoundation
import SAPOData
import SAPOfflineOData
import SAPCommon

// swiftlint:disable file_length
// swiftlint:disable trailing_whitespace
// swiftlint:disable type_body_length
@objc(ODataServiceProvider)
public class ODataServiceProvider: NSObject, DataProvider {
  enum StateChangeOperation: String {
    case close
    case clear
  }

  var onlineService: DataService<OnlineODataProvider>?
  var offlineService: DataService<OfflineODataProvider>?
  // HACK #1: Anywhere you see this bool used, it is a hack.  Ideally, we could use one DataService for
  // online and offline and initialize it with the correct DataServiceProvider type.  Since
  // DataServiceProvider is a protocol and not a concrete type, there are complications trying to
  // do something like:
  // var service: DataService<DataServiceProvider>
  //
  // There are also issues trying to create a generic method to return the correct type.  So, for the
  // time being, we will use a boolean and some duplicate code.

  var isOnlineServiceOpen = false
  var isOnlineServiceCreated = false
  public var online: Bool = false
  private static var demoDBPath: String?

  // This is a temporary workaround until Gateway supports DateTimeOffset. UTC is default, and customers can specify the
  // time zone of their backend in BrandedSettings, which has priority.
  // Those settings will be passed by initOfflineStore.
  // Know limitations: does not support multiple services (backends), does not support full-online mode
  public static var serviceTimeZoneAbbreviation = "UTC"

  private lazy var changeSetManager: ChangeSetManager = {
    let manager = ChangeSetManager(self.offlineService)
    return manager
  }()

  static let NILERRORMESSAGE =  "no error description: error or error.message is nil"

  // MARK: - INIT

  // If in demo mode, the demo DB path for udb files may have been specified.
  // Drop the file name and check path validity and if invalid, ignore it and use the documents folder.
  public static func offlineODataDirectory() -> String {
    let documentsFolder = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    // The demo DB path will get set when we init offline odata in demo mode.
    return documentsFolder + (ODataServiceProvider.demoDBPath ?? "")
  }
  
  public func open(params: NSDictionary, success: (AnyObject?) -> Void,
                   failure: (String?, String?, NSError?) -> Void) -> Bool {
    if onlineService != nil {
      do {
        try onlineService?.loadMetadata()
        isOnlineServiceOpen = true
        success(nil)
        return true
      } catch {
        failure(nil, "Service open failed, failed to retrieve metadata", error as NSError)
        return false
      }
    } else {
      let errorMsg = "Service open failed, DataService does not exist. Did you call create()?"
      failure(nil, errorMsg, DataServiceUtils.getError(errorCode: DataServiceUtils.genericErrorCode, errorMessage: errorMsg))
      return false
    }
  }

  public func createOpenService(serviceUrl: String ) -> Bool {
    let params: NSDictionary = ["serviceUrl": serviceUrl]
    if isOnlineServiceOpen {
      return true
    } else if create(params: params, success: { (_) in }, failure: { (_, _, _) in })
      && open(params: params, success: { (_) in }, failure: { (_, _, _) in }) {
      return true
    }
    return false
  }

  // swiftlint:disable function_body_length
  // swiftlint:disable:next cyclomatic_complexity
  public func initOfflineStore(params: NSDictionary, success: @escaping (AnyObject?) -> Void,
                               failure: @escaping (String?, String?, NSError?) -> Void) {

    var storeParams: OfflineODataParameters = OfflineODataParameters()
    let enableRepeatableRequests = true
    storeParams.enableRepeatableRequests = enableRepeatableRequests
    let inDemoMode = params["inDemoMode"] as? Bool
    ODataServiceProvider.demoDBPath = nil // default to nil, set when valid
    
    if inDemoMode ?? false {
      // If we are in demo mode, process the dbPath param so we can access the local udb files
      let paramDbPath = params["dbPath"] as? String
      let fileManager = FileManager.default
      let documentsFolder = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
      var isDir: ObjCBool = false
      if var dPath = paramDbPath, dPath.hasSuffix(".udb") {
        if !dPath.hasPrefix("/") {
          dPath = "/" + dPath
        }
        let dbRelativeFolder = dPath.components(separatedBy: "/").dropLast().joined(separator: "/")
        if fileManager.fileExists(atPath: (documentsFolder + dbRelativeFolder), isDirectory: &isDir) && isDir.boolValue {
          ODataServiceProvider.demoDBPath = dbRelativeFolder
        }
      }
    }

    if let serviceTimeZoneAbbreviation = params["serviceTimeZoneAbbreviation"] as? String, !serviceTimeZoneAbbreviation.isEmpty {
      ODataServiceProvider.serviceTimeZoneAbbreviation = serviceTimeZoneAbbreviation
    }

    if let encryptionKey = params["storeEncryptionKey"] as? String {
      storeParams.storeEncryptionKey = encryptionKey
    }

    if let serviceURL = params["serviceUrl"] as? String {
      do {
        if let storeName = DataServiceUtils.getServiceName(serviceUrl: serviceURL) {
          storeParams.storeName = storeName
        }
        storeParams.storePath = URL(fileURLWithPath: ODataServiceProvider.offlineODataDirectory())
        // SNOWBLIND-4095 - Transactions should be merged where possible.
        storeParams.extraStreamParameters = "__transaction_merge;"
        if inDemoMode ?? false, let name = storeParams.storeName {
          try self.initDemoDatabase(withStoreName: name)
        } else {
          print("inDemoMode Flag is nil")
        }
        let sapURLSession = OAuthRequestor.sharedInstance.urlSession
        /// Setup an instance of delegate.
        let delegate: OfflineODataDelegateImpl = OfflineODataDelegateImpl()
        let provider = try OfflineODataProvider( serviceRoot: URL(string: serviceURL)!, parameters: storeParams, sapURLSession: sapURLSession, delegate: delegate )
        // SNOWBLIND-3721 - enable binding
        provider.serviceOptions.supportsBind = false
        
        if let debugODataProvider = params["debugODataProvider"] as? Bool {
          if debugODataProvider {
            let sapLogLevel = SAPCommon.LogLevel.debug
            print("Setting log level for OfflineODataProvider('\(serviceURL)') to '\(sapLogLevel)'")
            provider.logger.add(handler: ConsoleLogHandler())
            provider.logger.logLevel = sapLogLevel
          }
        }

        // Apply any defining requests
        if let definingRequests = params["definingRequests"] as? [AnyObject] {
          for req in definingRequests {
            if let name = req["Name"] as? String, let query = req["Query"] as? String {
              var autoRetrieveStreams: Bool = false
              if let ars = req["AutomaticallyRetrievesStreams"] as? Bool {
                autoRetrieveStreams = ars
              }

              let defQuery = OfflineODataDefiningQuery(name: name, query: query, automaticallyRetrievesStreams: autoRetrieveStreams)
              try provider.add( definingQuery: defQuery )
            }
          }
        }

        // Do the open
        provider.open( completionHandler: { ( _ error: OfflineODataError? ) -> Void in
          if error != nil {
            /// Handle the error
            failure(nil, "Offline store initialization failed: \(error?.message ?? ODataServiceProvider.NILERRORMESSAGE)",
              DataServiceUtils.getOfflineError(errorCode: error?.code, oDataError: error!))
            return
          }

          self.offlineService = DataService(provider: provider)
          success(nil)
        })
      } catch ODataErrors.genericError(let errorMsg) {
        let errorMessage = "OfflineODataProvider failed to be initialized: \(errorMsg)"
        failure(nil, errorMessage, DataServiceUtils.getError(errorCode: DataServiceUtils.genericErrorCode, errorMessage: errorMessage))
      } catch let error as NSError {
        failure(nil, "OfflineODataProvider failed to be initialized: \(error.userInfo)", error as NSError)
      }
    } else {
      let errorMsg = "OfflineODataProvider failed to be initialized"
      failure(nil, errorMsg, DataServiceUtils.getError(errorCode: DataServiceUtils.genericErrorCode, errorMessage: errorMsg))
    }
  }
  private func initDemoDatabase(withStoreName name: String) throws {
    let fileManager = FileManager.default
    do {
      let odataDir = ODataServiceProvider.offlineODataDirectory()
      let rqUdbFilename = name + ".rq.udb"
      let udbFilename = name + ".udb"
      let rqUdbFileExists = fileManager.fileExists(atPath: odataDir + "/" + rqUdbFilename)
      let udbFileExists = fileManager.fileExists(atPath: odataDir + "/"  + udbFilename)

      if rqUdbFileExists && udbFileExists {
        // We already have BOTH the required udb files.
        return
      }

      let sourceDir = "app/branding"
      // Copy .rq.udb file
      var sourcePath = Bundle.main.path(forResource: name, ofType: ".rq.udb", inDirectory: sourceDir)
      guard sourcePath != .none && odataDir != .none else {
        throw ODataErrors.genericError("\(rqUdbFilename) not found in bundle directory: \(sourceDir) ")
      }
      var destPath = "\(odataDir)/\(rqUdbFilename)"
      try fileManager.copyItem(atPath: sourcePath!, toPath: destPath)

      // Copy .udb file
      sourcePath = Bundle.main.path(forResource: name, ofType: ".udb", inDirectory: sourceDir)
      guard sourcePath != .none && odataDir != .none else {
        throw ODataErrors.genericError("\(udbFilename) not found in bundle directory: \(sourceDir) ")
      }
      destPath = "\(odataDir)/\(udbFilename)"
      try fileManager.copyItem(atPath: sourcePath!, toPath: destPath)
    } catch ODataErrors.genericError(let errorMsg) {
      throw ODataErrors.genericError("Failed to initialize demo database: \(errorMsg)")
    } catch let error as NSError {
      throw ODataErrors.throwError(error)
    }
  }

  public func close(params: NSDictionary, success: (AnyObject?) -> Void,
                    failure: (String?, String?, NSError?) -> Void) {
    offlineStateChange(params: params,
                       success: success,
                       failure: failure,
                       stateChangeOperation: StateChangeOperation.close)
  }

  public func clear(params: NSDictionary, success: (AnyObject?) -> Void,
                    failure: (String?, String?, NSError?) -> Void) {
    offlineStateChange(params: params,
                       success: success,
                       failure: failure,
                       stateChangeOperation: StateChangeOperation.clear)
  }

  // swiftlint:disable function_body_length
  private func offlineStateChange(params: NSDictionary, success: (AnyObject?) -> Void,
                                  failure: (String?, String?, NSError?) -> Void,
                                  stateChangeOperation: StateChangeOperation) {
    let operationType: String = stateChangeOperation.rawValue

    if online {
      let errorMsg = "OnlineDataProvider used to do Offline OData \(operationType)"
      failure(nil, errorMsg, DataServiceUtils.getError(errorCode: DataServiceUtils.genericErrorCode, errorMessage: errorMsg))
      return
    }

    var isForce = false

    if let paramsForce: Bool = params["force"] as? Bool {
      isForce = paramsForce
    }

    if let offlineService = offlineService {
      var isPending = false
      var isQueueEmpty = false

      // hasPendingUpload and requestQueueIsEmpty will throw an exception if the store is closed.
      if !isForce {
        do {
          isPending = try offlineService.hasPendingUpload()
          isQueueEmpty = try offlineService.requestQueueIsEmpty()
        } catch {
          let errorMsg = "Service \(operationType) failed, error in identifying pending uploads"
          failure(nil, errorMsg, DataServiceUtils.getError(errorCode: DataServiceUtils.genericErrorCode, errorMessage: errorMsg))
          return
        }
      }

      if (!isPending && isQueueEmpty) || isForce {
        do {
          switch stateChangeOperation {
          case StateChangeOperation.close:
            try offlineService.close()
            break
          case StateChangeOperation.clear:
            try offlineService.clear()
            break
          }
          success(nil)
        } catch let offlineError as OfflineODataError {
          failure(nil, "Service \(operationType) failed: \(offlineError.message ?? ODataServiceProvider.NILERRORMESSAGE)",
            DataServiceUtils.getOfflineError(errorCode: offlineError.code, oDataError: offlineError))
        } catch {
          let errorMsg = "Service \(operationType) failed"
          failure(nil, errorMsg, DataServiceUtils.getError(errorCode: DataServiceUtils.genericErrorCode, errorMessage: errorMsg))
        }
      } else {
        let errorMsg = "Service \(operationType) failed, pending uploads exist."
        failure(nil, errorMsg, DataServiceUtils.getError(errorCode: DataServiceUtils.genericErrorCode, errorMessage: errorMsg))
      }
    } else {
      let errorMsg = "Offline OData Initialize needs to be called before \(operationType)"
      failure(nil, errorMsg, DataServiceUtils.getError(errorCode: DataServiceUtils.genericErrorCode, errorMessage: errorMsg))
    }
  }
  // swiftlint:enable function_body_length

  public static func clear(at url: URL?, withName name: String?, success: (AnyObject?) -> Void,
                           failure: (String?, String?, NSError?) -> Void) {
    do {
      try OfflineODataProvider.clear(at: url, withName: name)
      success(nil)
    } catch let offlineError as OfflineODataError {
      failure(nil, "Clear failed: \(offlineError.message ?? ODataServiceProvider.NILERRORMESSAGE)",
        DataServiceUtils.getOfflineError(errorCode: offlineError.code, oDataError: offlineError))
    } catch {
      let errorMsg = "Offline OData Clear failed (static)"
      failure(nil, errorMsg, DataServiceUtils.getError(errorCode: DataServiceUtils.genericErrorCode, errorMessage: errorMsg))
    }
  }

  // MARK: - UPLOAD - DOWNLOAD

  public func upload(params: NSDictionary, success: @escaping (AnyObject?) -> Void,
                     failure: @escaping (String?, String?, NSError?) -> Void) {
    if online {
      let errorMsg = "OnlineDataProvider used to do Offline OData Upload"
      failure(nil, errorMsg, DataServiceUtils.getError(errorCode: DataServiceUtils.genericErrorCode, errorMessage: errorMsg))
      return
    }

    if offlineService == nil {
      let errorMsg = "Offline OData Initialize needs to be called before upload"
      failure(nil, errorMsg, DataServiceUtils.getError(errorCode: DataServiceUtils.genericErrorCode, errorMessage: errorMsg))
      return
    }

    offlineService?.upload(completionHandler: {(_ error: OfflineODataError?) -> Void in
      if error == nil {
        success(nil)
      } else {
        failure(nil, "Upload failed: \(error?.message ?? ODataServiceProvider.NILERRORMESSAGE)",
          DataServiceUtils.getOfflineError(errorCode: error?.code, oDataError: error!))
      }
    })
  }

  public func download(params: NSDictionary, success: @escaping (AnyObject?) -> Void,
                       failure: @escaping (String?, String?, NSError?) -> Void) {
    if online {
      let errorMsg = "OnlineDataProvider used to do Offline OData Download"
      failure(nil, errorMsg, DataServiceUtils.getError(errorCode: DataServiceUtils.genericErrorCode, errorMessage: errorMsg))
      return
    }

    if offlineService == nil {
      let errorMsg = "Offline OData Initialize needs to be called before download"
      failure(nil, errorMsg, DataServiceUtils.getError(errorCode: DataServiceUtils.genericErrorCode, errorMessage: errorMsg))
      return
    }

    if let definingRequests = params["definingRequests"] as? [AnyObject] {
      var dqs: [OfflineODataDefiningQuery] = []
      for req in definingRequests {
        if let name = req["Name"] as? String, let query = req["Query"] as? String {
          var autoRetrieveStreams: Bool = false
          if let ars = req["AutomaticallyRetrievesStreams"] as? Bool {
            autoRetrieveStreams = ars
          }

          let defQuery = OfflineODataDefiningQuery(name: name, query: query, automaticallyRetrievesStreams: autoRetrieveStreams)
          do {
            try offlineService?.add(definingQuery: defQuery)
          } catch {
            // Typically if we get here, we have already added the defining query to the service. Currently, there is no way
            // to check with the service to see if the defining query already exists. So, it doesn't make much sense to fail the
            // download just because we are adding the defining query twice.  If we failed for something else on the add, we're
            // going to fail the download and catch that.
          }
          dqs.append(defQuery)
        }
      }

      offlineService?.download(withSubset: dqs, completionHandler: {(_ error: OfflineODataError?) -> Void in
        if error == nil {
          success(nil)
        } else {
          failure(nil, "Download failed: \(error?.message ?? ODataServiceProvider.NILERRORMESSAGE)",
            DataServiceUtils.getOfflineError(errorCode: error?.code, oDataError: error!))
        }
      })
    } else {
      offlineService?.download(completionHandler: {(_ error: OfflineODataError?) -> Void in
        if error == nil {
          success(nil)
        } else {
          failure(nil, "Download failed: \(error?.message ?? ODataServiceProvider.NILERRORMESSAGE)",
            DataServiceUtils.getOfflineError(errorCode: error?.code, oDataError: error!))
        }
      })
    }
  }

  public func downloadMedia(entitySet: String, readLink: String?, success: @escaping (AnyObject?) -> Void, failure: @escaping (String?, String?, NSError?) -> Void) {

    guard !(entitySet.isEmpty) else {
      return
    }
    do {
      var eSet: EntitySet?
      if online {
        eSet = try onlineService?.entitySet(withName: entitySet)
      } else {
        eSet = try offlineService?.entitySet(withName: entitySet)
      }

      let media: EntityValue? = EntityValue.ofType((eSet?.entityType!)!)
      media?.readLink = readLink

      var stream: SAPOData.ByteStream?
      if online {
        try onlineService?.loadEntity(media!)
        stream = try onlineService?.downloadMedia(entity: media!)
      } else {
        try offlineService?.loadEntity(media!)
        stream = try offlineService?.downloadMedia(entity: media!)
      }

      let data = try stream?.readAndClose()
      success(data as AnyObject?)
    } catch {
      print ("Caught exception in downloadMedia \(error)")
      failure(nil, "Download media failed", nil)
    }
  }

  public func isMediaLocal(entitySet: String, readLink: String?, success: @escaping (AnyObject?) -> Void, failure: @escaping (String?, String?, NSError?) -> Void) {

    guard !(entitySet.isEmpty) else {
      return
    }
    var fixedEntitySet = entitySet
    if fixedEntitySet.hasPrefix("/") {
      // local entity read link
      fixedEntitySet.remove(at: fixedEntitySet.startIndex)
    }
    do {
      var eSet: EntitySet?
      if online {
        eSet = try onlineService?.entitySet(withName: fixedEntitySet)
      } else {
        eSet = try offlineService?.entitySet(withName: fixedEntitySet)
      }

      let entityValue: EntityValue? = EntityValue.ofType((eSet?.entityType!)!)
      entityValue?.readLink = readLink

      if !online {
        try offlineService?.loadEntity(entityValue!)
      }

      let local = entityValue?.mediaStream.isOffline

      success(local as AnyObject)
    } catch {
      print ("Caught exception in isMediaLocal \(error)")
      failure(nil, "isMediaLocal failed", nil)
    }
  }

  // MARK: - CRUD
  // MARK: (Public)
  public func create(params: NSDictionary, success: (AnyObject?) -> Void,
                     failure: (String?, String?, NSError?) -> Void) -> Bool {
    if let serviceUrl = params["serviceUrl"] as? String {

      let serviceEndpoint = URL(string: serviceUrl)!
      let sapURLSession = OAuthRequestor.sharedInstance.urlSession
      let provider = OnlineODataProvider(serviceRoot: serviceEndpoint, sapURLSession: sapURLSession)
      if let APPID = params["X-SMP-APPID"] as? String {
        provider.httpHeaders.setHeader(withName: "X-SMP-APPID", value: APPID)
      }
      if let token = params["AccessToken"] as? String {
        provider.httpHeaders.setHeader(withName: "Authorization", value: "Bearer \(token)")
      }
      
      onlineService = DataService(provider: provider)
      onlineService?.traceRequests = true
      onlineService?.traceWithData = true

      // TODO: The following 2 lines are a workaround due to server/backend limitations
      // supporting HEAD and MERGE requests
      onlineService?.serviceOptions.supportsPatch = false
      onlineService?.serviceOptions.pingMethod = "GET"
      do {
        // TODO: comment for no need get token
        //try onlineService?.acquireToken()
        //Disable online for now
        online = true
        isOnlineServiceCreated = true
        success(nil)
        return true
      } catch {
        failure(nil, "Service create failed, unable to retrieve security token", error as NSError)
        return false
      }
    } else {
      let errorMsg = "Service create failed, incorrect or incomplete parameter list."
      failure(nil, errorMsg, DataServiceUtils.getError(errorCode: DataServiceUtils.genericErrorCode, errorMessage: errorMsg))
      return false
    }
  }

  public func read(entitySet entity: String, properties: NSArray, queryString: String? = nil, success: (AnyObject?) -> Void,
                   failure: (String?, String?, NSError?) -> Void) {
    func getEntityList(entityName: String, properties: [String], queryString: String?) throws -> EntityValueList {
      // TODO: use readService here, remove duplicate functions
      let query =  try getQuery(entityName: entityName, selectProperties: properties, queryString: queryString, useQueryParser: false)!
      var entityList: EntityValueList? = nil
      if online {
        entityList = try onlineService?.executeQuery(query).entityList()
      } else {
        entityList = try offlineService?.executeQuery(query).entityList()
      }

      if entityName == "ErrorArchive" && !online {
        // SNOWBLIND-3384 - Load the AffectedEntity property into the retrieved entities manually.
        // AffectedEntity is a navigation property and therefore isn't loaded into the entity by defult.
        // Unlike most other navigation properties, it can't be accessed with $expand because it's a
        // "built-in" entity set of the Offline OData SDK. Load this property by default.
        for entityValue in entityList! {
          let affectedEntityNavProp = entityValue.entityType.property(withName: "AffectedEntity")
          try offlineService?.loadProperty(affectedEntityNavProp, into: entityValue)
        }
      }
      return entityList!
    }

    guard !(entity.isEmpty) else {
      return
    }

    do {
      if let propertiesString = properties as? [String] {
        let filteredQueryString = try filterQueryOptions(for: entity, queryOptions: queryString)
        let list = try getEntityList(entityName: entity, properties: propertiesString, queryString: filteredQueryString)
        success(list.toJson(getDataContext()) as AnyObject?)
      }
    } catch {
      failure(nil, "Read EntitySet failed", error as NSError?)
    }
  }
  
  /**
   * Remove $top from query string params in cases where it would cause
   * the OData service to throw an error. Only allow $top if the navigation
   * property is an entity list.
   * See the INVALID_USE_OF_TOP error in the Offline OData repo.
   */
  private func filterQueryOptions(for entitySetString: String, queryOptions: String?) throws -> String? {
    var stringToFilter = entitySetString
    if stringToFilter.hasPrefix("/") {
      // local entity read link
      stringToFilter.remove(at: stringToFilter.startIndex)
    }
    // Only filter queries that are trying to access a navigation property.re trying to access a navigation property.
    if stringToFilter.index(of:"/") != nil {
      let splitEntitySet = stringToFilter.components(separatedBy: "/")
      let sourceEntitySetName = splitEntitySet[0].components(separatedBy: "(")[0]
      let navigationPropertyName = splitEntitySet[splitEntitySet.endIndex - 1]
      if let entitySet = try offlineService?.entitySet(withName: sourceEntitySetName),
        let queryOptions = queryOptions {
        let navigationProperty = entitySet.entityType.navigationProperties.first(where: { $0.name == navigationPropertyName })
        if navigationProperty != nil
        && !navigationProperty!.type.isEntityList {
          let queryParams = queryOptions.components(separatedBy: "&")
          let queryParamsWithoutTop = queryParams.filter({ $0.range(of:"$top") == nil })
          // An empty string for query options causes issues, so return nil if empty string
          return queryParamsWithoutTop.count > 0 ? queryParamsWithoutTop.joined(separator: "&") : nil
        }
      }
    }
    return queryOptions
  }

  public func createEntity(odataCreator: ODataCreator) throws -> Any {
    return try odataCreator.execute(offlineService: offlineService, changeSetManager: changeSetManager)
  }

  public func updateEntity(odataUpdater: ODataUpdater) throws -> Any {
    return try odataUpdater.execute(offlineService: offlineService, changeSetManager: changeSetManager)
  }

  public func deleteEntity(odataDeleter: ODataDeleter) throws -> Any {
    return try odataDeleter.execute(offlineService: offlineService, changeSetManager: changeSetManager)
  }

  public func deleteMediaEntity(entitySetName: String, readLink: String) throws -> Any {

    func deleteStream(entity: EntityValue) throws {
      if online {
        try self.onlineService?.deleteStream(entity: entity, link: entity.mediaStream, headers: (self.onlineService?.httpHeaders)!)
      } else {
        try self.offlineService?.deleteStream(entity: entity, link: entity.mediaStream)
      }
    }

    let entity = try getEntityUsingReadLink(readLink, entitySetName: entitySetName)
    try deleteStream(entity: entity)
    return entity.toJson(getDataContext()) as AnyObject
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

  // swiftlint:disable function_body_length
  // swiftlint:disable:next function_parameter_count
  public func createMediaEntity(entitySetName: String, properties: NSDictionary, headers: NSDictionary?, isOnlineRequest: Bool,
                                media: NSArray,
                                success: @escaping (AnyObject?) -> Void,
                                failure: @escaping (String?, String?, NSError?) -> Void) {

    var entities: [AnyObject] = []

    func getMediaContents(withMedia media: NSArray) -> [SAPOData.ByteStream]? {

      var contents: [SAPOData.ByteStream] = []
      for mediaData in media {
        guard let mediaDict =  mediaData as? NSDictionary else {
          return nil
        }
        if let mediaData = mediaDict["content"] as? Data, let contentType = mediaDict["contentType"] as? String {
          let content = ByteStream.fromBinary(data: mediaData)
          content.mediaType = contentType
          contents.append(content)
        } else {
          return nil
        }

      }
      return contents
    }

    func getErrorMessage(withErrors errors: [String], mediaNum: Int) -> String {
      var errorMsg = ""
      for error in errors {
        errorMsg = "\(errorMsg)\(error),"
      }
      return "\(errors.count) of \(mediaNum) Create Media Entity failed. Reasons [\(errorMsg)]"
    }

    func createMedia(entitySet: EntitySet, mediaContents: [SAPOData.ByteStream], properties: NSDictionary, headers: NSDictionary? ) throws -> [String] {
      let entityType: EntityType = entitySet.entityType
      var errors: [String] = []
      for mediaContent in mediaContents {
        let entity = EntityValue.ofType(entityType)
        guard let properties = properties as? [String: String] else {
          throw ODataErrors.genericError("createMedia properties have the wrong format")
        }
        try entity.setProperties(properties)
        do {
          if isOnlineRequest {
            try self.onlineService?.createMedia(entity: entity, content: mediaContent, headers: getHttpHeaders(headers: headers))
          } else {
            try self.offlineService?.createMedia(entity: entity, content: mediaContent, headers: getHttpHeaders(headers: headers))
          }
          print(entity.toString())
          entities.append(entity.toJson(getDataContext())! as AnyObject)
        } catch ODataErrors.genericError(let errorMsg) {
          let errorMessage = "Create Media Entity failed, \(errorMsg)"
          failure(nil, errorMessage, DataServiceUtils.getError(errorCode: DataServiceUtils.genericErrorCode, errorMessage: errorMessage))
        } catch {
          print ("Caught exception \(error)")
          errors.append(error.localizedDescription)
        }
      }
      return errors

    }

    guard let mediaContents = getMediaContents(withMedia: media) else {
      let errorMsg = "Create Media Entity failed, media contents not valid"
      failure(String(DataServiceUtils.genericErrorCode), errorMsg, DataServiceUtils.getError(errorCode: DataServiceUtils.genericErrorCode, errorMessage: errorMsg))
      return
    }

    do {
      guard let entitySet: EntitySet = try getEntitySet(withName: entitySetName, forceOnline: isOnlineRequest) else {
        let errorMsg = "Create Media Entity failed: Entity Set does not exist in service"
        failure(nil, errorMsg, DataServiceUtils.getError(errorCode: DataServiceUtils.genericErrorCode, errorMessage: errorMsg))
        return
      }

      let errors = try createMedia(entitySet: entitySet, mediaContents: mediaContents, properties: properties, headers: headers)

      if errors.count == 0 {
        success(entities as AnyObject?)
      } else {
        let errorMsg = getErrorMessage(withErrors: errors, mediaNum: mediaContents.count)
        failure(String(DataServiceUtils.genericErrorCode), errorMsg, DataServiceUtils.getError(errorCode: DataServiceUtils.genericErrorCode, errorMessage: errorMsg))
      }

    } catch ODataErrors.genericError(let errorMsg) {
      let errorMessage = "Create Media Entity failed, \(errorMsg)"
      failure(nil, errorMessage, DataServiceUtils.getError(errorCode: DataServiceUtils.genericErrorCode, errorMessage: errorMessage))
    } catch {
      print ("Caught exception \(error)")
      failure(String(DataServiceUtils.genericErrorCode), "Create Entity failed, unexpected exception", error as NSError?)
    }

  }

  // MARK: - ODATA UTILS

  private func getEntitySet(withName entitySetName: String, forceOnline: Bool = false) throws -> EntitySet? {
    if online || forceOnline {
      return try onlineService?.entitySet(withName: entitySetName)
    } else {
      return try offlineService?.entitySet(withName: entitySetName)
    }
  }

  private func getQuery(entityName: String, selectProperties: [String], queryString: String?, useQueryParser: Bool, forCount: Bool = false) throws -> DataQuery? {

    let containsLeadingAndTrailingBracketPattern = "\\(.*\\)"
    let isReadLink = (entityName.range(of: containsLeadingAndTrailingBracketPattern, options: .regularExpression) != nil)

    var query: DataQuery = DataQuery()

    // query.url should not be set manually as other settings may be ignored - original comment
    // since this issue has gone in circles leaving the example code here
    // just in case the odata folks tell us to put it back, as we're now
    // being told to set the url manually, unreal!
    //
    // setting query.url manually fixes a variety of issues including but
    // not limited to:
    // sap.isLocal no longer worked
    // selectedProperties no longer worked
    // possibly others because obviously query parser can't handle them all!
    //
    // here's code for that:
    //    if var queryString = queryString {
    //
    //      let queryContext = getDataContext()
    //
    //      if !queryString.hasPrefix("?") {
    //        queryString = "?" + queryString
    //      }
    //
    //      try query = QueryParser.init(context: queryContext).parse(requestPath: entityName, queryString: queryString)
    //    }

    // we really shouldn't be setting query.url directly, see https://issues.oasis-open.org/browse/ODATA-1033

    if useQueryParser {
      var queryString = queryString
      let queryContext = getDataContext()
      
      if (queryString != nil) && !queryString!.hasPrefix("?") {
        queryString = "?" + queryString!
      }
      try query = QueryParser.init(context: queryContext).parse(requestPath: entityName, queryString: queryString)
    } else {
      let queryUrl = (forCount) ? "\(entityName)/$count" : "\(entityName)"
      if queryString == nil {
        query.url = queryUrl
      } else {
        query.url = "\(queryUrl)?\(queryString!)"
      }
    }

    let entitySet: EntitySet

    if isReadLink == true {
      query.entityKey = EntityKey()

      let bracket = "("
      var token = entityName.components(separatedBy: bracket)
      var entityNameFromReadLink = token[0]

      if entityNameFromReadLink.hasPrefix("/") {
        // local entity read link
        entityNameFromReadLink.remove(at: entityNameFromReadLink.startIndex)
      }

      if online {
        entitySet = try (onlineService?.entitySet(withName: entityNameFromReadLink))!
      } else {
        entitySet = try (offlineService?.entitySet(withName: entityNameFromReadLink))!
      }
    } else {
      if online {
        entitySet = try (onlineService?.entitySet(withName: entityName))!
      } else {
        entitySet = try (offlineService?.entitySet(withName: entityName))!
      }
    }

    query = query.from(entitySet)

    let entityType: EntityType = entitySet.entityType
    if selectProperties.count != 0 {
      for prop in selectProperties {
        query = query.select(entityType.property(withName: prop))
      }
    }
    return query
  }

  private func getEntityUsingReadLink(_ readLink: String, entitySetName: String) throws -> EntityValue {

    guard let entitySet = try getEntitySet(withName: entitySetName) else {
      throw ODataErrors.genericError("EntitySet \(entitySetName) does not exist")
    }

    let entity = EntityValue.ofType(entitySet.entityType)

    entity.readLink = readLink

    try offlineService?.loadEntity(entity)

    return entity
  }

  private func getDataContext() -> DataContext {
    return DataContext(csdl: (online ? onlineService?.metadata : offlineService?.metadata)!)
  }

  // swiftlint:enable function_body_length

  // MARK: - CHANGESET MANAGEMENT
  public func beginChangeSet(success: @escaping (AnyObject?) -> Void, failure: @escaping (String?, String?, NSError?) -> Void) -> Void {
    do {
      try changeSetManager.beginChangeSet()
      success(true as AnyObject)

    } catch ODataErrors.genericError(let errorMsg) {
      let errorMessage = "Begin change set failed, \(errorMsg)"
      failure(nil, errorMessage, DataServiceUtils.getError(errorCode: DataServiceUtils.genericErrorCode, errorMessage: errorMessage))
    } catch {
      print ("Unexpected exception caught \(error)")
      failure(nil, "beginChangeSet failed", error as NSError?)
    }
  }

  public func cancelChangeSet(success: @escaping (AnyObject?) -> Void, failure: @escaping (String?, String?, NSError?) -> Void) -> Void {
    changeSetManager.cancelChangeSet()
    success(true as AnyObject)
  }

  public func commitChangeSet(success: @escaping (AnyObject?) -> Void, failure: @escaping (String?, String?, NSError?) -> Void) -> Void {
    do {
      try changeSetManager.commitChangeSet()
      success(true as AnyObject)

    } catch ODataErrors.genericError(let errorMsg) {
      let errorMessage = "Commit change set failed, \(errorMsg)"
      failure(nil, errorMessage, DataServiceUtils.getError(errorCode: DataServiceUtils.genericErrorCode, errorMessage: errorMessage))
    } catch {
      failure(nil, "commitChangeSet failed", error as NSError?)
    }
  }

  public func count(entitySet entity: String, properties: NSArray, queryString: String? = nil, success: (AnyObject?) -> Void,
                   failure: (String?, String?, NSError?) -> Void) {

    func getCount(entityName: String, properties: [String], queryString: String?) throws -> Int64? {
      let query = try getQuery(entityName: entityName, selectProperties: properties, queryString: queryString, useQueryParser: false, forCount: true)!
      query.countOnly = true
      if online {
        return try onlineService?.executeQuery(query).count()
      } else {
        print("QueryFormatter: \(QueryFormatter.format(query: query, context: getDataContext()))")
        return try offlineService?.executeQuery(query).count()
      }
    }
    
    guard !(entity.isEmpty) else {
      let errorMsg = "Count failed, entitySet not provided."
      failure(nil, errorMsg, DataServiceUtils.getError(errorCode: DataServiceUtils.genericErrorCode, errorMessage: errorMsg))
      return
    }
    
    do {
      if let propertiesString = properties as? [String],
        let count = try getCount(entityName: entity, properties: propertiesString, queryString: queryString) {
        success(count as AnyObject?)
      }
    } catch {
      print(error)
      failure(nil, "count failed", error as NSError?)
    }
  }
}
