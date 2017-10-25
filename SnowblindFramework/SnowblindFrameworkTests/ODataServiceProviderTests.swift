//
//  ODataServiceProviderTests.swift
//  SnowblindClient
//
//  Created by Mehta, Kunal on 9/9/16.
//  Copyright © 2016 sap. All rights reserved.
//

import XCTest
import SAPOData
import SAPOfflineOData

@testable import SAPMDC

// swiftlint:disable type_body_length
class ODataServiceProviderTests: XCTestCase {

  var oDataProvider: ODataServiceProvider?
  let dsManager: DataServiceManager = DataServiceManager.sharedInstance
  let openParams: NSDictionary = ["serviceUrl": "http://mock.host/mock.service/",
                                  "username": "mehtaku", "password": "Syclo123!"]
  var mockProvider: MockOnlineODataProvider?
  var mockService: MockDataService<OnlineODataProvider>?
  static let NILERRORMESSAGE =  "no error description: error or error.message is nil"

  override func setUp() {
    super.setUp()
    // Put setup code here. This method is called before the invocation of each test method in the class.
    oDataProvider = ODataServiceProvider()
    oDataProvider?.online = true
    mockProvider = MockOnlineODataProvider(serviceName: "mock", serviceRoot: "http://mock.host/mock.service/")
    mockService = MockDataService(provider: mockProvider!)
    do {
      try mockProvider?.loadMetadata()
    } catch {
      print("Mock provider could not load metadata")
    }
  }

  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
    oDataProvider?.onlineService = nil
  }

  func testCreateServiceWithEmptyParams() {
    let params = NSDictionary()
    createService(params: params) { (error: NSError?) in
      guard error == nil else {
        return
      }
      XCTFail("Should not succeed with empty params")
    }
  }

  func testCreateServiceWithBadParams() {
    let params: NSDictionary = ["BadParameter": "https://bad-url.com"]
    createService(params: params) { (error: NSError?) in
      guard error == nil else {
        return
      }
      XCTFail("Should not succeed with bad params")
    }
  }

  //    func testCreateServiceWithValidParams() {
  //        let params: NSDictionary = ["serviceUrl": "http://services.odata.org/V4/Northwind/Northwind.svc/"]
  //        createService(params: params) { (error: NSError?) in
  //            guard error == nil else {
  //                XCTFail("Should not fail")
  //                return
  //            }
  //        }
  //    }

  func testOpenServiceWithNilService() {
    let openExpectation: XCTestExpectation = self.expectation(description: "Open expectation")
    let params = NSDictionary()

    _ = self.oDataProvider?.open(params: params, success: { (_) in
      openExpectation.fulfill()
      XCTFail("Should not succeed without service")
    }, failure: { (_: String?, message: String?, _: NSError?) in
      openExpectation.fulfill()
      XCTAssert(message == "Service open failed, DataService does not exist. Did you call create()?")
    })

    waitForExpectations(timeout: 10) { error in
      if let error = error {
        print("Error: \(error.localizedDescription)")
      }
    }
  }

  func testOpenServiceWithValidParams() {

    oDataProvider?.onlineService = mockService
    let openExpectation: XCTestExpectation = self.expectation(description: "Open expectation")

    _ = self.oDataProvider?.open(params: openParams, success: { (_) in
      openExpectation.fulfill()
      XCTAssertTrue((self.oDataProvider?.onlineService?.hasMetadata)!)
    }, failure: { (_: String?, _: String?, _: NSError?) in
      openExpectation.fulfill()
      XCTFail("Open service failed")
    })

    waitForExpectations(timeout: 10) { error in
      if let error = error {
        print("Error: \(error.localizedDescription)")
      }
    }
  }

  func testReadWithInvalidCollection() {
    oDataProvider?.onlineService = mockService
    oDataProvider?.read(entitySet: "", properties: ["dummy"], success: { (_) in
      XCTFail()
    }, failure: { (_, message, _) in
      XCTAssertTrue(message == "Service read failed, collection parameter is empty")
    })
  }

  func testReadAllProperties() {
    oDataProvider?.onlineService = mockService
    let openExpectation: XCTestExpectation = self.expectation(description: "Open expectation")

    _ = self.oDataProvider?.open(params: openParams, success: { (_) in
      openExpectation.fulfill()

      let readExpectation:XCTestExpectation = self.expectation(description: "Read expectation")

      self.oDataProvider?.read(entitySet: "NorthwindModel.Product", properties: [], success: { (_) in
        readExpectation.fulfill()
      }, failure: { (_, _, _) in
        XCTFail()
        readExpectation.fulfill()
      })
    }, failure: { (_: String?, _: String?, _: NSError?) in
      openExpectation.fulfill()
      XCTFail("Open service failed")
    })

    waitForExpectations(timeout: 10) { error in
      if let error = error {
        print("Error: \(error.localizedDescription)")
      }
    }
  }

  func testReadOneProperty() {
    oDataProvider?.onlineService = mockService
    let openExpectation: XCTestExpectation = self.expectation(description: "Open expectation")

    _ = self.oDataProvider?.open(params: openParams, success: { (_) in
      openExpectation.fulfill()

      let readExpectation: XCTestExpectation = self.expectation(description: "Read expectation")

      self.oDataProvider?.read(entitySet: "NorthwindModel.Product", properties: ["ProductName"], success: { (_) in
        readExpectation.fulfill()
      }, failure: { (_, _, _) in
        XCTFail()
        readExpectation.fulfill()
      })
    }, failure: { (_: String?, _: String?, _: NSError?) in
      openExpectation.fulfill()
      XCTFail("Open service failed")
    })

    waitForExpectations(timeout: 10) { error in
      if let error = error {
        print("Error: \(error.localizedDescription)")
      }
    }
  }
  // to_fix
//  func testUpdateOneProperty() {
//    oDataProvider?.onlineService = mockService
//
//    let url = "http://mock.host/mock.service/"
//    let openExpectation: XCTestExpectation = self.expectation(description: "Open expectation")
//    let params: NSDictionary = ["serviceUrl": url, "username": "mehtaku", "password": "Syclo123!"]
//
//    _ = self.oDataProvider?.open(params: params, success: { (_) in
//      openExpectation.fulfill()
//
//      //read
//      let readExpectation:XCTestExpectation = self.expectation(description: "Read expectation")
//
//      self.oDataProvider?.read(entitySet: "NorthwindModel.Product", properties: ["ProductName"], success: { (_) in
//        readExpectation.fulfill()
//
//        //update
//        // create a temp entity that can be updated.
//        mockProvider?.createEntityForUpdates()
//
//        let updateExpectation:XCTestExpectation = self.expectation(description: "Update expectation")
//        self.oDataProvider?.updateEntity(params: Any,
//                                         success: { (_) in
//                                          updateExpectation.fulfill()
//        }
//          updateExpectation.fulfill()
//        })
//
//      }, failure: { (_, _, _) in
//        XCTFail()
//        readExpectation.fulfill()
//      })
//
//    }, failure: { (_: String?, _: String?, _: NSError?) in
//      openExpectation.fulfill()
//      XCTFail("Open service failed")
//    })
//
//    waitForExpectations(timeout: 10) { error in
//      if let error = error {
//        print("Error: \(error.localizedDescription)")
//      }
//    }
//  }

//  func testCreateEntityWithValidParams() {
//    oDataProvider?.onlineService = mockService
//
//    let url = "http://mock.host/mock.service/"
//    let openExpectation: XCTestExpectation = self.expectation(description: "Open expectation")
//    let params: NSDictionary = ["serviceUrl": url, "username": "mike", "password": "123!"]
//
//    _ = self.oDataProvider?.open(params: params, success: { (_) in
//      openExpectation.fulfill()
//      let createEntityExpectation:XCTestExpectation = self.expectation(description: "Update expectation")
//      self.oDataProvider?.createEntity(entitySetName: "NorthwindModel.Product",
//                                       properties: ["ProductName": "Updated", "ProductID": 0],
//                                       linksToCreate: [], success: { (_) in
//                                        createEntityExpectation.fulfill()
//      }, failure: { (_:String?, _:String?, _:NSError?) in
//        createEntityExpectation.fulfill()
//        XCTFail("create entity shouldn't fail")
//      })
//
//    }, failure: { (_: String?, _: String?, _: NSError?) in
//      openExpectation.fulfill()
//      XCTFail("Open service should not fail")
//    })
//
//    waitForExpectations(timeout: 10) { error in
//      if let error = error {
//        print("Error: \(error.localizedDescription)")
//      }
//    }
//  }

//  func testCreateEntityInvalidCases() {
//
//    let entitySet = "NorthwindModel.Product"
//    let properties = ["ProductName": "Bread" as AnyObject]
//
//    createEntityWithInvalidParams(entitySetName: entitySet, properties: [:], expectedMessage: "Invalid parameters: properties is empty")
//    createEntityWithInvalidParams(entitySetName: "", properties: properties as NSDictionary, expectedMessage: "Invalid parameters: entitySet is empty")
//  }

//  func createEntityWithInvalidParams(entitySetName: String, properties: NSDictionary, expectedMessage: String) {
//    oDataProvider?.onlineService = mockService
//
//    let url = "http://mock.host/mock.service/"
//    let openExpectation: XCTestExpectation = self.expectation(description: "Open expectation")
//    let params: NSDictionary = ["serviceUrl": url, "username": "mike", "password": "123!"]
//
//    _ = self.oDataProvider?.open(params: params, success: { (_) in
//      openExpectation.fulfill()
//      let createEntityExpectation:XCTestExpectation = self.expectation(description: "Update expectation")
//      self.oDataProvider?.createEntity(entitySetName: entitySetName,
//                                       properties: properties,
//                                       linksToCreate: [],
//                                       success: { (_) in
//                                        createEntityExpectation.fulfill()
//                                        XCTFail("create entity should fail")
//      }, failure: { (_: String?, message: String?, _: NSError?) in
//        createEntityExpectation.fulfill()
//        XCTAssertTrue(message == expectedMessage, "error message: expected: \(expectedMessage) actual: \(message)")
//      })
//
//    }, failure: { (_: String?, _: String?, _: NSError?) in
//      openExpectation.fulfill()
//      XCTFail("Open service should not fail")
//    })
//
//    waitForExpectations(timeout: 10) { error in
//      if let error = error {
//        print("Error: \(error.localizedDescription)")
//      }
//    }
//  }

  // MARK: Helper
  func createService(params: NSDictionary, callback: (NSError?) -> Void) {
    let createExpectation: XCTestExpectation = expectation(description: "Create expectation")
    _ = oDataProvider?.create(params: params, success: { (_) in
      createExpectation.fulfill()
      callback(nil)
    }, failure: { (_: String?, _: String?, _: NSError?) in
      createExpectation.fulfill()
      callback(NSError())
    })

    waitForExpectations(timeout: 20) { error in
      if let error = error {
        print("Error: \(error.localizedDescription)")
      }
    }
  }

  func testDownloadInvalidCases() {
    downloadWithInvalidParams(setOffline: false, expectedMessage: "OnlineDataProvider used to do Offline OData Download")
    downloadWithInvalidParams(setOffline: true, expectedMessage: "Offline OData Initialize needs to be called before download")
  }

  func downloadWithInvalidParams(setOffline: Bool, expectedMessage: String) {
    if setOffline {
      oDataProvider?.online = false
    } else {
      oDataProvider?.onlineService = mockService
    }

    let url = "http://mock.host/mock.service/"
    let downloadExpectation: XCTestExpectation = self.expectation(description: "Download expectation")
    let params: NSDictionary = ["serviceUrl": url, "storeName": "test123"]

    self.oDataProvider?.download(params: params, success: { (_) in
      XCTFail("Download entity should fail")
    }, failure: { (_: String?, message: String?, _: NSError?) in
      XCTAssertTrue(message == expectedMessage, "error message: expected: \(expectedMessage) actual: \(message ?? ODataServiceProviderTests.NILERRORMESSAGE)")
      downloadExpectation.fulfill()
    })

    waitForExpectations(timeout: 10) { error in
      if let error = error {
        print("Error: \(error.localizedDescription)")
      }
    }
  }

  func testUploadInvalidCases() {
    uploadWithInvalidParams(setOffline: false, expectedMessage: "OnlineDataProvider used to do Offline OData Upload")
    uploadWithInvalidParams(setOffline: true, expectedMessage: "Offline OData Initialize needs to be called before upload")
  }

  func uploadWithInvalidParams(setOffline: Bool, expectedMessage: String) {
    if setOffline {
      oDataProvider?.online = false
    } else {
      oDataProvider?.onlineService = mockService
    }

    let url = "http://mock.host/mock.service/"
    let uploadExpectation: XCTestExpectation = self.expectation(description: "Upload expectation")
    let params: NSDictionary = ["serviceUrl": url, "storeName": "test123"]

    self.oDataProvider?.upload(params: params, success: { (_) in
      XCTFail("Upload entity should fail")
    }, failure: { (_: String?, message: String?, _: NSError?) in
      XCTAssertTrue(message == expectedMessage, "error message: expected: \(expectedMessage) actual: \(message ?? ODataServiceProviderTests.NILERRORMESSAGE)")
      uploadExpectation.fulfill()
    })

    waitForExpectations(timeout: 10) { error in
      if let error = error {
        print("Error: \(error.localizedDescription)")
      }
    }
  }

//  func testDeleteEntity() {
//    oDataProvider?.onlineService = mockService
//
//    let url = "http://mock.host/mock.service/"
//    let openExpectation: XCTestExpectation = self.expectation(description: "Open expectation")
//    let params: NSDictionary = ["serviceUrl": url, "username": "mehtaku", "password": "Syclo123!"]
//
//    _ = self.oDataProvider?.open(params: params, success: { (_) in
//      openExpectation.fulfill()
//      let readExpectation:XCTestExpectation = self.expectation(description: "Read expectation")
//
//      self.oDataProvider?.read(entitySet: "NorthwindModel.Product", properties: ["ProductName"], success: { (_) in
//        readExpectation.fulfill()
//        mockProvider?.createEntityForUpdates()
//        let deleteExpectation:XCTestExpectation = self.expectation(description: "Delete expectation")
//
//        self.oDataProvider?.deleteEntity(entitySetName: "NorthwindModel.Product",
//                                         properties: ["ProductID": 0],
//                                         keyProperties: ["ProductID"],
//                                         success: { (_) in
//                                          deleteExpectation.fulfill()
//        }, failure: { (_:String?, _:String?, _:NSError?) in
//          deleteExpectation.fulfill()
//        })
//
//      }, failure: { (_, _, _) in
//        XCTFail()
//        readExpectation.fulfill()
//      })
//
//    }, failure: { (_: String?, _: String?, _: NSError?) in
//      openExpectation.fulfill()
//      XCTFail("Open service failed")
//    })
//
//    waitForExpectations(timeout: 10) { error in
//      if let error = error {
//        print("Error: \(error.localizedDescription)")
//      }
//    }
//
//  }
  func testCloseInvalidCases() {
    closeWithInvalidParams(setOffline: false, expectedMessage: "OnlineDataProvider used to do Offline OData close")
    closeWithInvalidParams(setOffline: true, expectedMessage: "Offline OData Initialize needs to be called before close")
  }

  func closeWithInvalidParams(setOffline: Bool, expectedMessage: String) {
    if setOffline {
      oDataProvider?.online = false
    } else {
      oDataProvider?.onlineService = mockService
    }

    let url = "http://mock.host/mock.service/"
    let closeExpectation: XCTestExpectation = self.expectation(description: "Close expectation")
    let params: NSDictionary = ["serviceUrl": url]

    self.oDataProvider?.close(params: params, success: { (_) in
      closeExpectation.fulfill()
      XCTFail("Close entity should fail")
    }, failure: { (_: String?, message: String?, _: NSError?) in
      closeExpectation.fulfill()
      XCTAssertTrue(message == expectedMessage, "error message: expected: \(expectedMessage) actual: \(message ?? ODataServiceProviderTests.NILERRORMESSAGE)")
    })

    waitForExpectations(timeout: 10) { error in
      if let error = error {
        print("Error: \(error.localizedDescription)")
      }
    }
  }

  func testClearInvalidCases() {
    clearWithInvalidParams(setOffline: false, expectedMessage: "OnlineDataProvider used to do Offline OData clear")
    clearWithInvalidParams(setOffline: true, expectedMessage: "Offline OData Initialize needs to be called before clear")
  }

  func clearWithInvalidParams(setOffline: Bool, expectedMessage: String) {
    if setOffline {
      oDataProvider?.online = false
    } else {
      oDataProvider?.onlineService = mockService
    }

    let url = "http://mock.host/mock.service/"
    let clearExpectation: XCTestExpectation = self.expectation(description: "Clear expectation")
    let params: NSDictionary = ["serviceUrl": url]

    self.oDataProvider?.clear(params: params, success: { (_) in
      clearExpectation.fulfill()
      XCTFail("Clear entity should fail")
    }, failure: { (_: String?, message: String?, _: NSError?) in
      clearExpectation.fulfill()
      XCTAssertTrue(message == expectedMessage, "error message: expected: \(expectedMessage) actual: \(message ?? ODataServiceProviderTests.NILERRORMESSAGE)")
    })

    waitForExpectations(timeout: 10) { error in
      if let error = error {
        print("Error: \(error.localizedDescription)")
      }
    }
  }
}
