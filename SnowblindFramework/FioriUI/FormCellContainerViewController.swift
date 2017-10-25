//
//  FormTableViewController.swift
//
//
//  Copyright © 2016. SAP. All rights reserved.
//

import UIKit
import SAPFiori

public class FormCellType {
  // swiftlint:disable identifier_name
  enum FormCellType: String {
    case Title = "Control.Type.FormCell.Title"
    case Note = "Control.Type.FormCell.Note"
    case SimpleProperty = "Control.Type.FormCell.SimpleProperty"
    case ListPicker = "Control.Type.FormCell.ListPicker"
    case DatePicker = "Control.Type.FormCell.DatePicker"
    case DurationPicker = "Control.Type.FormCell.DurationPicker"
    case SwitchCell = "Control.Type.FormCell.Switch"
    case SegmentedControl = "Control.Type.FormCell.SegmentedControl"
    case Attachment = "Control.Type.FormCell.Attachment"
    case Button = "Control.Type.FormCell.Button"
    case Filter = "Control.Type.FormCell.Filter"
    case Sorter = "Control.Type.FormCell.Sorter"
  }
}

@objc
public class FormCellContainerViewController: FUIFormTableViewController, FullScreenTableViewControllerTraits, UITextFieldDelegate {

  // For each attachment form cell we need a different delegate instance
  public var aDelegates = [IndexPath: AttachmentFormViewDelegate]()
  @objc
  public var numberOfSections: Int = 0
  // The number of rows by section. Includes rows even if they're not currently visible.
  @objc
  public var numberOfRowsInSection: [Int] = []
  @objc
  public var sectionNames: [String] = []
  @objc
  public var isInPopover: Bool = false
  // Global design states header height is 30
  //https://experience.sap.com/fiori-design-ios/article/grid-design/#divider
  let sectionHeaderHeight: CGFloat = 30.0

  private var cellTypesForSection: [Int : [[String: Any]]] = [:]
  // Doesn't need to change because it's only used to determine section.
  // Includes rows even if they're not currently visible.
  private var totalNumberOfRows: Int = 0

  /**
   This property's role is to keep the DatePicker's value when changed in the UI as the control
   (DatePickerFormCell) does not after a refresh cycle.
   This situation arises because there are 2 states for the Picker:  Label mode and Picker mode.
   The Picker gets refreshed every time the control changes state and the value is not kept in the Picker.
   */
  // TODO:  refactor this out when Observable is implemented.

  public var datePickerValue: [String: Date] = [:]
  public var durationPickerValue: [String: Double] = [:]

  // delegates
  //private var delegates = [FormCellItemDelegate]()
  // Maps params["_Name"] to FormCellItemDelegate
  private var delegates = [String: FormCellItemDelegate]()

  public func didChangeValue(for name: String!, with data: [String: Any]) {
    let delegate: FormCellItemDelegate = delegates[name]!
    delegate.perform(NSSelectorFromString("valueChangedWithParams"), with: data)
  }

  // MARK: - ViewController methods

  open override func viewDidLoad() {
    super.viewDidLoad()
    self.onFullScreenTableViewControllerLoaded()
    self.tableView.estimatedRowHeight = 98
    self.tableView.rowHeight = UITableViewAutomaticDimension
    self.tableView.estimatedSectionHeaderHeight = sectionHeaderHeight
  }

  open override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    self.onFullScreenTableViewControllerAppeared()
  }

  // MARK: - TableViewController methods

  open override func numberOfSections(in tableView: UITableView) -> Int {
    return self.numberOfSections
  }

  open override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if let cellsInSection: [[String: Any]] = self.cellTypesForSection[section] {
      return cellsInSection.filter(self.isCellVisible).count
    }
    return 0
  }

  open override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String {
    return self.sectionNames[section]
  }

  open override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    var tableViewCell: UITableViewCell? = nil
    if let cellsInSection: [[String: Any]] = self.cellTypesForSection[indexPath.section] {
      let cellParams: [String: Any] = cellsInSection.filter(self.isCellVisible)[indexPath.row]
      let type: String = (cellParams["_Type"] as? String)!
      let name: String = (cellParams["_Name"] as? String)!
      let delegate: FormCellItemDelegate = delegates[name]!
      tableViewCell = FormCellFactory.getFormCell(tableView: tableView, indexPath: indexPath, cellType: type, cellParams: cellParams,
                                                  formCellController: self, delegate:delegate)

      if let tableViewCell = tableViewCell as? FUIBaseTableViewCell {
        let maxItemCount: Int = cellsInSection.filter(self.isCellVisible).count
        if indexPath.row != (maxItemCount-1) {
          tableViewCell.separators = .bottom
        } else {
          tableViewCell.separators = []
        }
      }
    }
    return tableViewCell!
  }

  // Set the section header height to 30 points (SNOWBLIND-3621)
  override public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    if self.isInPopover {
      // SB-5088: Hiding first section header if the page is in a popover and the header title is empty
      if section == 0 && self.sectionNames[section] == "" {
        return 0
      }
    }
    return self.sectionHeaderHeight
  }

  // Remove section footer (SNOWBLIND-3621).  Currently, no footer support from metadata.
  // If footer support will be added, a more robust solution is needed
  override public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    return nil
  }

  // Remove section footer (SNOWBLIND-3621).  Currently, no footer support from metadata.
  // If footer support will be added, a more robust solution is needed
  override public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return CGFloat.leastNormalMagnitude
  }

  // MARK: - Implementation

  // TODO:  This method trips swiftlint (force_cast) rule.  Please refactor.
  // TODO:  This method trips swiftlint (cyclomatic_complexity) rule.  Please refactor.
  // TODO:  This method trips swiftlint (function_body_length) rule.  Please refactor.
  @objc
  // swiftlint:disable function_body_length
  // swiftlint:disable:next cyclomatic_complexity
  public func addFormCell(_ params: [String: Any], withDelegate delegate: FormCellItemDelegate) {

    let type: String = (params["_Type"] as? String)!
    if let cellType = FormCellType.FormCellType(rawValue: type) {
      switch cellType {
      case .Title:
        self.tableView.register(FUITitleFormCell.self, forCellReuseIdentifier: FUITitleFormCell.reuseIdentifier)
        break
      case .Note:
        self.tableView.register(FUINoteFormCell.self, forCellReuseIdentifier: FUINoteFormCell.reuseIdentifier)
        break
      case .SimpleProperty:
        self.tableView.register(FUISimplePropertyFormCell.self, forCellReuseIdentifier: FUISimplePropertyFormCell.reuseIdentifier)
        break
      case .ListPicker:
        self.tableView.register(FUIListPickerFormCell.self, forCellReuseIdentifier: FUIListPickerFormCell.reuseIdentifier)
        break
      case .DatePicker:
        self.tableView.register(FUIDatePickerFormCell.self, forCellReuseIdentifier: FUIDatePickerFormCell.reuseIdentifier)
        break
      case .DurationPicker:
        self.tableView.register(FUIDurationPickerFormCell.self, forCellReuseIdentifier: FUIDurationPickerFormCell.reuseIdentifier)
        break
      case .SwitchCell:
        self.tableView.register(FUISwitchFormCell.self, forCellReuseIdentifier: FUISwitchFormCell.reuseIdentifier)
        break
      case .SegmentedControl:
        self.tableView.register(FUISegmentedControlFormCell.self, forCellReuseIdentifier: FUISegmentedControlFormCell.reuseIdentifier)
        break
      case .Attachment:
        self.tableView.register(FUIAttachmentsFormCell.self, forCellReuseIdentifier: FUIAttachmentsFormCell.reuseIdentifier)
        break
      case .Button:
        self.tableView.register(FUIButtonFormCell.self, forCellReuseIdentifier: FUIButtonFormCell.reuseIdentifier)
        break
      case .Filter:
        self.tableView.register(FUIFilterFormCell.self, forCellReuseIdentifier: FUIFilterFormCell.reuseIdentifier)
        break
      case .Sorter:
        self.tableView.register(FUIFilterFormCell.self, forCellReuseIdentifier: FUIFilterFormCell.reuseIdentifier)
        break
      }
      let name: String = (params["_Name"] as? String)!
      delegates[name] = delegate

      self.totalNumberOfRows += 1
      let currentSectionNumber: Int = findSectionForRow(self.totalNumberOfRows)
      if var sectionTypes = self.cellTypesForSection[currentSectionNumber] {
        sectionTypes.append(params)
        self.cellTypesForSection[currentSectionNumber] = sectionTypes
      } else {
        self.cellTypesForSection[currentSectionNumber] = [ params ]
      }
    }
  }
  // swiftlint:enable function_body_length

  @objc
  public func updateFormCell(_ params: [String: Any], cellRow row: Int, cellSection section: Int) {
    let indexPath = IndexPath(row: row, section: section)
    let cell = self.tableView.cellForRow(at: indexPath)

    // Save the updated params for this form cell
    self.cellTypesForSection[indexPath.section]?[indexPath.row] = params

    if let cell =  cell as? FUIListPickerFormCell {
      if let pickerItems = ParameterHelper.getParameterAsNSDictionaryArray(cellParams: params, paramName: FormCellFactory.Parameters.PickerItems.rawValue) {
        if let listPickerDataSource = cell.listPicker.dataSource as? ListPickerDataSource {
          listPickerDataSource.update(data: pickerItems)
          cell.listPicker.reloadData()
        }
      }
    }
  }

  /**
   Update form cell with an array of udpated formCell values.
   @param params The NSArray* which contains NSDictionary that stores formCell property values
   @param style The NUI style class for the container
   */
  // TODO:  This method trips swiftlint (force_cast) rule.  Please refactor.
  @objc
  public func updateFormCells(_ params: NSArray, withStyle style: String?) {
    var cellIndex = 0
    // Assign the updated property values to cellTypesForSection
    for i in 0..<numberOfRowsInSection.count {
      for j in 0..<numberOfRowsInSection[i] {
        cellTypesForSection[i]?[j] = params[cellIndex] as! Dictionary // swiftlint:disable:this force_cast
        cellIndex += 1
      }
    }

    if style != nil {
      self.tableView.nuiClass = style
    }

    // SB-5091: Do not redraw the whole page if the change is from durationPickerFormCell or datePickerFormCell
    if FormCellFactory.needRedraw {
      self.tableView.reloadData()
    }
    FormCellFactory.needRedraw = true
  }

  public func updateParamsWithValue(_ newValue: Dictionary<String, Any>, _ indexPath: IndexPath) {
    /** SB-5138
    * Before the fix, the update param is updating params into array without checking the visibility of the row.
    * But the formcell is created based on visibility and the indexPath row number is from filtered visible rows.
    * This is causing mismatch on params and will cause the stored value in params not being displayed correctly.
    * Fix: Update params according to actual indexPath row number (including not visible row).
    */
    var actualRow: Int = -1
    var visibleRow: Int = -1
    if let cellsInSection: [[String: Any]] = self.cellTypesForSection[indexPath.section] {
      for cellParams in cellsInSection {
        actualRow += 1
        if self.isCellVisible(cellParams: cellParams) {
          visibleRow += 1
          if visibleRow == indexPath.row {
            break
          }
        }
      }
    }
    if actualRow > -1 {
      self.cellTypesForSection[indexPath.section]?[actualRow]["Value"] = newValue["Value"]!
    }
  }

  private func findSectionForRow(_ row: Int) -> Int {
    var tmpRows: Int = 0
    for i in 0..<self.numberOfRowsInSection.count {
      tmpRows += self.numberOfRowsInSection[i]
      if row <= tmpRows {
        return i
      }
    }
    return tmpRows
  }

  public func getCellTypesForSection() -> [Int : [[String: Any]]] {
    return self.cellTypesForSection
  }

  // Validate the text field in SimplePropertyFormCell. If it is numeric, allow only numbers and decimal point.
  open func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    if textField.keyboardType == .decimalPad {
      if let currentText = textField.text, currentText.isEmpty && string == "-" {
        // Only first char can be "-"
        return true
      }
      if textField.text?.range(of: ".") != nil && string.range(of: ".") != nil {
        // A decimal point already entered.
        return false
      }
      let allowedChars = CharacterSet.decimalDigits
      let characterSet  = CharacterSet(charactersIn: string)
      return allowedChars.isSuperset(of: characterSet) || string == "."
    }
    // non-numeric field.
    return true
  }

  // Dismiss keyboard on return press
  open func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return true
  }

  // TODO:  This method trips swiftlint (force_cast) rule.  Please refactor.
  private func isCellVisible(cellParams: [String: Any]) -> Bool {
    if let isVisible = cellParams["IsVisible"] {
      return isVisible as! Bool // swiftlint:disable:this force_cast
    }
    return true
  }
}
