//
//  FormCellFactoryTest.swift
//  SAPMDCFramework
//
//  Created by Sauve, Mathieu on 2016-12-12.
//  Copyright © 2016 SAP. All rights reserved.
//

import XCTest
import SAPFiori
@testable import SAPMDC

// swiftlint:disable file_length
// swiftlint:disable function_body_length
class FormCellFactoryTest: XCTestCase {

  func testGetFormCellForAttachment() {
    let attachmentParams = [
      "_Name": "AttachmentFormCell1",
      "_Type": "Control.Type.FormCell.Attachment",
      "AttachmentTitle": "Photos [%d]",
      "AttachmentAddTitle": "Add photos",
      "AttachmentCancelTitle": "No!",
      "AttachmentActionType": ["AddPhoto", "TakePhoto"],
      "Value": [],
      "OnValueChange": "/AssetWorkManager/Actions/Message.action"
      ] as [String : Any]

    if let attachmentTestCell = cellMocker(attachmentParams) as? SAPFiori.FUIAttachmentsFormCell {
      XCTAssertNotNil(attachmentTestCell)
      XCTAssertTrue(attachmentTestCell.attachmentsController.customAttachmentsTitleFormat == "Photos [%d]")
      XCTAssertTrue(attachmentTestCell.attachmentsController.customPopupTitleString == "Add photos")
      XCTAssertTrue(attachmentTestCell.attachmentsController.customCancelString == "No!")
      XCTAssertTrue(attachmentTestCell.attachmentsController.numberOfAttachmentActions() == 2)
    }
  }

  func testGetFormCellForTitle() {
    var titleCellParams = [
      "_Name": "TitleFormCell",
      "PlaceHolder": "Title",
      "Value": "Value",
      "_Type": "Control.Type.FormCell.Title"
    ] as [String : Any]
    titleCellParams.updateValue(["SeparatorBackgroundColor": "000000",
                                 "SeparatorIsHidden": true,
                                 "ValidationMessage": "Validation Message",
                                 "ValidationMessageColor": "111111",
                                 "ValidationViewBackgroundColor": "222222",
                                 "ValidationViewIsHidden": false],
                                forKey: "validationProperties")

    if let titleTestCell = cellMocker(titleCellParams) as? SAPFiori.FUITitleFormCell {
      XCTAssertNotNil(titleTestCell)
      XCTAssertTrue(titleTestCell.placeholderText == "Title")
      XCTAssertTrue(titleTestCell.value == "Value")
      XCTAssert(titleTestCell.isTrackingLiveChanges == true, "isTrackingLiveChanges is expected to true")
      XCTAssert(titleTestCell.isEditable == true, "IsEditable defaults to true")
      XCTAssert(getHexStringFor(color: titleTestCell.validationView.separator.backgroundColor) == "000000")
      XCTAssert(titleTestCell.validationView.separator.isHidden)
      XCTAssert(titleTestCell.validationMessage == "Validation Message")
      XCTAssert(getHexStringFor(color: titleTestCell.validationView.titleLabel.textColor) == "111111")
      XCTAssert(getHexStringFor(color: titleTestCell.validationView.backgroundColor) == "222222")
      XCTAssert(titleTestCell.validationView.isHidden == false)
    } else {
      XCTFail()
    }
  }

  private func getHexStringFor(color: UIColor?) -> String {
    var red: CGFloat = 0
    var green: CGFloat = 0
    var blue: CGFloat = 0
    var alpha: CGFloat = 0

    color?.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
    return String(format: "%02x%02x%02x", Int(red * 255), Int(green * 255), Int(blue * 255))
  }

  func testGetFormCellForNote() {
    let placeHolder = "Description"
    let value = "Note"
    let noteCellParams = [
      "_Name": "NoteFormCell",
      "Value": value,
      "PlaceHolder": placeHolder,
      "_Type": "Control.Type.FormCell.Note"
      ] as [String : Any]

    if let noteTestCell = cellMocker(noteCellParams) as? SAPFiori.FUINoteFormCell {
      XCTAssertNotNil(noteTestCell)
      XCTAssert(noteTestCell.placeholderText == placeHolder, "PlaceHolder is not correct: expected: \(placeHolder) actual: \(String(describing: noteTestCell.placeholderText))")
      XCTAssert(noteTestCell.value == value, "Value is not correct: expected: \(value) actual: \(noteTestCell.value)")
      XCTAssert(noteTestCell.isTrackingLiveChanges == true, "isTrackingLiveChanges is expected to true")
      XCTAssert(noteTestCell.isEditable == true, "IsEditable defaults to true")
    } else {
      XCTFail()
    }

    if let noteTestCell = cellMocker([
      "_Name": "NoteFormCell",
      "Value": value,
      "PlaceHolder": placeHolder,
      "_Type": "Control.Type.FormCell.Note",
      "IsEditable": false
      ] as [String : Any]) as? SAPFiori.FUINoteFormCell {
      XCTAssert(noteTestCell.isEditable == false, "IsEditable should be faulse")

    } else {
      XCTFail()
    }
  }

  func testGetFormCellForSimpleProperty() {
    let simplePropertyCellParams = [
      "_Type": "Control.Type.FormCell.SimpleProperty",
      "_Name": "SimplePropertyFormCell",
      "Caption": "Location",
      "Value": "127 Higgins Drive, Palo Alto",
      "PlaceHolder": "Address",
      "KeyboardType": "Phone"
      ] as [String : Any]

    if let simplePropertyTestCell = cellMocker(simplePropertyCellParams) as? SAPFiori.FUISimplePropertyFormCell {
      XCTAssertNotNil(simplePropertyTestCell)
      XCTAssertTrue(simplePropertyTestCell.placeholderText == "Address")
      XCTAssertTrue(simplePropertyTestCell.keyName == "Location")
      XCTAssertTrue(simplePropertyTestCell.value == "127 Higgins Drive, Palo Alto")
      XCTAssert(simplePropertyTestCell.isTrackingLiveChanges == true, "isTrackingLiveChanges is expected to true")
      XCTAssert(simplePropertyTestCell.isEditable == false, "IsEditable defaults to false")
      XCTAssert(simplePropertyTestCell.valueTextField.keyboardType == .phonePad, "Keyboard type is .phonePad")
    } else {
      XCTFail()
    }
  }

  func testGetFormCellForSwitch() {
    let switchCellParams = [
      "_Type": "Control.Type.FormCell.Switch",
      "_Name": "Switchcell",
      "Caption": "Confirmed",
      "Value": true
      ] as [String : Any]

    if let switchTestCell = cellMocker(switchCellParams) as? SAPFiori.FUISwitchFormCell {
      XCTAssertNotNil(switchTestCell)
      XCTAssertTrue(switchTestCell.keyName == "Confirmed")
      XCTAssertTrue(switchTestCell.value == true)
      XCTAssert(switchTestCell.isEditable == true, "IsEditable defaults to true")
    } else {
      XCTFail()
    }

    let newSwitchCellParams = [
      "_Type": "Control.Type.FormCell.Switch",
      "_Name": "Switchcell",
      "Caption": "Confirmed",
      "Value": "WRONG",
      "IsEditable": false
      ] as [String : Any]

    if let newSwitchTestCell = cellMocker(newSwitchCellParams) as? SAPFiori.FUISwitchFormCell {
      XCTAssertTrue(newSwitchTestCell.value == false)
      XCTAssert(newSwitchTestCell.isEditable == false, "IsEditable should be false")
    } else {
      XCTFail()
    }
  }

  func testGetFormCellForButton() {
    let buttonCellParams1 = [
      "_Type": "Control.Type.FormCell.Button",
      "_Name": "Buttoncell1",
      "TextAlignment": "center",
      "Title": "ButtonTitle"
    ] as [String : Any]
    let buttonTestCell1 = cellMocker(buttonCellParams1)
    if let buttonTestCell1 = buttonTestCell1 as? SAPFiori.FUIButtonFormCell {
      XCTAssertNotNil(buttonTestCell1)
      XCTAssertEqual(buttonTestCell1.alignment, .center)
      XCTAssertEqual(buttonTestCell1.button.currentTitle, "ButtonTitle")
    } else {
      XCTFail()
    }

    let buttonCellParams2 = [
      "_Type": "Control.Type.FormCell.Button",
      "_Name": "Buttoncell2",
      "TextAlignment": "left",
      "Title": "ButtonTitle2"
    ] as [String : Any]

    if let buttonTestCell2 = cellMocker(buttonCellParams2) as? SAPFiori.FUIButtonFormCell {
      XCTAssertNotNil(buttonTestCell2)
      XCTAssertEqual(buttonTestCell2.alignment, .left)
      XCTAssertEqual(buttonTestCell2.button.currentTitle, "ButtonTitle2")
    } else {
      XCTFail()
    }

    let buttonCellParams3 = [
      "_Type": "Control.Type.FormCell.Button",
      "_Name": "Buttoncell3",
      "TextAlignment": "right",
      "Title": "ButtonTitle3"
    ] as [String : Any]

    if let buttonTestCell3 = cellMocker(buttonCellParams3) as? SAPFiori.FUIButtonFormCell {
      XCTAssertNotNil(buttonTestCell3)
      XCTAssertEqual(buttonTestCell3.alignment, .right)
      XCTAssertEqual(buttonTestCell3.button.currentTitle, "ButtonTitle3")
    } else {
      XCTFail()
    }

    let buttonCellParams4 = [
      "_Type": "Control.Type.FormCell.Button",
      "_Name": "Buttoncell4",
      "TextAlignment": "test default",
      "Title": "ButtonTitle4"
    ] as [String : Any]

    if let buttonTestCell4 = cellMocker(buttonCellParams4) as? SAPFiori.FUIButtonFormCell {
      XCTAssertNotNil(buttonTestCell4)
      XCTAssertEqual(buttonTestCell4.alignment, .center)
      XCTAssertEqual(buttonTestCell4.button.currentTitle, "ButtonTitle4")
    } else {
      XCTFail()
    }
  }

  func testGetFormCellForDatePicker() {
    let caption = "date"
    let dateTimeEntryMode = "date"
    let value = "2016-12-25T12:00:05Z"
    let placeHolder = "please select"
    let datePickerCellParams = getDatePickerParams(caption, value, dateTimeEntryMode, placeHolder)

    if let datePickerTestCell = cellMocker(datePickerCellParams) as? SAPFiori.FUIDatePickerFormCell {
      XCTAssertNotNil(datePickerTestCell)
      XCTAssertTrue(datePickerTestCell.keyName == caption, "Caption is not correct: expected: \(caption) actual: \(String(describing: datePickerTestCell.keyName))")
      XCTAssertTrue(datePickerTestCell.placeholderText == placeHolder, "PlaceHolder is not correct: " +
         "expected: \(placeHolder) actual: \(String(describing: datePickerTestCell.placeholderText))")
      XCTAssertTrue(datePickerTestCell.datePickerMode == UIDatePickerMode.date,
                     "DateTimeEntryMode is not correct: expected: \(UIDatePickerMode.date) actual: \(datePickerTestCell.datePickerMode)")
      let formatter = ISO8601DateFormatter()
      let someDateTime = formatter.date(from : value)
      XCTAssertTrue(datePickerTestCell.value == someDateTime, "Value is not correct: " +
         "expected: \(String(describing: someDateTime)) actual: \(String(describing: datePickerTestCell.value))")
      XCTAssert(datePickerTestCell.isEditable == true, "IsEditable defaults to true")
    } else {
      XCTFail("Cell type should be datePickerFormCellTestCell")
    }

    let formCellContainerViewController = FormCellContainerViewController()
    let changedValue = ISO8601DateFormatter().date(from: "2017-04-25T12:00:05Z")
    formCellContainerViewController.datePickerValue[caption] = changedValue
    // changing the buffer doesn't trigger a value change event, so we have to simulate it
    let datePickerCellParamsChanged = getDatePickerParams(caption, "2017-04-25T12:00:05Z", dateTimeEntryMode, placeHolder)

    if let datePickerFormCellTestCell = cellMocker(with: formCellContainerViewController, datePickerCellParamsChanged) as? SAPFiori.FUIDatePickerFormCell {
      XCTAssert(datePickerFormCellTestCell.value == changedValue, "Value is not correct: expected: \(String(describing: changedValue)) actual: \(datePickerFormCellTestCell.value)")
    }

    if let datePickerTestCell = cellMocker([
      "_Type": "Control.Type.FormCell.DatePicker",
      "_Name": "DatePickercell",
      "Caption": caption,
      "Value": value,
      "DateTimeEntryMode": dateTimeEntryMode,
      "PlaceHolder": placeHolder,
      "IsEditable": false
      ]) as? SAPFiori.FUIDatePickerFormCell {
      XCTAssert(datePickerTestCell.isEditable == false, "IsEditable should be false")
    } else {
      XCTFail("Cell type should be datePickerFormCellTestCell")
    }
  }

  func testGetFormCellForDatePickerDateTimeMode() {
    var dateTimeEntryMode = "time"
    var datePickerCellParams = getDatePickerParams("", "", dateTimeEntryMode, "")
    if let datePickerTestCell = cellMocker(datePickerCellParams) as? SAPFiori.FUIDatePickerFormCell {
      XCTAssertTrue(datePickerTestCell.datePickerMode == UIDatePickerMode.time,
                    "DateTimeEntryMode is not correct: expected: \(UIDatePickerMode.time) actual: \(datePickerTestCell.datePickerMode)")
    }

    dateTimeEntryMode = "datetime"
    datePickerCellParams = getDatePickerParams("", "", dateTimeEntryMode, "")
    if let datePickerTestCell = cellMocker(datePickerCellParams) as? SAPFiori.FUIDatePickerFormCell {
      XCTAssertTrue(datePickerTestCell.datePickerMode == UIDatePickerMode.dateAndTime,
                    "DateTimeEntryMode is not correct: expected: \(UIDatePickerMode.dateAndTime) actual: \(datePickerTestCell.datePickerMode)")
    }
  }

  private func getDatePickerParams(_ caption: String, _ value: String, _ dateTimeEntryMode: String, _ placeHolder: String) -> [String : Any] {
    return [
      "_Type": "Control.Type.FormCell.DatePicker",
      "_Name": "DatePickercell",
      "Caption": caption,
      "Value": value,
      "DateTimeEntryMode": dateTimeEntryMode,
      "PlaceHolder": placeHolder
    ]
  }

  func testGetFormCellForSegmentedControlWithValidParameters() {
    let caption = "Priority"
    let value = 2
    let segments = ["Low", "Medium", "High"]
    let segmentedControlCellParams = getSegmentedControlParameters(caption, value, segments)

    if let segmentedControlTestCell = cellMocker(segmentedControlCellParams) as? SAPFiori.FUISegmentedControlFormCell {
      XCTAssertNotNil(segmentedControlTestCell, "segmentedControlTestCell should be nil")
      XCTAssert(segmentedControlTestCell.keyName == caption, "Caption is not correct: expected: \(caption) actual: \(segmentedControlTestCell.value)")
      XCTAssert(segmentedControlTestCell.value == value, "Value is not correct: expected: \(value) actual: \(segmentedControlTestCell.value)")
      XCTAssert(segmentedControlTestCell.valueOptions == segments, "segments is not correct: expected: \(segments) actual: \(segmentedControlTestCell.valueOptions)")
      XCTAssert(segmentedControlTestCell.isEditable == true, "IsEditable defaults to true")
    } else {
      XCTFail("Cell type should be SegmentedControl")
    }

    if let segmentedControlTestCell = cellMocker([
      "_Type": "Control.Type.FormCell.SegmentedControl",
      "_Name": "SegmentedControl",
      "Caption": caption,
      "Value": value,
      "Segments": segments,
      "IsEditable": false
      ]) as? SAPFiori.FUISegmentedControlFormCell {
      XCTAssert(segmentedControlTestCell.isEditable == false, "IsEditable should be false")
    } else {
      XCTFail("Cell type should be SegmentedControl")
    }
  }

  func testGetFormCellForSegmentedControlWithInvalidParameters() {
    let caption = 1
    let value = "test"
    let segments = [1, 2, 3]
    let segmentedControlCellParams = getSegmentedControlParameters(caption, value, segments)
    if let segmentedControlTestCell = cellMocker(segmentedControlCellParams) as? SAPFiori.FUISegmentedControlFormCell {
      XCTAssertNotNil(segmentedControlTestCell, "segmentedControlTestCell should be nil")
      XCTAssert(segmentedControlTestCell.keyName == "1", "Caption is not correct: expected: '1' actual: \(segmentedControlTestCell.value)")
      XCTAssert(segmentedControlTestCell.value == -1, "Value is not correct: expected: -1 actual: \(segmentedControlTestCell.value)")
      XCTAssert(segmentedControlTestCell.valueOptions == [], "segments is not correct: expected: [] actual: \(segmentedControlTestCell.valueOptions)")
    } else {
      XCTFail("Cell type should be SegmentedControl")
    }
  }

  private func getSegmentedControlParameters(_ caption: Any, _ value: Any, _ segments:[Any] ) -> [String : Any] {
    return [
      "_Type": "Control.Type.FormCell.SegmentedControl",
      "_Name": "SegmentedControl",
      "Caption": caption,
      "Value": value,
      "Segments": segments
    ]
  }
  // swiftlint:disable function_body_length
  func testGetFormCellForListPickerWithValidParameters() {
    let caption = "Picker"
    let value = [0, 2]
    let pickerItems = ["Low", "Medium", "High"]
    let pickerPrompt = "Choose"
    let allowsMultipleSelection = true
    let isSelectedSectionEnabled = true
    var params = getListPickerControlParameters(caption, value, pickerItems, pickerPrompt, allowsMultipleSelection, isSelectedSectionEnabled)

    let controller = FormCellContainerViewController()
    let cellType = params["_Type"] as? String
    controller.addFormCell(params, withDelegate: FormCellItemDelegate())
    if let cell = FormCellFactory.getFormCell(tableView: controller.tableView,
                                       indexPath: IndexPath.init(),
                                       cellType: cellType!,
                                       cellParams: params,
                                       formCellController: controller,
                                       delegate: FormCellItemDelegate()) as? SAPFiori.FUIListPickerFormCell {
      XCTAssertNotNil(cell, "segmentedControlTestCell should not be nil")
      XCTAssert(cell.keyName == caption, "Caption is not correct: expected: \(caption) actual: \(cell.value)")
      XCTAssert(cell.value == value, "Value is not correct: expected: \(value) actual: \(cell.value)")
      XCTAssert(cell.valueOptions == pickerItems,
                "PickerItems is not correct: expected: \(pickerItems) actual: \(cell.valueOptions)")
      XCTAssert(cell.listPicker.prompt == pickerPrompt,
                "PickerPrompt is not correct: expected: \(pickerPrompt) actual: \(String(describing: cell.listPicker.prompt))")
      XCTAssert(cell.allowsMultipleSelection == allowsMultipleSelection,
                "allowsMultipleSelection is not correct: expected: \(allowsMultipleSelection) actual: \(cell.allowsMultipleSelection)")
      XCTAssert(cell.listPicker.isSelectedSectionEnabled == isSelectedSectionEnabled,
                "isSelectedSectionEnabled is not correct: expected: \(isSelectedSectionEnabled) actual: \(cell.listPicker.isSelectedSectionEnabled)")
      XCTAssert(cell.isEditable == true, "IsEditable defaults to true")
    }

    if let listPickerFormCellTestCellWithEmptySelection = cellMocker([
      "_Type": "Control.Type.FormCell.ListPicker", "_Name": "ListPicker2", "Caption": caption,
      "Value": value, "PickerItems": pickerItems, "AllowMultipleSelection": true, "AllowEmptySelection": false, "PickerPrompt": pickerPrompt,
      "IsEditable": false, "Search": ["Enabled": true, "BarcodeScanner": false]
      ]) as? SAPFiori.FUIListPickerFormCell {
      XCTAssert(listPickerFormCellTestCellWithEmptySelection.isEditable == false, "IsEditable should be false")
      XCTAssert(listPickerFormCellTestCellWithEmptySelection.listPicker.isSearchEnabled == true, "IsSearchEnabled should be true")
      XCTAssert(listPickerFormCellTestCellWithEmptySelection.listPicker.isBarcodeScannerEnabled == false, "IsBarcodeScanEnabled should be false")
      XCTAssert(listPickerFormCellTestCellWithEmptySelection.allowsEmptySelection == false, "Empty selection should be set to false")
    } else {
      XCTFail("Cell type should be ListPickerControl")
    }

    if let listPickerFormCellTestCell = cellMocker([
        "_Type": "Control.Type.FormCell.ListPicker", "_Name": "ListPicker2", "Caption": caption,
        "Value": value, "PickerItems": pickerItems, "AllowMultipleSelection": true, "PickerPrompt": pickerPrompt,
        "IsEditable": false, "Search": ["Enabled": true, "BarcodeScanner": false]
        ]) as? SAPFiori.FUIListPickerFormCell {
        XCTAssert(listPickerFormCellTestCell.isEditable == false, "IsEditable should be false")
        XCTAssert(listPickerFormCellTestCell.listPicker.isSearchEnabled == true, "IsSearchEnabled should be true")
        XCTAssert(listPickerFormCellTestCell.listPicker.isBarcodeScannerEnabled == false, "IsBarcodeScanEnabled should be false")
        XCTAssert(listPickerFormCellTestCell.allowsEmptySelection == true, "Empty selection should be true by default")
    } else {
        XCTFail("Cell type should be ListPickerControl")
    }

  }
  // swiftlint:enable function_body_length

  func testGetFormCellForListPickerWithInvalidParameters() {
    let caption = true
    let value = ["1", "2"]
    let pickerItems = [1, 2, 3]
    let allowsMultipleSelection = "false"
    var listPickerControlCellParams = getListPickerControlParameters(caption, value, pickerItems, "", allowsMultipleSelection)

    // Make this param invalid by removing it
    listPickerControlCellParams.removeValue(forKey: "PickerPrompt")

    if let listPickerFormCellTestCell = cellMocker(listPickerControlCellParams) as? SAPFiori.FUIListPickerFormCell {
      XCTAssertNotNil(listPickerFormCellTestCell, "segmentedControlTestCell should be nil")
      XCTAssert(listPickerFormCellTestCell.keyName == "true", "Caption is not correct: expected: 'true' actual: \(listPickerFormCellTestCell.value)")
      XCTAssert(listPickerFormCellTestCell.value == [], "Value is not correct: expected: [] actual: \(listPickerFormCellTestCell.value)")
      XCTAssert(listPickerFormCellTestCell.valueOptions == [],
                "PickerItems is not correct: expected: [] actual: \(listPickerFormCellTestCell.valueOptions)")
      XCTAssert(listPickerFormCellTestCell.listPicker.prompt == nil,
                "PickerPrompt is not correct: expected: empty string, actual: \(String(describing: listPickerFormCellTestCell.listPicker.prompt))")
      XCTAssert(listPickerFormCellTestCell.allowsMultipleSelection == true,
                "allowsMultipleSelection is not correct: expected: true actual: \(listPickerFormCellTestCell.allowsMultipleSelection)")
    } else {
      XCTFail("Cell type should be SegmentedControl")
    }
  }

  private func getListPickerControlParameters(_ caption: Any, _ value: Any, _ pickerItems: [Any], _ pickerPrompt: Any, _ allowMultipleSelection: Any,
                                              _ isSelectedSectionEnabled: Any = false) -> [String : Any] {
    return [
      "_Type": "Control.Type.FormCell.ListPicker",
      "_Name": "ListPicker2",
      "Caption": caption,
      "Value": value,
      "PickerItems": pickerItems,
      "AllowMultipleSelection": allowMultipleSelection,
      "IsSelectedSectionEnabled": isSelectedSectionEnabled,
      "PickerPrompt": pickerPrompt
      ] as [String : Any]
  }

  internal func cellMocker(_ params: [String: Any]) -> UITableViewCell {
    let formCellContainerViewController = FormCellContainerViewController()
    return cellMocker(with: formCellContainerViewController, params)
  }

  internal func cellMocker(with containerViewController: FormCellContainerViewController, _ params: [String: Any]) -> UITableViewCell {
    let cellType = params["_Type"] as? String
    let myDelegate = FormCellItemDelegateStub()
    containerViewController.addFormCell(params, withDelegate: myDelegate)
    return FormCellFactory.getFormCell(tableView: containerViewController.tableView,
                                       indexPath: IndexPath(row: 1, section: 1),
                                       cellType: cellType!,
                                       cellParams: params,
                                       formCellController: containerViewController,
                                       delegate: myDelegate)
  }

  func testGetFormCellForDurationPicker() {
    let caption = "duration"
    let value = 7200.0
    let minuteInterval = 2

    let durationPickerCellParams = [
      "_Type": "Control.Type.FormCell.DurationPicker",
      "_Name": "duration1",
      "Caption": caption,
      "Value": value,
      "MinuteInterval": minuteInterval
      ] as [String : Any]

    let formCellContainerViewController = FormCellContainerViewController()
    if let durationPickerTestCell = cellMocker(with: formCellContainerViewController, durationPickerCellParams) as? SAPFiori.FUIDurationPickerFormCell {
      XCTAssertNotNil(durationPickerTestCell)
      XCTAssertTrue(durationPickerTestCell.keyName == caption, "Caption is not correct: expected: \(caption) actual: \(String(describing: durationPickerTestCell.keyName))")
      // Can't test durationPickerTestCell.value. The value was reset back to default value but it looks good in screen.
      // Test formCellContainerViewController.durationPickerValue[caption] instead
      XCTAssertTrue(formCellContainerViewController.durationPickerValue[caption] == value,
                    "durationPickerValue is not correct: expected: \(value) actual: \(String(describing: formCellContainerViewController.durationPickerValue[caption]))")
      XCTAssertTrue(durationPickerTestCell.durationPicker.minuteInterval == minuteInterval,
                    "minuteInterval is not correct: expected: \(minuteInterval) actual: \(durationPickerTestCell.durationPicker.minuteInterval)")
      XCTAssert(durationPickerTestCell.isEditable == true, "IsEditable defaults to true")
    }

    if let durationPickerTestCell = cellMocker(with: formCellContainerViewController, [
      "_Type": "Control.Type.FormCell.DurationPicker",
      "_Name": "duration1",
      "Caption": caption,
      "Value": value,
      "MinuteInterval": minuteInterval,
      "IsEditable": false
      ] as [String : Any]) as? SAPFiori.FUIDurationPickerFormCell {
      XCTAssert(durationPickerTestCell.isEditable == false, "IsEditable should be false")
    }
  }
}

class FormCellItemDelegateStub: FormCellItemDelegate {

  public func valueChangedWithParams() {
    print("---VALUE-CHANGED---")
  }
}
