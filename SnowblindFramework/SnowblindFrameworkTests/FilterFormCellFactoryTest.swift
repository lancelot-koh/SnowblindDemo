//
//  FilterFormCellFactoryTest.swift
//  SAPMDCFramework
//
//  Created by Mate, Gabor Lajos on 2017. 04. 18..
//  Copyright © 2017. SAP. All rights reserved.
//

import XCTest
import SAPFiori
@testable import SAPMDC

class FilterFormCellFactoryTest: FormCellFactoryTest {

  func testGetFormCellForFilterFormCellWithValidParameters() {
    let caption = "Filter"
    let value = [0, 2]
    let filterItems = ["Low", "Medium", "High"]
    let allowsMultipleSelection = true
    let allowsEmptySelection = true
    var params = getFilterControlParameters(false, caption, value, filterItems, allowsMultipleSelection,
                                            allowsEmptySelection)
    let controller = FormCellContainerViewController()
    let cellType = params["_Type"] as? String
    controller.addFormCell(params, withDelegate: FormCellItemDelegate())
    if let cell = FormCellFactory.getFormCell(tableView: controller.tableView,
                                              indexPath: IndexPath.init(),
                                              cellType: cellType!,
                                              cellParams: params,
                                              formCellController: controller,
                                              delegate: FormCellItemDelegate()) as? SAPFiori.FUIFilterFormCell {
      XCTAssertNotNil(cell, "segmentedControlTestCell should not be nil")
      XCTAssert(cell.keyName == caption, "Caption is not correct: expected: \(caption) actual: \(cell.value)")
      XCTAssert(cell.value == value, "Value is not correct: expected: \(value) actual: \(cell.value)")
      XCTAssert(cell.valueOptions == filterItems,
                "FilterItems is not correct: expected: \(filterItems) actual: \(cell.valueOptions)")
      XCTAssert(cell.allowsMultipleSelection == allowsMultipleSelection,
                "allowsMultipleSelection is not correct: expected: \(allowsMultipleSelection) actual: \(cell.allowsMultipleSelection)")
      XCTAssert(cell.isEditable == true, "IsEditable defaults to true")
    }

    if let filterFormCellTestCell = cellMocker([
      "_Type": "Control.Type.FormCell.Filter", "_Name": "OrderId", "Caption": caption,
      "Value": value, "FilterItems": filterItems, "AllowMultipleSelection": true,
      "IsEditable": false
      ]) as? SAPFiori.FUIFilterFormCell {
      XCTAssert(filterFormCellTestCell.isEditable == false, "IsEditable should be false")
    } else {
      XCTFail("Cell type should be FilterFormCellControl")
    }
  }

  func testGetFormCellForFilterFormCellWithInvalidParameters() {
    let caption = true
    let value = ["1", "2"]
    let filterItems = [1, 2, 3]
    let allowsMultipleSelection = "false"
    let allowsEmptySelection = "true"
    let filterControlCellParams = getFilterControlParameters(false, caption, value, filterItems, allowsMultipleSelection, allowsEmptySelection)
    if let filterFormCellTestCell = cellMocker(filterControlCellParams) as? SAPFiori.FUIFilterFormCell {
      XCTAssertNotNil(filterFormCellTestCell, "filterControlTestCell should be nil")
      XCTAssert(filterFormCellTestCell.value == [], "Value is not correct: expected: [] actual: \(filterFormCellTestCell.value)")
      XCTAssert(filterFormCellTestCell.allowsMultipleSelection == true,
                "allowsMultipleSelection is not correct: expected: true actual: \(filterFormCellTestCell.allowsMultipleSelection)")
      XCTAssert(filterFormCellTestCell.allowsEmptySelection == true,
                "allowsEmptySelection is not correct: expected: true actual: \(filterFormCellTestCell.allowsEmptySelection)")
    } else {
      XCTFail("Cell type should be FilterFormCellControl")
    }
  }
// swiftlint:disable function_parameter_count
  private func getFilterControlParameters(_ sorter: Bool,
                                          _ caption: Any,
                                          _ value: Any,
                                          _ filterItems: [Any],
                                          _ allowMultipleSelection: Any,
                                          _ allowEmptySelection: Any) -> [String : Any] {
    return [
      "_Type": (sorter) ? "Control.Type.FormCell.Sorter" : "Control.Type.FormCell.Filter",
      "_Name": "BusinessArea",
      "Caption": caption,
      "Value": value,
      "FilterItems": filterItems,
      "AllowMultipleSelection": allowMultipleSelection,
      "AllowEmptySelection": allowEmptySelection
      ] as [String : Any]
  }
// swiftlint:enable function_parameter_count

}
