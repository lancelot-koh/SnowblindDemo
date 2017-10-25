//
//  OnlineODataProviderReadMock.swift
//  SAPMDCFramework
//
//  Created by Hably, Alexandra on 2017. 01. 13..
//  Copyright © 2017. SAP. All rights reserved.
//

import Foundation
import SAPOData

enum Queries: String {
  case basic = "Products"
  case subset = "Products(1)"
  case withQueryString = "Products?$filter=%27Price%27%20gt%20%2710%27"
  case detailEntitySet = "Products(1)/Order_Details"
}

class OnlineODataProviderReadMock: OnlineODataProvider {

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
    productList = EntityValueList()

    if let implementedQueryMocks = Queries(rawValue: query.toString()) {

      switch implementedQueryMocks {
      case .subset:
        _ = productList?.appendThis(createProduct(for: 1)!)
        return QueryResult(query: query, result: productList)

      case .withQueryString:
        for i in 0..<5 {
          _ = productList?.appendThis(createProduct(for: i, arbitraryFilterData: 11)!)
        }
        return QueryResult(query: query, result: productList)

      case .detailEntitySet:
        // not implemented yet
        break

      case .basic:
        // see default
        break
      }
    }

    // default

    print("The mock class contains no implementation for this query, so returning a basic list of Products")

    for i in 0..<5 {
      _ = productList?.appendThis(createProduct(for: i)!)
    }

    return QueryResult(query: query, result: productList)

  }

  override func updateEntity(_ entity: EntityValue, headers: HTTPHeaders, options: RequestOptions) throws {
    // hard coded to update the first entity
    productList?[0] = entity
  }

  // MARK: Helpers
  private func readCSDLFile(file: String) -> String? {
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

  func createProduct(for index: Int, arbitraryFilterData: Int? = nil) -> EntityValue? {
    let products = ["Milk", "Coffee", "Tea", "Bread", "Butter"]
    let entityType = metadata.entityType(withName: "NorthwindModel.Product")
    // TODO: instead of hardcoding entity type, can we get it fro the query as below?
    // let item = EntityValue.ofType(query.entitySet!.entityType)
    let item = EntityValue.ofType(entityType)
    let propName = entityType.property(withName: "ProductName")
    propName.setStringValue(in: item, to: products[index])
    let propId = entityType.property(withName: "ProductID")
    propId.setIntValue(in: item, to: index)
    if let priceFilter = arbitraryFilterData {
      let propPrice = entityType.property(withName: "UnitPrice")
      propPrice.setDecimalValue(in: item, to: BigDecimal.fromInt(priceFilter + index*2))
    }
    return item
  }

  func createEntityForUpdates() {
    tmpEntityForUpdate = createProduct(for: 0)
  }
}
