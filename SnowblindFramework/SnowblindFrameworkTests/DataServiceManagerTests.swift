//
//  DataServiceManagerTests.swift
//  SnowblindClient
//
//  Created by Mehta, Kunal on 9/9/16.
//  Copyright © 2016 sap. All rights reserved.
//

import XCTest
import SAPOData
import SAPOfflineOData

@testable import SAPMDC

// swiftlint:disable file_length
// swiftlint:disable type_body_length
let readEntitySet: String = "NorthwindModel.Product"
let readProperties: NSArray = ["ProductName"]
class DataServiceManagerTests: XCTestCase {

  let amwParams: NSDictionary = ["serviceUrl": "https://hcpms-i839015trial.hanatrial.ondemand.com/com.sap.amw/"]
  let amw2Params: NSDictionary = ["serviceUrl": "https://hcpms-i839015trial.hanatrial.ondemand.com/com.sap.amw2/"]
  let openParams: NSDictionary = ["serviceUrl": "http://mock.host/mock.service/",
                                  "username": "mehtaku", "password": "Syclo123!"]
  let readParams: NSDictionary = ["serviceUrl": "http://mock.host/mock.service/",
                                  "entitySet": readEntitySet, "properties": readProperties]
  var provider: MockDataProvider?
  var onlineODataProvider: MockOnlineODataProvider?

  override func setUp() {
    super.setUp()
    // Put setup code here. This method is called before the invocation of each test method in the class.
    DataServiceManager.sharedInstance.dataProviders.removeAll()
    provider = MockDataProvider()
    onlineODataProvider = MockOnlineODataProvider(serviceName: "mock", serviceRoot: "http://mock.host/mock.service/")
    do {
      try onlineODataProvider?.loadMetadata()
    } catch {
      print("Mock provider could not load metadata")
    }
  }

  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
  }

  func testSingleton() {
    let firstInstance = DataServiceManager.sharedInstance
    let secondInstance = DataServiceManager.sharedInstance

    XCTAssert(firstInstance == secondInstance)
  }

  func testCreateOneService() {
    let createExpectation: XCTestExpectation = expectation(description: "Create expectation")

    DataServiceManager.sharedInstance.create(provider: provider!, params: amwParams,
      resolve: { (_) in
        createExpectation.fulfill()
        XCTAssertNotNil(DataServiceManager.sharedInstance.dataProviders["com.sap.amw"])
        XCTAssert(provider?.params == amwParams)
      },
      reject: { (_: String?, message: String?, _: Error?) in
        createExpectation.fulfill()
        XCTFail("\(String(describing: message))")
      }
    )

    waitForExpectations(timeout: 10) { error in
      if let error = error {
        print("Error: \(error.localizedDescription)")
      }
    }
  }

  func testOpenService() {
    DataServiceManager.sharedInstance.dataProviders["mock.service"] = provider

    // open service
    let openExpectation: XCTestExpectation = self.expectation(description: "Open expectation")

    DataServiceManager.sharedInstance.open(params: openParams, resolve: { (_) in
      XCTAssert(provider!.params == openParams)
      openExpectation.fulfill()
    }, reject: { (_: String?, message: String?, _: Error?) in
      openExpectation.fulfill()
      XCTFail("\(String(describing: message))")
    })

    waitForExpectations(timeout: 10) { error in
      if let error = error {
        print("Error: \(error.localizedDescription)")
      }
    }

  }

  func testReadValidCollection() {
    DataServiceManager.sharedInstance.dataProviders["mock.service"] = provider

    // open service
    let openExpectation: XCTestExpectation = self.expectation(description: "Open expectation")

    DataServiceManager.sharedInstance.open(params: openParams, resolve: { (_) in
      openExpectation.fulfill()
      XCTAssert(provider!.params == openParams)

      // read service
      DataServiceManager.sharedInstance.read(params: readParams, resolve: { (_: Any?) in
        XCTAssert(provider!.entitySetStr == readEntitySet)
        XCTAssert(provider!.propertiesArr == readProperties)
      }, reject: { (_: String?, message: String?, _: Error?) in
        XCTFail("\(String(describing: message))")
      })

    }, reject: { (_: String?, message: String?, _: Error?) in
      openExpectation.fulfill()
      XCTFail("\(String(describing: message))")
    })

    waitForExpectations(timeout: 10) { error in
      if let error = error {
        print("Error: \(error.localizedDescription)")
      }
    }
  }

  func testReadValidCollectionWithSubset() {
    let entitySet: String = "Products(1)"
    let properties: NSArray = []
    let readWithSubsetParams: NSDictionary = [
      "serviceUrl": "http://mock.host/mock.service/",
      "entitySet": entitySet,
      "properties": properties]

    let testProvider = OnlineODataProviderReadMock(serviceName: "mock", serviceRoot: "http://mock.host/mock.service/")
    do {
      try testProvider.loadMetadata()
    } catch {
      print("Mock provider could not load metadata")
    }
    DataServiceManager.sharedInstance.dataProviders["mock.service"] = provider
    // open service
    let openExpectation: XCTestExpectation = self.expectation(description: "Open expectation")

    DataServiceManager.sharedInstance.open(params: openParams, resolve: { (_) in
      openExpectation.fulfill()
      XCTAssert(provider!.params == openParams)

      // read service
      DataServiceManager.sharedInstance.read(params: readWithSubsetParams, resolve: { (_: Any?) in
        XCTAssert(provider!.entitySetStr == entitySet)
        XCTAssert(provider!.propertiesArr == properties)
      }, reject: { (_: String?, message: String?, _: Error?) in
        XCTFail("\(String(describing: message))")
      })
    }, reject: { (_: String?, message: String?, _: Error?) in
      openExpectation.fulfill()
      XCTFail("\(String(describing: message))")
    })

    waitForExpectations(timeout: 10) { error in
      if let error = error {
        print("Error: \(error.localizedDescription)")
      }
    }
  }

  func testReadValidCollectionWithQueryString() {
    let entitySet: String = "Products"
    let properties: NSArray = []
    let queryString: String = "$filter=%27Price%27%20gt%20%2710%27"
    let readWithQueryStringParams: NSDictionary = [
      "serviceUrl": "http://mock.host/mock.service/",
      "entitySet": entitySet,
      "properties": properties,
      "queryOptions": queryString]

    let testProvider = OnlineODataProviderReadMock(serviceName: "mock", serviceRoot: "http://mock.host/mock.service/")
    do {
      try testProvider.loadMetadata()
    } catch {
      print("Mock provider could not load metadata")
    }
    DataServiceManager.sharedInstance.dataProviders["mock.service"] = provider

    // open service
    let openExpectation: XCTestExpectation = self.expectation(description: "Open expectation")

    DataServiceManager.sharedInstance.open(params: openParams, resolve: { (_) in
      openExpectation.fulfill()

      // read service
      DataServiceManager.sharedInstance.read(params: readWithQueryStringParams, resolve: { (_: Any?) in
        XCTAssert(provider!.entitySetStr == entitySet)
        XCTAssert(provider!.propertiesArr == properties)
        XCTAssert(provider!.queryString == queryString)
      }, reject: { (_: String?, message: String?, _: Error?) in
        XCTFail("\(String(describing: message))")
      })
    }, reject: { (_: String?, message: String?, _: Error?) in
      openExpectation.fulfill()
      XCTFail("\(String(describing: message))")
    })

    waitForExpectations(timeout: 10) { error in
      if let error = error {
        print("Error: \(error.localizedDescription)")
      }
    }
  }

  func testReadEmptyPropertiesArray() {
    DataServiceManager.sharedInstance.dataProviders["mock.service"] = provider

    // open service
    let openExpectation: XCTestExpectation = self.expectation(description: "Open expectation")
    DataServiceManager.sharedInstance.open(params: openParams, resolve: { (_) in
      openExpectation.fulfill()
      let entitySet: String = "NorthwindModel.Product"
      let properties: NSArray = []
      let emptyPropsArray: NSDictionary = ["serviceUrl": "http://mock.host/mock.service/",
                                           "entitySet": entitySet, "properties": properties]

      //read service
      DataServiceManager.sharedInstance.read(params: emptyPropsArray, resolve: { (_: Any?) in
        XCTAssertTrue(entitySet == provider!.entitySetStr)
        XCTAssertTrue(properties == provider!.propertiesArr)
      }, reject: { (_: String?, message: String?, _: Error?) in
        XCTFail("\(String(describing: message))")
      })

    }, reject: { (_: String?, message: String?, _: Error?) in
      openExpectation.fulfill()
      XCTFail("\(String(describing: message))")
    })

    waitForExpectations(timeout: 10) { error in
      if let error = error {
        print("Error: \(error.localizedDescription)")
      }
    }
  }

//  func testUpdateWithValidParameters() {
//    DataServiceManager.sharedInstance.dataProviders["mock.service"] = provider
//
//    // open service
//    let openExpectation: XCTestExpectation = self.expectation(description: "Open expectation")
//    DataServiceManager.sharedInstance.open(params: openParams, resolve: { (_) in
//      openExpectation.fulfill()
//
//      //update service
//      let updateParams : NSDictionary = ["serviceUrl": "http://mock.host/mock.service/",
//                                         "entitySet": "NorthwindModel.Product",
//                                         "properties": ["ProductName": "Milk - updated" as AnyObject, "ProductID": 0 as AnyObject],
//                                         "keyProperties": ["ProductID"],
//                                         "updateLinks": []]
//      DataServiceManager.sharedInstance.update(params:updateParams, resolve: { (_: Any?) in
//      }, reject: { (_: String?, _: String?, _: Error?) in
//        XCTFail()
//      })
//
//    }, reject: { (_: String?, message: String?, _: Error?) in
//      openExpectation.fulfill()
//      XCTFail("\(message)")
//    })
//
//    waitForExpectations(timeout: 10) { error in
//      if let error = error {
//        print("Error: \(error.localizedDescription)")
//      }
//    }
//  }

  func testGetServiceName() {
    XCTAssertTrue(DataServiceUtils.getServiceName(serviceUrl: "http://myservice.sap.com/testservice") == "testservice")
    XCTAssertNil(DataServiceUtils.getServiceName(serviceUrl: ""))
    XCTAssertNil(DataServiceUtils.getServiceName(serviceUrl: "http://"))
    XCTAssertNil(DataServiceUtils.getServiceName(serviceUrl: "https://hcpms-i839015trial.hanatrial.ondemand.com/"))
  }

//  func testCreateEntity() {
//    let expectedMessage = "Could not find service provider"
//    let serviceUrl = "http://mock.host/mock.service/"
//    let entitySet = "NorthwindModel.Product"
//    let properties = ["ProductName": "Bread" as AnyObject]
//
//    let invalidServiceUrl: NSDictionary = ["serviceUrl": 123, "entitySet": entitySet, "properties": properties]
//    createEntityeWithInvalidParams(param: invalidServiceUrl, expectedMessage: expectedMessage)
//
//    let invalidEntity: NSDictionary = ["serviceUrl": serviceUrl, "entitySet": 123, "properties": properties]
//    createEntityeWithInvalidParams(param: invalidEntity, expectedMessage: expectedMessage)
//
//    let invalidProps: NSDictionary = ["serviceUrl": serviceUrl, "entitySet": entitySet, "properties": 123]
//    createEntityeWithInvalidParams(param: invalidProps, expectedMessage: expectedMessage)
//
//    let validProps: NSDictionary = ["serviceUrl": serviceUrl, "entitySet": entitySet, "properties": properties, "createLinks": []]
//    createEntityWithValidParameters(param: validProps)
//
//  }

  func createEntityeWithInvalidParams(param: NSDictionary, expectedMessage: String) {
    DataServiceManager.sharedInstance.dataProviders["mock.service"] = provider

    // open service
    let openExpectation: XCTestExpectation = self.expectation(description: "Open expectation")
    DataServiceManager.sharedInstance.open(params: openParams, resolve: { (_) in
      openExpectation.fulfill()

      DataServiceManager.sharedInstance.createEntity(params: param, resolve: { (_: Any?) in
        XCTFail("Create entity should fail")
      }, reject: { (_: String?, message: String?, _: Error?) in
        XCTAssertTrue(message == expectedMessage, "error message: expected: \(expectedMessage) actual: \(String(describing: message))")
      })

    }, reject: { (_: String?, message: String?, _: Error?) in
      openExpectation.fulfill()
      XCTFail("\(String(describing: message))")
    })

    waitForExpectations(timeout: 10) { error in
      if let error = error {
        print("Error: \(error.localizedDescription)")
      }
    }
  }

  func createEntityWithValidParameters(param: NSDictionary) {
    DataServiceManager.sharedInstance.dataProviders["mock.service"] = provider

    // open service
    let openExpectation: XCTestExpectation = self.expectation(description: "Open expectation")
    DataServiceManager.sharedInstance.open(params: openParams, resolve: { (_) in
      openExpectation.fulfill()

      DataServiceManager.sharedInstance.createEntity(params:param, resolve: { (_: Any?) in
      }, reject: { (_: String?, _: String?, _: Error?) in
        XCTFail("Create entity should NOT fail")
      })

    }, reject: { (_: String?, message: String?, _: Error?) in
      openExpectation.fulfill()
      XCTFail("\(String(describing: message))")
    })

    waitForExpectations(timeout: 10) { error in
      if let error = error {
        print("Error: \(error.localizedDescription)")
      }
    }
  }

//  func testCreateEntityWithValidLink() {
//    let serviceUrl = "http://mock.host/mock.service/"
//    let entitySet = "NorthwindModel.Product"
//    let properties = ["ProductName": "Bread" as AnyObject]
//    var createLinkDictionary1 = [String: Any]()
//    createLinkDictionary1["property"] = "EquipmentOP"
//    createLinkDictionary1["entitySet"] = "Operation"
//    createLinkDictionary1["queryOptions"] = "EquipID eq 123"
//
//    var createLinkDictionary2 = [String: Any]()
//    createLinkDictionary2["property"] = "FLOP"
//    createLinkDictionary2["entitySet"] = "Operation"
//    createLinkDictionary2["queryOptions"] = "FLID eq 123"
//
//    let createLinks = [createLinkDictionary1, createLinkDictionary2]
//
//    let validLinks: NSDictionary = ["serviceUrl": serviceUrl, "entitySet": entitySet, "properties": properties, "createLinks": createLinks]
//    let expectedCreateLinks = "[[\"QueryOptions\": \"EquipID eq 123\", \"Property\": \"EquipmentOP\", \"EntitySet\": \"Operation\"],"
//      + " [\"QueryOptions\": \"FLID eq 123\", \"Property\": \"FLOP\", \"EntitySet\": \"Operation\"]]"
//    createEntityLinkWithValidLinks(param: validLinks, expecteValue: expectedCreateLinks)
//
//    let emptyLinks: NSDictionary = ["serviceUrl": serviceUrl, "entitySet": entitySet, "properties": properties, "createLinks": []]
//    createEntityLinkWithValidLinks(param: emptyLinks, expecteValue: "[]")
//  }

  func testCreateEntityWithInvalidLinks() {
    let serviceUrl = "http://mock.host/mock.service/"
    let entitySet = "NorthwindModel.Product"
    let properties = ["ProductName": "Bread" as AnyObject]

    var createLinkDictionary = [String: Any]()
    createLinkDictionary["Property"] = 123
    createLinkDictionary["EntitySet"] = "Operation"
    createLinkDictionary["QueryOptions"] = "FLID eq 123"
    var createLinks = [createLinkDictionary]
    var inValidLinks: NSDictionary = ["serviceUrl": serviceUrl, "entitySet": entitySet, "properties": properties, "createLinks": createLinks]
    createEntityLinkWithInValidLinks(param: inValidLinks)

    createLinkDictionary["Propert"] = "FLOP"
    createLinkDictionary["EntitySet"] = true
    createLinkDictionary["QueryOptions"] = "FLID eq 123"
    createLinks = [createLinkDictionary]
    inValidLinks = ["serviceUrl": serviceUrl, "entitySet": entitySet, "properties": properties, "createLinks": createLinks]
    createEntityLinkWithInValidLinks(param: inValidLinks)

    createLinkDictionary["Propert"] = "FLOP"
    createLinkDictionary["EntitySet"] = "Operation"
    createLinkDictionary["QueryOptions"] = 45
    createLinks = [createLinkDictionary]
    inValidLinks = ["serviceUrl": serviceUrl, "entitySet": entitySet, "properties": properties, "createLinks": createLinks]
    createEntityLinkWithInValidLinks(param: inValidLinks)
  }

  func createEntityLinkWithValidLinks(param: NSDictionary, expecteValue: String) {
    DataServiceManager.sharedInstance.dataProviders["mock.service"] = provider
    // open service
    let openExpectation: XCTestExpectation = self.expectation(description: "Open expectation")
    DataServiceManager.sharedInstance.open(params: openParams, resolve: { (_) in
      openExpectation.fulfill()

      DataServiceManager.sharedInstance.createEntity(params:param, resolve: { (_: Any?) in
      }, reject: { (_: String?, _: String?, _: Error?) in
        XCTFail("Create entity should NOT fail")
      })
      XCTAssertTrue(provider?.createLinks?.description == expecteValue,
                    "error message: expected: \(expecteValue) actual: \(String(describing: provider?.createLinks?.description))")

    }, reject: { (_: String?, message: String?, _: Error?) in
      openExpectation.fulfill()
      XCTFail("\(String(describing: message))")
    })

    waitForExpectations(timeout: 10) { error in
      if let error = error {
        print("Error: \(error.localizedDescription)")
      }
    }
  }

  func createEntityLinkWithInValidLinks(param: NSDictionary) {
    DataServiceManager.sharedInstance.dataProviders["mock.service"] = provider
    // open service
    let openExpectation: XCTestExpectation = self.expectation(description: "Open expectation")
    DataServiceManager.sharedInstance.open(params: openParams, resolve: { (_) in
      openExpectation.fulfill()

      DataServiceManager.sharedInstance.createEntity(params:param, resolve: { (_: Any?) in
        XCTFail("Create entity should fail")
      }, reject: { (_: String?, _: String?, _: Error?) in

      })

    }, reject: { (_: String?, message: String?, _: Error?) in
      openExpectation.fulfill()
      XCTFail("\(String(describing: message))")
    })

    waitForExpectations(timeout: 10) { error in
      if let error = error {
        print("Error: \(error.localizedDescription)")
      }
    }
  }

  // Download tests
  func testDownload() {
    let missingServiceUrl: NSDictionary = ["junk": "ABC123"]
    let expectedMessageForMissingUrl = "serviceUrl missing from definition"
    downloadWithInvalidParams(param: missingServiceUrl, expectedMessage: expectedMessageForMissingUrl)

    let serviceUrlMissingApp: NSDictionary = ["serviceUrl": "http://mock.host/"]
    let expectedMessageForMissingApp = "serviceName missing from serviceUrl"
    downloadWithInvalidParams(param: serviceUrlMissingApp, expectedMessage: expectedMessageForMissingApp)

    let serviceUrlUnknownApp: NSDictionary = ["serviceUrl": "http://mock.host/bogus_app"]
    let expectedMessageForUnknownApp = "Offline OData Store needs to be initialized"
    downloadWithInvalidParams(param: serviceUrlUnknownApp, expectedMessage: expectedMessageForUnknownApp)

    let goodService: NSDictionary = ["serviceUrl": "http://mock.host/mock.service/"]
    downloadWithValidParams(param: goodService)
  }

  func downloadWithInvalidParams(param: NSDictionary, expectedMessage: String) {
    let downloadExpectation: XCTestExpectation = self.expectation(description: "Download expectation")

    DataServiceManager.sharedInstance.dataProviders["mock.service"] = provider

    DataServiceManager.sharedInstance.download(params: param, resolve: { (_: Any?) in
      XCTFail("Download should fail")
    }, reject: { (_: String?, message: String?, _: Error?) in
      XCTAssertTrue(message == expectedMessage, "error message: expected: \(expectedMessage) actual: \(String(describing: message))")
      downloadExpectation.fulfill()
    })

    waitForExpectations(timeout: 10) { error in
      if let error = error {
        print("Error: \(error.localizedDescription)")
      }
    }
  }

  func downloadWithValidParams(param: NSDictionary) {
    let downloadExpectation: XCTestExpectation = self.expectation(description: "Download expectation")
    DataServiceManager.sharedInstance.dataProviders["mock.service"] = provider

    DataServiceManager.sharedInstance.download(params:param, resolve: { (_: Any?) in
      downloadExpectation.fulfill()
    }, reject: { (_: String?, _: String?, _: Error?) in
      XCTFail("Download entity should NOT fail")
    })

    waitForExpectations(timeout: 10) { error in
      if let error = error {
        print("Error: \(error.localizedDescription)")
      }
    }
  }

  // Initialize tests
  func testInitialize() {
    let initExpectation: XCTestExpectation = expectation(description: "Initialize expectation")

    DataServiceManager.sharedInstance.initOfflineStore(provider: provider!, params: amwParams,
      resolve: { (_) in
        initExpectation.fulfill()
        XCTAssertNotNil(DataServiceManager.sharedInstance.dataProviders["com.sap.amw"])
        XCTAssert(self.provider?.params == self.amwParams)
      },
      reject: { (_: String?, message: String?, _: Error?) in
        initExpectation.fulfill()
        XCTFail("\(String(describing: message))")
      }
    )

    waitForExpectations(timeout: 10) { error in
      if let error = error {
        print("Error: \(error.localizedDescription)")
      }
    }
  }

  // Close tests
  func testClose() {
    let closeExpectation: XCTestExpectation = expectation(description: "Close expectation")

    DataServiceManager.sharedInstance.initOfflineStore(provider: provider!, params: amwParams,
      resolve: { (_) in
        DataServiceManager.sharedInstance.close(params: ["serviceUrl": self.amwParams["serviceUrl"]!], resolve: { (_) in
          closeExpectation.fulfill()
          XCTAssert(DataServiceManager.sharedInstance.dataProviders["com.sap.amw"] != nil)
        }, reject: { (_: String?, message: String?, _: Error?) in
          closeExpectation.fulfill()
          XCTFail("\(String(describing: message))")
        })
      },
      reject: { (_: String?, message: String?, _: Error?) in
        closeExpectation.fulfill()
        XCTFail("\(String(describing: message))")
      }
    )

    waitForExpectations(timeout: 10) { error in
      if let error = error {
        print("Error: \(error.localizedDescription)")
      }
    }
  }

  func testClear() {
    let clearExpectation: XCTestExpectation = expectation(description: "Clear expectation")

    DataServiceManager.sharedInstance.initOfflineStore(provider: provider!, params: amwParams,
      resolve: { (_) in
        DataServiceManager.sharedInstance.clear(params: ["serviceUrl": self.amwParams["serviceUrl"]!], resolve: { (_) in
          clearExpectation.fulfill()
          XCTAssertNil(DataServiceManager.sharedInstance.dataProviders["com.sap.amw"])
        }, reject: { (_: String?, message: String?, _: Error?) in
          clearExpectation.fulfill()
          XCTFail("\(String(describing: message))")
        })
      },
      reject: { (_: String?, message: String?, _: Error?) in
        clearExpectation.fulfill()
        XCTFail("\(String(describing: message))")
      }
    )

    waitForExpectations(timeout: 10) { error in
      if let error = error {
        print("Error: \(error.localizedDescription)")
      }
    }
  }

  // Upload tests
  func testUpload() {
    let missingServiceUrl: NSDictionary = ["junk": "ABC123"]
    let expectedMessageForMissingUrl = "serviceUrl missing from definition"
    uploadWithInvalidParams(param: missingServiceUrl, expectedMessage: expectedMessageForMissingUrl)

    let serviceUrlMissingApp: NSDictionary = ["serviceUrl": "http://mock.host/"]
    let expectedMessageForMissingApp = "serviceName missing from serviceUrl"
    uploadWithInvalidParams(param: serviceUrlMissingApp, expectedMessage: expectedMessageForMissingApp)

    let serviceUrlUnknownApp: NSDictionary = ["serviceUrl": "http://mock.host/bogus_app"]
    let expectedMessageForUnknownApp = "Offline OData Store needs to be initialized"
    uploadWithInvalidParams(param: serviceUrlUnknownApp, expectedMessage: expectedMessageForUnknownApp)

    let goodService: NSDictionary = ["serviceUrl": "http://mock.host/mock.service/"]
    uploadWithValidParams(param: goodService)
  }

  func uploadWithInvalidParams(param: NSDictionary, expectedMessage: String) {
    let uploadExpectation: XCTestExpectation = self.expectation(description: "Upload expectation")

    DataServiceManager.sharedInstance.dataProviders["mock.service"] = provider

    DataServiceManager.sharedInstance.upload(params: param, resolve: { (_: Any?) in
      XCTFail("Upload should fail")
    }, reject: { (_: String?, message: String?, _: Error?) in
      XCTAssertTrue(message == expectedMessage, "error message: expected: \(expectedMessage) actual: \(String(describing: message))")
      uploadExpectation.fulfill()
    })

    waitForExpectations(timeout: 10) { error in
      if let error = error {
        print("Error: \(error.localizedDescription)")
      }
    }
  }

  func uploadWithValidParams(param: NSDictionary) {
    let uploadExpectation: XCTestExpectation = self.expectation(description: "upload expectation")
    DataServiceManager.sharedInstance.dataProviders["mock.service"] = provider

    DataServiceManager.sharedInstance.upload(params:param, resolve: { (_: Any?) in
      uploadExpectation.fulfill()
    }, reject: { (_: String?, _: String?, _: Error?) in
      XCTFail("Upload entity should NOT fail")
    })

    waitForExpectations(timeout: 10) { error in
      if let error = error {
        print("Error: \(error.localizedDescription)")
      }
    }
  }

  // MARK: createMedia
  func testCreateMedia() {

    let serviceUrl = "http://mock.host/mock.service/"
    let entitySet = "NorthwindModel.Product"
    let properties = ["ProductName": "Bread" as AnyObject]
    let headers = ["header1": "value1"]
    let media = [["content": "contentValue", "contentType": "image/jpeg"]]

    let validProps: NSDictionary = ["serviceUrl": serviceUrl, "entitySet": entitySet, "properties": properties, "headers": headers, "isOnlineRequest": true, "media": media]
    createMediaWithValidParams(param: validProps)

    let expectedMessage = "create Media Entity failed: invalid params"
    let invalidUrl: NSDictionary = ["serviceUrl": 123, "entitySet": entitySet, "properties": properties, "headers": headers, "isOnlineRequest": true, "media": media]
    createMediaWithInvalidParams(param: invalidUrl, expectedMessage: expectedMessage)

    let invalidMedia: NSDictionary = ["serviceUrl": serviceUrl, "entitySet": entitySet, "properties": properties, "headers": headers,
                                      "isOnlineRequest": true, "media": "invalidMedia"]
    createMediaWithInvalidParams(param: invalidMedia, expectedMessage: expectedMessage)

    let invalidMedia2: NSDictionary = ["serviceUrl": serviceUrl, "entitySet": entitySet, "properties": properties, "headers": headers,
                                       "isOnlineRequest": true, "media": []]
    createMediaWithInvalidParams(param: invalidMedia2, expectedMessage: expectedMessage)

    let invalidURL: NSDictionary = ["invalidServiceUrl": serviceUrl, "entitySet": entitySet, "properties": properties, "headers": headers,
                                    "isOnlineRequest": true, "media": []]
    createMediaWithInvalidParams(param: invalidURL, expectedMessage: expectedMessage)

    let invalidEntity: NSDictionary = ["invalidServiceUrl": serviceUrl, "invalidEntitySet1": entitySet, "properties": properties, "headers": headers,
                                       "isOnlineRequest": true, "media": []]
    createMediaWithInvalidParams(param: invalidEntity, expectedMessage: expectedMessage)

    let invalidProperty: NSDictionary = ["ServiceUrl": serviceUrl, "entitySet": entitySet, "properties": "Properties", "headers": headers,
                                         "isOnlineRequest": true, "media": []]
    createMediaWithInvalidParams(param: invalidProperty, expectedMessage: expectedMessage)

    let invalidService: NSDictionary = ["serviceUrl": "invalidService",
                                        "entitySet": entitySet,
                                        "properties": properties,
                                        "headers": headers,
                                        "isOnlineRequest": true,
                                        "media": media]
    createMediaWithInvalidParams(param: invalidService, expectedMessage: "Could not find service provider")

  }

  func createMediaWithValidParams(param: NSDictionary) {
    DataServiceManager.sharedInstance.dataProviders["mock.service"] = provider

    // open service
    let openExpectation: XCTestExpectation = self.expectation(description: "Open expectation")
    DataServiceManager.sharedInstance.open(params: openParams, resolve: { (_) in
      openExpectation.fulfill()

      DataServiceManager.sharedInstance.createMedia(params:param, resolve: { (_: Any?) in
      }, reject: { (_: String?, _: String?, _: Error?) in
        XCTFail("Create entity should NOT fail")
      })

    }, reject: { (_: String?, message: String?, _: Error?) in
      openExpectation.fulfill()
      XCTFail("\(String(describing: message))")
    })

    waitForExpectations(timeout: 10) { error in
      if let error = error {
        print("Error: \(error.localizedDescription)")
      }
    }
  }

  func createMediaWithInvalidParams(param: NSDictionary, expectedMessage: String) {
    DataServiceManager.sharedInstance.dataProviders["mock.service"] = provider

    // open service
    let openExpectation: XCTestExpectation = self.expectation(description: "Open expectation")
    DataServiceManager.sharedInstance.open(params: openParams, resolve: { (_) in
      openExpectation.fulfill()

      DataServiceManager.sharedInstance.createMedia(params: param, resolve: { (_: Any?) in
        XCTFail("Create entity should fail")
      }, reject: { (_: String?, message: String?, _: Error?) in
        XCTAssertTrue(message == expectedMessage, "error message: expected: \(expectedMessage) actual: \(String(describing: message))")
      })

    }, reject: { (_: String?, message: String?, _: Error?) in
      openExpectation.fulfill()
      XCTFail("\(String(describing: message))")
    })

    waitForExpectations(timeout: 10) { error in
      if let error = error {
        print("Error: \(error.localizedDescription)")
      }
    }
  }

//  func testDeleteWithValidParameters() {
//    DataServiceManager.sharedInstance.dataProviders["mock.service"] = provider
//    let openExpectation: XCTestExpectation = self.expectation(description: "Open expectation")
//    DataServiceManager.sharedInstance.open(params: openParams, resolve: { (_) in
//      openExpectation.fulfill()
//      let deleteParams : NSDictionary = ["serviceUrl": "http://mock.host/mock.service/",
//                                         "entitySet": "NorthwindModel.Product",
//                                         "properties": ["ProductID": 0 as AnyObject],
//                                         "keyProperties": ["ProductID"]]
//      DataServiceManager.sharedInstance.deleteEntity(params:deleteParams, resolve: { (_: Any?) in
//      }, reject: { (_: String?, _: String?, _: Error?) in
//        XCTFail()
//      })
//
//    }, reject: { (_: String?, message: String?, _: Error?) in
//      openExpectation.fulfill()
//      XCTFail("\(message)")
//    })
//
//    waitForExpectations(timeout: 10) { error in
//      if let error = error {
//        print("Error: \(error.localizedDescription)")
//      }
//    }
//  }

  // MARK: delete stream
  func testDeleteMedia() {
    let serviceUrl = "http://mock.host/mock.service/"
    let entitySet = "NorthwindModel.Product"
    let readLink = "readLink"

    let validProps: NSDictionary = ["serviceUrl": serviceUrl, "entitySet": entitySet, "properties": [], "readLink": readLink]
    var pros: NSDictionary = ["service": validProps]
    deleteMediaWithValidParams(param: pros)

    var expectedMessage = "Delete Entity failed, Malformed parameter: serviceUrl"
    let invalidUrl: NSDictionary = ["entitySet": entitySet, "properties": [], "readLink": readLink]
    pros = ["service": invalidUrl]
    deleteStreamWithInvalidParams(param: pros, expectedMessage: expectedMessage)

    expectedMessage = "Delete Entity failed, Malformed parameter: entitySet"
    let invalidEntity: NSDictionary = ["serviceUrl": serviceUrl, "invalidEntitySet1": entitySet, "readLink": readLink]
    pros = ["service": invalidEntity]
    deleteStreamWithInvalidParams(param: pros, expectedMessage: expectedMessage)

    expectedMessage = "Delete Entity failed, No data provider exists for serviceName: invalidService"
    let invalidService: NSDictionary = ["serviceUrl": "invalidService", "entitySet": entitySet, "properties": [], "readLink": readLink]
    pros = ["service": invalidService]
    deleteStreamWithInvalidParams(param: pros, expectedMessage: expectedMessage)
  }

  func deleteMediaWithValidParams(param: NSDictionary) {
    DataServiceManager.sharedInstance.dataProviders["mock.service"] = provider

    // open service
    let openExpectation: XCTestExpectation = self.expectation(description: "Open expectation")
    DataServiceManager.sharedInstance.open(params: openParams, resolve: { (_) in
      openExpectation.fulfill()

      DataServiceManager.sharedInstance.deleteMedia(params:param, resolve: { (_: Any?) in
      }, reject: { (_: String?, _: String?, _: Error?) in
        XCTFail("Delete Stream should NOT fail")
      })

    }, reject: { (_: String?, message: String?, _: Error?) in
      openExpectation.fulfill()
      XCTFail("\(String(describing: message))")
    })

    waitForExpectations(timeout: 10) { error in
      if let error = error {
        print("Error: \(error.localizedDescription)")
      }
    }

  }

  func deleteStreamWithInvalidParams(param: NSDictionary, expectedMessage: String) {
    DataServiceManager.sharedInstance.dataProviders["mock.service"] = provider

    // open service
    let openExpectation: XCTestExpectation = self.expectation(description: "Open expectation")
    DataServiceManager.sharedInstance.open(params: openParams, resolve: { (_) in
      openExpectation.fulfill()

      DataServiceManager.sharedInstance.deleteMedia(params: param, resolve: { (_: Any?) in
        XCTFail("Delete Stream should fail")
      }, reject: { (_: String?, message: String?, _: Error?) in
        XCTAssertTrue(message == expectedMessage, "error message: expected: \(expectedMessage) actual: \(String(describing: message))")
      })

    }, reject: { (_: String?, message: String?, _: Error?) in
      openExpectation.fulfill()
      XCTFail("\(String(describing: message))")
    })

    waitForExpectations(timeout: 10) { error in
      if let error = error {
        print("Error: \(error.localizedDescription)")
      }
    }
  }
}
