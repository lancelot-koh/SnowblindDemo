//
//  MockOnlineODataProvider
//  SAPMDCFramework
//
//  Created by Mehta, Kunal on 11/2/16.
//  Copyright © 2016 SAP. All rights reserved.
//

import Foundation
import SAPOData

class MockOnlineODataProvider: OnlineODataProvider {
  var tmpEntityForUpdate: EntityValue?
  var productList: EntityValueList?

  override func loadMetadata() throws {
    let parser = CSDLParser()
    if let csdlString = readCSDLFile(file: "NorthwindCSDL") {
      let csdlDoc = try parser.parse(csdlString, url: "dummy")
      metadata = csdlDoc
    }
  }

  override func executeQuery(_ query: DataQuery, headers: HTTPHeaders, options: RequestOptions) throws -> QueryResult {
    print(query)

    if productList == nil {
      productList = EntityValueList()
      for i in 0..<5 {
        _ = productList?.appendThis(createProduct(for: i)!)
      }
    }

    return QueryResult(query: query, result: productList)
  }

  override func updateEntity(_ entity: EntityValue, headers: HTTPHeaders, options: RequestOptions) throws {
    // hard coded to update the fitst entity
    productList?[0] = entity
  }

  override func createEntity(_ entity: EntityValue, headers: HTTPHeaders, options: RequestOptions) throws {
    // not to throw any error
  }

  override func acquireToken() throws {
    // good
  }

  override func processBatch(_ batch: SAPOData.RequestBatch, headers: SAPOData.HTTPHeaders, options: SAPOData.RequestOptions) throws {
    // good
  }

  // MARK: Helpers
  func readCSDLFile(file: String) -> String? {
    let bundle = Bundle(for: type(of: self))
    if let path = bundle.path(forResource: file, ofType: "xml") {
      do {
        let csdl = try String(contentsOfFile: path)
        return csdl
      } catch {
        print("Caught exception \(error)")
      }
    }
    return nil
  }

  func createProduct(for index: Int) -> EntityValue? {
    let products = ["Milk", "Coffee", "Tea", "Bread", "Butter"]
    let entityType = metadata.entityType(withName: "NorthwindModel.Product")
    // TODO: instead of hardcoding entity type, can we get it fro the query as below?
    // let item = EntityValue.ofType(query.entitySet!.entityType)
    let item = EntityValue.ofType(entityType)
    let propName = entityType.property(withName: "ProductName")
    propName.setStringValue(in: item, to: products[index])
    let propId = entityType.property(withName: "ProductID")
    propId.setIntValue(in: item, to: index)
    return item
  }

  func createEntityForUpdates() {
    tmpEntityForUpdate = createProduct(for: 0)
  }
}
