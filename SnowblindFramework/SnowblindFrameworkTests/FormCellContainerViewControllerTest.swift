//
//  FormCellContainerViewControllerTest.swift
//  SAPMDCFramework
//
//  Created by Tan, Jin Na on 12/22/16.
//  Copyright © 2016 SAP. All rights reserved.
//

import XCTest
import SAPFiori
@testable import SAPMDC

class FormCellContainerViewControllerTest: XCTestCase {

  override func setUp() {
    super.setUp()
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }

  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
  }

  func testAddFormCell() {
    let controller = getFormCellContainerViewController()
    let cellTypesForSection = controller.getCellTypesForSection()

    if cellTypesForSection.count == 2 && cellTypesForSection[0]?.count == 1 &&  cellTypesForSection[1]?.count == 3 {
      if let titleParams = cellTypesForSection[0]![0] as? [String: String] {
        XCTAssert(titleParams == getTitleParams(), "section[0][0] params incorrect: expected: \(getTitleParams()) actual: \(titleParams)")
      }

      if let noteParams = cellTypesForSection[1]![0] as? [String: String] {
        XCTAssert(noteParams == getNoteParams(), "section[1][0] params incorrect : expected: \(getNoteParams()) actual: \(noteParams)")
      }

      if let dateParams = cellTypesForSection[1]![1] as? [String: String] {
        XCTAssert(dateParams == getDatePickerCellParams(), "section[1][1] params incorrect: expected: \(getDatePickerCellParams()) actual: \(dateParams)")
      }

      let attachmentParams = cellTypesForSection[1]![2]
      for (key, value) in attachmentParams {
        switch value {
        case let value as String:
          XCTAssert(value == (getAttachmentCellParams()[key] as? String)!, "Different values for: \(key)")
        case let value as [String]:
          XCTAssert(value == (getAttachmentCellParams()[key] as? [String])!, "Different values for: \(key)")
        default:
          XCTFail("Unknown parameter type!")
        }
      }

    } else {
      XCTFail("cellTypesForSection count incorrect")
    }
  }

  func testHiddenFormCellsAreNotShown() {
    let controller = FormCellContainerViewController()
    let tableView = UITableView()
    controller.tableView = tableView
    controller.numberOfSections = 2
    controller.numberOfRowsInSection = [1, 4]
    controller.addFormCell(getTitleParams(), withDelegate: FormCellItemDelegate())
    controller.addFormCell(getNoteParams(), withDelegate: FormCellItemDelegate())
    controller.addFormCell(getDurationParamsHidden(), withDelegate: FormCellItemDelegate())
    controller.addFormCell(getDatePickerCellParams(), withDelegate: FormCellItemDelegateStub())
    controller.addFormCell(getSwitchParamsVisible(), withDelegate: FormCellItemDelegate())
    controller.sectionNames = ["s1", "s2"]
    let cellTypesForSection = controller.getCellTypesForSection()
    let sectionCountsAreCorrect = cellTypesForSection.count == 2 && cellTypesForSection[0]?.count == 1 && cellTypesForSection[1]?.count == 4
    XCTAssert(sectionCountsAreCorrect, "cellTypesForSection count incorrect")
    let ds = controller as UITableViewDataSource
    XCTAssertEqual(ds.tableView(tableView, numberOfRowsInSection: 0), 1)
    XCTAssertEqual(ds.tableView(tableView, numberOfRowsInSection: 1), 3)
    let cell00 = ds.tableView(tableView, cellForRowAt: IndexPath(row: 0, section: 0))
    let cell01 = ds.tableView(tableView, cellForRowAt: IndexPath(row: 0, section: 1))
    let cell11 = ds.tableView(tableView, cellForRowAt: IndexPath(row: 1, section: 1))
    let cell21 = ds.tableView(tableView, cellForRowAt: IndexPath(row: 2, section: 1))
    XCTAssertNotNil(cell00)
    XCTAssertNotNil(cell01)
    XCTAssertNotNil(cell11)
    XCTAssertNotNil(cell21)
    // Duration cell should not be included
    XCTAssertNotNil(cell00 as? FUITitleFormCell)
    XCTAssertNotNil(cell01 as? FUINoteFormCell)
    XCTAssertNotNil(cell11 as? FUIDatePickerFormCell)
    XCTAssertNotNil(cell21 as? FUISwitchFormCell)
  }

  func testUpdateFormCells() {
    let controller = getFormCellContainerViewController()
    var params: [[String: Any]] = []
    params.append(getTitleParamsUpdated())
    params.append(getNoteParamsUpdated())
    params.append(getDatePickerCellParamsUpdated())
    params.append(getAttachmentCellParamsUpdated())
    controller.sectionNames = ["s1", "s2"]
    controller.updateFormCells(params as NSArray, withStyle: nil)

    let cellTypesForSection = controller.getCellTypesForSection()
    if cellTypesForSection.count == 2 && cellTypesForSection[0]?.count == 1 &&  cellTypesForSection[1]?.count == 3 {
      if let titleParams = cellTypesForSection[0]![0] as? [String: String] {
        XCTAssert(titleParams == getTitleParamsUpdated(), "section[0][0] params incorrect : expected: \(getTitleParams()) actual: \(titleParams)")
      }

      if let noteParams = cellTypesForSection[1]![0] as? [String: String] {
        XCTAssert(noteParams == getNoteParamsUpdated(), "section[1][0] params incorrect: expected: \(getNoteParams()) actual: \(noteParams)")
      }

      if let dateParams = cellTypesForSection[1]![1] as? [String: String] {
        XCTAssert(dateParams == getDatePickerCellParamsUpdated(), "csection[1][1] params incorrect: expected: \(getDatePickerCellParams()) actual: \(dateParams)")
      }

      let attachmentParams = cellTypesForSection[1]![2]
      for (key, value) in attachmentParams {
        switch value {
        case let value as String:
          XCTAssert(value == (getAttachmentCellParamsUpdated()[key] as? String)!, "Different values for: \(key)")
        case let value as [String]:
          XCTAssert(value == (getAttachmentCellParamsUpdated()[key] as? [String])!, "Different values for: \(key)")
        default:
          XCTFail("Unknown parameter type!")
        }
      }

    } else {
      XCTFail("cellTypesForSection count incorrect")
    }

  }

  private func getTitleParams() -> [String : String] {
    let titleCellParams = [
      "_Name": "TitleFormCell",
      "PlaceHolder": "Title",
      "Value": "Value",
      "_Type": "Control.Type.FormCell.Title"
    ]
    return titleCellParams
  }

  private func getTitleParamsUpdated() -> [String : String] {
    let titleCellParams = [
      "_Name": "TitleFormCell",
      "PlaceHolder": "Title2",
      "Value": "Value2",
      "_Type": "Control.Type.FormCell.Title"
    ]
    return titleCellParams
  }

  private func getNoteParams() -> [String : String] {
    return [
      "_Name": "NoteFormCell",
      "Value": "Note",
      "PlaceHolder": "Description",
      "_Type": "Control.Type.FormCell.Note"
    ]
  }

  private func getDurationParamsHidden() -> [String : Any] {
    return [
      "_Name": "DurationFormCellHidden",
      "Value": 55,
      "PlaceHolder": "Description",
      "_Type": "Control.Type.FormCell.DurationPicker",
      "IsVisible": false
    ]
  }

  private func getSwitchParamsVisible() -> [String : Any] {
    return [
      "_Name": "SwitchFormCellVisible",
      "Value": true,
      "PlaceHolder": "Description",
      "_Type": "Control.Type.FormCell.Switch",
      "IsVisible": true
    ]
  }

  private func getNoteParamsUpdated() -> [String : String] {
    return [
      "_Name": "NoteFormCell",
      "Value": "Note2",
      "PlaceHolder": "Description2",
      "_Type": "Control.Type.FormCell.Note"
    ]
  }

  private func getDatePickerCellParams() -> [String : String] {
    return [
      "_Type": "Control.Type.FormCell.DatePicker",
      "_Name": "DatePickercell",
      "Caption": "datePicker",
      "Value": "2016-12-25T12:00:05Z",
      "DateTimeEntryMode": "date",
      "PlaceHolder": "please select"
    ]
  }

  private func getDatePickerCellParamsUpdated() -> [String : String] {

    return [
      "_Type": "Control.Type.FormCell.DatePicker",
      "_Name": "DatePickercell",
      "Caption": "datePicker",
      "Value": "2016-12-26T12:00:05Z",
      "DateTimeEntryMode": "time",
      "PlaceHolder": "please select again"
    ]
  }

  private func getAttachmentCellParams() -> [String : Any] {

    return [
      "_Name": "AttachmentFormCell1",
      "_Type": "Control.Type.FormCell.Attachment",
      "AttachmentTitleFormat": "Photos [%d]",
      "AttachmentAddTitle": "Add photos",
      "AttachmentCancelTitle": "No!",
      "AttachmentActionType": ["AddPhoto"],
      "Value": [],
      "OnValueChange": "/AssetWorkManager/Actions/Message.action"
    ]
  }

  private func getAttachmentCellParamsUpdated() -> [String : Any] {

    return [
      "_Name": "AttachmentFormCell1",
      "_Type": "Control.Type.FormCell.Attachment",
      "AttachmentTitleFormat": "Photos [%d]",
      "AttachmentAddTitle": "Add photos",
      "AttachmentCancelTitle": "No!",
      "AttachmentActionType": ["AddPhoto", "TakePhoto"],
      "Value": ["assets-library://asset/asset.JPG?id=ED7AC36B-A150-4C38-BB8C-B6D696F4F2ED&ext=JPG"],
      "OnValueChange": "/AssetWorkManager/Actions/Message.action"
    ]
  }

  private func getFormCellContainerViewController() -> FormCellContainerViewController {
    let containerViewController = FormCellContainerViewController()
    containerViewController.numberOfSections = 2
    containerViewController.numberOfRowsInSection = [1, 3]
    containerViewController.addFormCell(getTitleParams(), withDelegate: FormCellItemDelegate())
    containerViewController.addFormCell(getNoteParams(), withDelegate: FormCellItemDelegate())
    containerViewController.addFormCell(getDatePickerCellParams(), withDelegate: FormCellItemDelegate())
    containerViewController.addFormCell(getAttachmentCellParams(), withDelegate: FormCellItemDelegate())
    return containerViewController
  }

}
