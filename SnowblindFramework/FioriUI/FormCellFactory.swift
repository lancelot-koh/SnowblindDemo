//
//  FormCellFactory.swift
//  SAPMDCFramework
//
//  Created by Tan, Jin Na on 12/9/16.
//  Copyright © 2016 SAP. All rights reserved.
//
import Foundation
import SAPFiori
import Photos

public class FormCellFactory {

  // swiftlint:disable identifier_name
  enum Parameters: String {
    case Value
    case PlaceHolder
    case Caption
    case DateTimeEntryMode
    case Segments
    case AllowMultipleSelection
    case AllowEmptySelection
    case IsAutoResizing
    case CollectionItems
    case PickerPrompt
    case PickerItems
    case MinuteInterval
    case IsEditable
    case IsSearchEnabled
    case IsBarcodeScanEnabled
    case IsSelectedSectionEnabled
    case FilterItems
    case SortByItems
    case AttachmentActionType
    case AttachmentTitle
    case AttachmentAddTitle
    case AttachmentCancelTitle
    case KeyboardType
    case ValidationMessage
    case ValidationMessageColor
    case SeparatorBackgroundColor
    case SeparatorIsHidden
    case ValidationViewBackgroundColor
    case ValidationViewIsHidden
    case Styles
    case Switch
    case Title
    case Background
    case ApportionsSegmentWidthsByContent
    case TextAlignment
    case IsDataSourceRequiringUniqueIdentifiers
    case AddedAttachments
    case DeletedAttachments
  }

  // [SB-5091] To remember whether the value changes need redraw the view
  public static var needRedraw: Bool = true

  // TODO:  This method trips swiftlint (function_parameter_count) rule.  Please refactor.
  // swiftlint:disable function_parameter_count
  // swiftlint:disable cyclomatic_complexity
  // swiftlint:disable file_length
  public static func getFormCell(tableView: UITableView, indexPath: IndexPath, cellType: String, cellParams: [String: Any],
                                 formCellController: FormCellContainerViewController, delegate: FormCellItemDelegate) -> UITableViewCell {
    let type: FormCellType.FormCellType = FormCellType.FormCellType(rawValue: cellType)!
    var tableViewCell: UITableViewCell? = nil
    switch type {
    case .Title:
      tableViewCell = titleFormCell(tableView: tableView, indexPath: indexPath, cellParams: cellParams, formCellController: formCellController, delegate: delegate)
      break
    case .Note:
      tableViewCell = noteFormCell(tableView: tableView, indexPath: indexPath, cellParams: cellParams, formCellController: formCellController, delegate: delegate)
      break
    case .SimpleProperty:
      tableViewCell = simplePropertyFormCell(tableView: tableView, indexPath: indexPath, cellParams: cellParams, formCellController: formCellController, delegate: delegate)
      break
    case .ListPicker:
      tableViewCell = listPickerFormCell(tableView: tableView, indexPath: indexPath, cellParams: cellParams, formCellController: formCellController, delegate: delegate)
      break
    case .DatePicker:
      tableViewCell = datePickerFormCell(tableView: tableView, indexPath: indexPath, cellParams: cellParams, formCellController: formCellController, delegate: delegate)
      break
    case .DurationPicker:
      tableViewCell = durationPickerFormCell(tableView: tableView, indexPath: indexPath, cellParams: cellParams, formCellController: formCellController, delegate: delegate)
      break
    case .SwitchCell:
      tableViewCell = switchFormCell(tableView: tableView, indexPath: indexPath, cellParams: cellParams, formCellController: formCellController, delegate: delegate)
      break
    case .SegmentedControl:
      tableViewCell = segmentedControlFormCell(tableView: tableView, indexPath: indexPath, cellParams: cellParams, formCellController: formCellController, delegate: delegate)
      break
    case .Attachment:
      tableViewCell = attachmentFormCell(tableView: tableView, indexPath: indexPath, cellParams: cellParams, formCellController: formCellController, delegate: delegate)
      break
    case .Button:
      tableViewCell = buttonFormCell(tableView: tableView, indexPath: indexPath, cellParams: cellParams, formCellController: formCellController, delegate: delegate)
      break
    case .Filter:
      tableViewCell = filterFormCell(tableView: tableView, indexPath: indexPath, cellParams: cellParams, formCellController: formCellController, delegate: delegate, sorter: false)
      break
    case .Sorter:
      tableViewCell = filterFormCell(tableView: tableView, indexPath: indexPath, cellParams: cellParams, formCellController: formCellController, delegate: delegate, sorter: true)
      break
    }
    return tableViewCell!
  }
  // swiftlint:enable cyclomatic_complexity

  // This helper us used by the onChangeHandler to notify the FormCellItemDelegate that a new value is used
  /** SB-5138
  * Before fix, the onChangeHandler is not calling update params,
  * causing the value is not displayed when the control goes out of view.
  * Fix: add a call to updateParamsWithValue on every onChangeHandler, and
  * merge notifyFormCellUpdate and notifyFormCellUpdateForPickers as it is performing same action.
  */
  private static func notifyFormCellUpdate<ValueType>(_ delegate: FormCellItemDelegate, _ newValue: ValueType, _ iPath: IndexPath, _ formCellController: FormCellContainerViewController) -> Void {
    let params = ["Value": newValue]
    formCellController.updateParamsWithValue(params, iPath)
    let selector = NSSelectorFromString("valueChangedWithParams")
    if delegate.responds(to: selector) {
      delegate.perform(selector, with: params)
    }
  }

  private static func titleFormCell(tableView: UITableView, indexPath: IndexPath, cellParams: [String: Any],
                                    formCellController: FormCellContainerViewController, delegate: FormCellItemDelegate) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: FUITitleFormCell.reuseIdentifier, for: indexPath)
    if let cell =  cell as? FUITitleFormCell {
      if let value = ParameterHelper.getParameterAsString(cellParams: cellParams, paramName: Parameters.Value.rawValue) {
        cell.value = value
      }
      if let placeHolder = ParameterHelper.getParameterAsString(cellParams: cellParams, paramName: Parameters.PlaceHolder.rawValue) {
        cell.placeholderText  = placeHolder
      }
      if let isEditable = ParameterHelper.getParameterAsBool(cellParams: cellParams, paramName: Parameters.IsEditable.rawValue) {
        cell.isEditable = isEditable
      }

      // Styling
      if let styles = ParameterHelper.getParameterAsDictionary(cellParams: cellParams, paramName: Parameters.Styles.rawValue) {
        if let backgroundStyle = ParameterHelper.getParameterAsString(cellParams: styles, paramName: Parameters.Background.rawValue) {
          setBackgroundStyle(view: cell, style: backgroundStyle)
        }

        if let titleStyle = ParameterHelper.getParameterAsString(cellParams: styles, paramName: Parameters.Value.rawValue) {
          cell.valueTextField.nuiClass = titleStyle
        }
      }

      // set validation message and view
      setValidationView(for: cell, with: cellParams)
      cell.isTrackingLiveChanges = true
      cell.onChangeHandler = { newValue in
        self.needRedraw = true
        notifyFormCellUpdate(delegate, newValue, indexPath, formCellController)
      }
    }
    return cell
  }

  private static func noteFormCell(tableView: UITableView, indexPath: IndexPath, cellParams: [String: Any],
                                   formCellController: FormCellContainerViewController, delegate: FormCellItemDelegate) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: FUINoteFormCell.reuseIdentifier, for: indexPath)
    if let cell =  cell as? FUINoteFormCell {
      if let value = ParameterHelper.getParameterAsString(cellParams: cellParams, paramName: Parameters.Value.rawValue) {
        cell.value = value
      }
      if let placeholder = ParameterHelper.getParameterAsString(cellParams: cellParams, paramName: Parameters.PlaceHolder.rawValue) {
        cell.placeholderText  = placeholder
      }
      if let isEditable = ParameterHelper.getParameterAsBool(cellParams: cellParams, paramName: Parameters.IsEditable.rawValue) {
        cell.isEditable = isEditable
      }
      if let isAutoResizing = ParameterHelper.getParameterAsBool(cellParams: cellParams, paramName: Parameters.IsAutoResizing.rawValue) {
        cell.isAutoFitting = isAutoResizing
      }

      // Styling
      if let styles = ParameterHelper.getParameterAsDictionary(cellParams: cellParams, paramName: Parameters.Styles.rawValue) {
        if let backgroundStyle = ParameterHelper.getParameterAsString(cellParams: styles, paramName: Parameters.Background.rawValue) {
          setBackgroundStyle(view: cell, style: backgroundStyle)
        }

        if let notetextStyle = ParameterHelper.getParameterAsString(cellParams: styles, paramName: Parameters.Value.rawValue) {
          cell.valueTextView.nuiClass = notetextStyle
        }
      }

      // set validation message and view
      setValidationView(for: cell, with: cellParams)
      cell.isTrackingLiveChanges = true
      cell.onChangeHandler = { newValue in
        self.needRedraw = true
        notifyFormCellUpdate(delegate, newValue, indexPath, formCellController)
      }
    }
    return cell
  }

  private static func simplePropertyFormCell(tableView: UITableView, indexPath: IndexPath, cellParams: [String: Any],
                                             formCellController: FormCellContainerViewController, delegate: FormCellItemDelegate) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: FUISimplePropertyFormCell.reuseIdentifier, for: indexPath)
    if let cell =  cell as? FUISimplePropertyFormCell {
      cell.valueTextField.delegate = formCellController
      if let value = ParameterHelper.getParameterAsString(cellParams: cellParams, paramName: Parameters.Value.rawValue) {
        cell.value = value
      }
      if let placeholder = ParameterHelper.getParameterAsString(cellParams: cellParams, paramName: Parameters.PlaceHolder.rawValue) {
        cell.placeholderText  = placeholder
      }
      if let caption = ParameterHelper.getParameterAsString(cellParams: cellParams, paramName: Parameters.Caption.rawValue) {
        cell.keyName = caption
      }
      if let isEditable = ParameterHelper.getParameterAsBool(cellParams: cellParams, paramName: Parameters.IsEditable.rawValue) {
        cell.isEditable = isEditable
      }
      if let keyboardType = ParameterHelper.getParameterAsString(cellParams: cellParams, paramName: Parameters.KeyboardType.rawValue) {
        cell.valueTextField.keyboardType = getKeyboardType(keyboardType: keyboardType)
      }

      // Styling
      if let styles = ParameterHelper.getParameterAsDictionary(cellParams: cellParams, paramName: Parameters.Styles.rawValue) {
        if let backgroundStyle = ParameterHelper.getParameterAsString(cellParams: styles, paramName: Parameters.Background.rawValue) {
          setBackgroundStyle(view: cell, style: backgroundStyle)
        }

        if let captionStyle = ParameterHelper.getParameterAsString(cellParams: styles, paramName: Parameters.Caption.rawValue) {
          cell.keyLabel.nuiClass = captionStyle
        }

        if let valueStyle = ParameterHelper.getParameterAsString(cellParams: styles, paramName: Parameters.Value.rawValue) {
          cell.valueTextField.nuiClass = valueStyle
        }
      }

      // set validation message and view
      setValidationView(for: cell, with: cellParams)
      cell.isTrackingLiveChanges = true
      cell.onChangeHandler = { newValue in
        self.needRedraw = true
        notifyFormCellUpdate(delegate, newValue, indexPath, formCellController)
      }
    }
    return cell
  }

  private static func getKeyboardType(keyboardType: String) -> UIKeyboardType {
    switch keyboardType {
    case "Email":
      return UIKeyboardType.emailAddress
    case "Number":
      return UIKeyboardType.decimalPad
    case "Phone":
      return UIKeyboardType.phonePad
    case "Url":
      return UIKeyboardType.URL
    case "DateTime":
      return UIKeyboardType.numbersAndPunctuation
    default:
      return UIKeyboardType.default
    }
  }

  private static func buttonFormCell(tableView: UITableView, indexPath: IndexPath, cellParams: [String: Any],
                                     formCellController: FormCellContainerViewController, delegate: FormCellItemDelegate) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: FUIButtonFormCell.reuseIdentifier, for: indexPath)
    if let cell = cell as? FUIButtonFormCell {
      let alignmentString: String? = ParameterHelper.getParameterAsString(cellParams: cellParams, paramName: Parameters.TextAlignment.rawValue)
      let alignment: FUIButtonWrapper.ContentAlignment = FUIButtonWrapper.alignmentFromString(alignment: alignmentString)
      // Convert to SAPFiori.FUIHorizontalAlignment
      switch alignment {
      case .center:
        cell.alignment = .center
        break
      case .left:
        cell.alignment = .left
        break
      case .right:
        cell.alignment = .right
        break
      }
      if let title = ParameterHelper.getParameterAsString(cellParams: cellParams, paramName: Parameters.Title.rawValue) {
        cell.button.setTitle(title, for: UIControlState.normal)
      }
      cell.onChangeHandler = { newValue in
        self.needRedraw = true
        let params = ["Button": cell.button]
        let selector = NSSelectorFromString("valueChangedWithParams")
        if delegate.responds(to: selector) {
          delegate.perform(selector, with: params)
        }
      }
      // Styling
      if let styles = ParameterHelper.getParameterAsDictionary(cellParams: cellParams, paramName: Parameters.Styles.rawValue) {
        if let backgroundStyle = ParameterHelper.getParameterAsString(cellParams: styles, paramName: Parameters.Background.rawValue) {
          setBackgroundStyle(view: cell, style: backgroundStyle)
        }

        if let buttonStyle = ParameterHelper.getParameterAsString(cellParams: styles, paramName: Parameters.Value.rawValue) {
          cell.button.nuiClass = buttonStyle
        }
      }
    }
    return cell
  }

  private static func switchFormCell(tableView: UITableView, indexPath: IndexPath, cellParams: [String: Any],
                                     formCellController: FormCellContainerViewController, delegate: FormCellItemDelegate) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: FUISwitchFormCell.reuseIdentifier, for: indexPath)
    if let cell =  cell as? FUISwitchFormCell {
      if let caption = ParameterHelper.getParameterAsString(cellParams: cellParams, paramName: Parameters.Caption.rawValue) {
        cell.keyName = caption
      }
      if let value = ParameterHelper.getParameterAsBool(cellParams: cellParams, paramName: Parameters.Value.rawValue) {
        cell.value = value
      }
      if let isEditable = ParameterHelper.getParameterAsBool(cellParams: cellParams, paramName: Parameters.IsEditable.rawValue) {
        cell.isEditable = isEditable
      }

      // Styling
      if let styles = ParameterHelper.getParameterAsDictionary(cellParams: cellParams, paramName: Parameters.Styles.rawValue) {
        if let backgroundStyle = ParameterHelper.getParameterAsString(cellParams: styles, paramName: Parameters.Background.rawValue) {
          setBackgroundStyle(view: cell, style: backgroundStyle)
        }

        if let captionStyle = ParameterHelper.getParameterAsString(cellParams: styles, paramName: Parameters.Caption.rawValue) {
          cell.keyLabel.nuiClass = captionStyle
        }

        if let switchStyle = ParameterHelper.getParameterAsString(cellParams: styles, paramName: Parameters.Switch.rawValue) {
          cell.switchView.nuiClass = switchStyle
        }
      }

      // set validation message and view
      setValidationView(for: cell, with: cellParams)
      cell.onChangeHandler = { newValue in
        self.needRedraw = true
        notifyFormCellUpdate(delegate, newValue, indexPath, formCellController)
      }
    }
    return cell
  }

  // This method is used just for setting the background of the whole cell.
  // It has to be applied first among the styling properties.
  private static func setBackgroundStyle(view: UIView, style: String) {
    view.nuiClass = style
    for subView in view.subviews {
      setBackgroundStyle(view: subView, style: style)
    }
  }

  // TODO:  This method trips swiftlint (cyclomatic_complexity) rule.  Please refactor.
  // swiftlint:disable cyclomatic_complexity
  private static func datePickerFormCell(tableView: UITableView, indexPath: IndexPath, cellParams: [String: Any],
                                         formCellController: FormCellContainerViewController, delegate: FormCellItemDelegate) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: FUIDatePickerFormCell.reuseIdentifier, for: indexPath)
    if let cell =  cell as? FUIDatePickerFormCell {
      if let caption = ParameterHelper.getParameterAsString(cellParams: cellParams, paramName: Parameters.Caption.rawValue) {
        cell.keyName = caption
      }

      if let placeholder = ParameterHelper.getParameterAsString(cellParams: cellParams, paramName: Parameters.PlaceHolder.rawValue) {
        cell.placeholderText = placeholder
      }
      if let isEditable = ParameterHelper.getParameterAsBool(cellParams: cellParams, paramName: Parameters.IsEditable.rawValue) {
        cell.isEditable = isEditable
      }

      // Styling
      if let styles = ParameterHelper.getParameterAsDictionary(cellParams: cellParams, paramName: Parameters.Styles.rawValue) {
        if let backgroundStyle = ParameterHelper.getParameterAsString(cellParams: styles, paramName: Parameters.Background.rawValue) {
          setBackgroundStyle(view: cell, style: backgroundStyle)
        }

        if let labelStyle = ParameterHelper.getParameterAsString(cellParams: styles, paramName: Parameters.Caption.rawValue) {
          cell.keyLabel.nuiClass = labelStyle
        }

        if let valueStyle = ParameterHelper.getParameterAsString(cellParams: styles, paramName: Parameters.Value.rawValue) {
          cell.valueTextField.nuiClass = valueStyle
        }
      }

      // set validation message and view
      setValidationView(for: cell, with: cellParams)
      // initValue might always override the current one
      if let caption = cell.keyName, let currentValue = formCellController.datePickerValue[caption] {
        cell.value = currentValue
      }

      if let localDateOrTimeString = ParameterHelper.getParameterAsString(cellParams: cellParams, paramName: Parameters.Value.rawValue) {
        let utcDate = DataServiceUtils.utcDateFromString(localDateOrTimeString, withTimeZoneAbbreviation: ODataServiceProvider.serviceTimeZoneAbbreviation)
        cell.value = utcDate
        if let caption = cell.keyName {
          if formCellController.datePickerValue[caption] != utcDate {
            formCellController.datePickerValue[caption] = utcDate
            DispatchQueue.global(qos: .background).async {
              notifyFormCellUpdate(delegate, utcDate, indexPath, formCellController)
            }
          }
        }
      }

      if let datePickerMode = ParameterHelper.getParameterAsString(cellParams: cellParams, paramName: Parameters.DateTimeEntryMode.rawValue) {
        if datePickerMode.caseInsensitiveCompare("date") == ComparisonResult.orderedSame {
          cell.datePickerMode = UIDatePickerMode.date
        } else if datePickerMode.caseInsensitiveCompare("time") == ComparisonResult.orderedSame {
          cell.datePickerMode = UIDatePickerMode.time
        } else {
          cell.datePickerMode = UIDatePickerMode.dateAndTime
        }
      }

      cell.isTrackingLiveChanges = true

      cell.onChangeHandler = { newValue in
        self.needRedraw = false
        notifyFormCellUpdate(delegate, newValue, indexPath, formCellController)
      }
    }
    return cell
  }

  private static func durationPickerFormCell(tableView: UITableView, indexPath: IndexPath, cellParams: [String: Any],
                                             formCellController: FormCellContainerViewController, delegate: FormCellItemDelegate) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: FUIDurationPickerFormCell.reuseIdentifier, for: indexPath)
    if let cell =  cell as? FUIDurationPickerFormCell {
      if let caption = ParameterHelper.getParameterAsString(cellParams: cellParams, paramName: Parameters.Caption.rawValue) {
        cell.keyName = caption
      }
      if let isEditable = ParameterHelper.getParameterAsBool(cellParams: cellParams, paramName: Parameters.IsEditable.rawValue) {
        cell.isEditable = isEditable
      }

      // Styling
      if let styles = ParameterHelper.getParameterAsDictionary(cellParams: cellParams, paramName: Parameters.Styles.rawValue) {
        if let backgroundStyle = ParameterHelper.getParameterAsString(cellParams: styles, paramName: Parameters.Background.rawValue) {
          setBackgroundStyle(view: cell, style: backgroundStyle)
        }

        if let captionStyle = ParameterHelper.getParameterAsString(cellParams: styles, paramName: Parameters.Caption.rawValue) {
          cell.keyLabel.nuiClass = captionStyle
        }

        if let valueStyle = ParameterHelper.getParameterAsString(cellParams: styles, paramName: Parameters.Value.rawValue) {
          cell.valueTextField.nuiClass = valueStyle
        }
      }

      // set validation message and view
      setValidationView(for: cell, with: cellParams)
      // initValue might always override the current one
      if let caption = cell.keyName, let currentValue = formCellController.durationPickerValue[caption] {
        cell.value = currentValue
      }

      if let initValue = ParameterHelper.getParameterAsDouble(cellParams: cellParams, paramName: Parameters.Value.rawValue) {
        cell.value = initValue
        if let caption = cell.keyName {
          formCellController.durationPickerValue[caption] = initValue
        }
      }

      if let minuteInterval = ParameterHelper.getParameterAsInt(cellParams: cellParams, paramName: Parameters.MinuteInterval.rawValue) {
        cell.durationPicker.minuteInterval = minuteInterval
      }

      cell.isTrackingLiveChanges = true
      cell.onChangeHandler = { newValue in
        // TODO:  refactor this out when Observable is implemented.
        if let caption = cell.keyName {
          formCellController.durationPickerValue[caption] = newValue
        }
        self.needRedraw = false
        notifyFormCellUpdate(delegate, newValue, indexPath, formCellController)
      }
    }
    return cell
  }

  private static func setPickerFormCellProperties(pickerFormcellParam: FUIListPickerFormCell, cellParams: [String: Any]) {
    // As per design spec
    pickerFormcellParam.listPicker.tintColor = UIColor.preferredFioriColor(forStyle: .tintColorDark)
    if let caption = ParameterHelper.getParameterAsString(cellParams: cellParams, paramName: Parameters.Caption.rawValue) {
      pickerFormcellParam.keyName = caption
    }
  }

  // TODO:  This method trips swiftlint cyclomatic_complexity i.e. it is too long.  REFACTOR please.
  // swiftlint:disable cyclomatic_complexity
  // swiftlint:disable function_body_length
  private static func listPickerFormCell(tableView: UITableView, indexPath: IndexPath, cellParams: [String: Any],
                                         formCellController: FormCellContainerViewController, delegate: FormCellItemDelegate) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: FUIListPickerFormCell.reuseIdentifier, for: indexPath)
    if let cell =  cell as? FUIListPickerFormCell {
      setPickerFormCellProperties(pickerFormcellParam:cell, cellParams:cellParams)
      if let caption = ParameterHelper.getParameterAsString(cellParams: cellParams, paramName: Parameters.Caption.rawValue) {
        cell.keyName = caption
      }
      let search = Search(params: cellParams as NSDictionary)
      if ParameterHelper.getParameterAsBool(cellParams: cellParams, paramName: Parameters.IsDataSourceRequiringUniqueIdentifiers.rawValue) != nil {

        // This is a picker with paging (UUID based)
        cell.listPicker.isDataSourceRequiringUniqueIdentifiers = true

        if let pickerItems = ParameterHelper.getParameterAsNSDictionaryArray(cellParams: cellParams, paramName: Parameters.PickerItems.rawValue) {

          let initValue: [NSDictionary] = ParameterHelper.getParameterAsNSDictionaryArray(cellParams: cellParams, paramName: Parameters.Value.rawValue) ?? []

          let dataSource = ListPickerDataSource(name: cell.keyName!, data: pickerItems, initiallySelectedData:initValue, delegate: delegate, search: search)
          cell.listPicker.dataSource = dataSource
          cell.listPicker.searchResultsUpdating = dataSource
          cell.listPicker.searchBarDelegate = dataSource

          // The value only uses the unique IDs
          cell.uuidValues = initValue.map({(item: NSDictionary) -> String in
            return item["UniqueId"] as? String ?? ""
          }).filter({(uniqueId: String) -> Bool in
            return !uniqueId.isEmpty
          })

          // When the ListPicker has a data source, we are in charge of setting its UI value ourselves
          cell.valueTextField.text = initValue.map({(item: NSDictionary) -> String in
            return item["DisplayValue"] as? String ?? ""
          }).joined(separator: ", ")

          cell.onUuidChangeHandler = { newValue in
            self.needRedraw = true
            notifyFormCellUpdate(delegate, newValue, indexPath, formCellController)
          }
        }
      } else {
        // For pickers that don't use paging, we use the default selection/searching implementation in the SDK library
        if let pickerItems = ParameterHelper.getParameterAsStringArray(cellParams: cellParams, paramName: Parameters.PickerItems.rawValue) {
          cell.valueOptions = pickerItems

          if let initValue = ParameterHelper.getParameterAsIntArray(cellParams: cellParams, paramName: Parameters.Value.rawValue) {
            cell.value = initValue
          } else {
            cell.value = []
          }

          cell.onChangeHandler = { newValue in
            notifyFormCellUpdate(delegate, newValue, indexPath, formCellController)
          }
        }
      }
      if let isSelectedSectionEnabled = ParameterHelper.getParameterAsBool(cellParams: cellParams, paramName: Parameters.IsSelectedSectionEnabled.rawValue) {
        cell.listPicker.isSelectedSectionEnabled = isSelectedSectionEnabled
      } else {
        // default value is false: SNOWBLIND-4235
        cell.listPicker.isSelectedSectionEnabled = false
      }

      cell.listPicker.isSearchEnabled = search.enabled
      cell.listPicker.isBarcodeScannerEnabled = search.barcodeScanner
      // TODO:  Should probably refactor the metadata to match SAPFiori naming:  PickerPrompt should be renamed:  listPicker.prompt
      if let pickerPrompt = ParameterHelper.getParameterAsString(cellParams: cellParams, paramName: Parameters.PickerPrompt.rawValue) {
        cell.listPicker.prompt = pickerPrompt
      }

      if let allowMultipleSelection = ParameterHelper.getParameterAsBool(cellParams: cellParams, paramName: Parameters.AllowMultipleSelection.rawValue) {
        cell.allowsMultipleSelection = allowMultipleSelection
      }

      if let allowEmptySelection = ParameterHelper.getParameterAsBool(cellParams: cellParams, paramName: Parameters.AllowEmptySelection.rawValue) {
        cell.allowsEmptySelection = allowEmptySelection
      } else {
        // set the default to true: SNOWBLIND-2409
        cell.allowsEmptySelection = true
      }
      if let isEditable = ParameterHelper.getParameterAsBool(cellParams: cellParams, paramName: Parameters.IsEditable.rawValue) {
        cell.isEditable = isEditable
      }

      // Styling
      if let styles = ParameterHelper.getParameterAsDictionary(cellParams: cellParams, paramName: Parameters.Styles.rawValue) {
        if let backgroundStyle = ParameterHelper.getParameterAsString(cellParams: styles, paramName: Parameters.Background.rawValue) {
          setBackgroundStyle(view: cell, style: backgroundStyle)
        }

        if let captionStyle = ParameterHelper.getParameterAsString(cellParams: styles, paramName: Parameters.Caption.rawValue) {
          cell.keyLabel.nuiClass = captionStyle
        }

        if let valueStyle = ParameterHelper.getParameterAsString(cellParams: styles, paramName: Parameters.Value.rawValue) {
          cell.valueTextField.nuiClass = valueStyle
        }
      }

      // set validation message and view
      setValidationView(for: cell, with: cellParams)
    }
    return cell
  }
  // swiftlint:enable function_body_length
  // swiftlint:enable cyclomatic_complexity

  private static func segmentedControlFormCell(tableView: UITableView, indexPath: IndexPath, cellParams: [String: Any],
                                               formCellController: FormCellContainerViewController, delegate: FormCellItemDelegate) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: FUISegmentedControlFormCell.reuseIdentifier, for: indexPath)
    if let cell =  cell as? FUISegmentedControlFormCell {
      if let caption = ParameterHelper.getParameterAsString(cellParams: cellParams, paramName: Parameters.Caption.rawValue) {
        cell.keyName = caption
      }
      if let segments = ParameterHelper.getParameterAsStringArray(cellParams: cellParams, paramName: Parameters.Segments.rawValue) {
        cell.valueOptions = segments
      }
      if let value = ParameterHelper.getParameterAsInt(cellParams: cellParams, paramName: Parameters.Value.rawValue) {
        cell.value = value
      }
      if let isEditable = ParameterHelper.getParameterAsBool(cellParams: cellParams, paramName: Parameters.IsEditable.rawValue) {
        cell.isEditable = isEditable
      }
      if let apportionsSegmentWidthsByContent = ParameterHelper.getParameterAsBool(cellParams: cellParams, paramName: Parameters.ApportionsSegmentWidthsByContent.rawValue) {
        cell.apportionsSegmentWidthsByContent = apportionsSegmentWidthsByContent
      }
      // Styling
      if let styles = ParameterHelper.getParameterAsDictionary(cellParams: cellParams, paramName: Parameters.Styles.rawValue) {

        if let backgroundStyle = ParameterHelper.getParameterAsString(cellParams: styles, paramName: Parameters.Background.rawValue) {
          setBackgroundStyle(view: cell, style: backgroundStyle)
        }

        if let captionStyle = ParameterHelper.getParameterAsString(cellParams: styles, paramName: Parameters.Caption.rawValue) {
          cell.keyLabel.nuiClass = captionStyle
        }
      }

      // set validation message and view
      setValidationView(for: cell, with: cellParams)
      cell.onChangeHandler = { newValue in
        self.needRedraw = true
        notifyFormCellUpdate(delegate, newValue, indexPath, formCellController)
      }
    }
    return cell
  }

// swiftlint:disable cyclomatic_complexity
  private static func filterFormCell(tableView: UITableView, indexPath: IndexPath, cellParams: [String: Any],
                                     formCellController: FormCellContainerViewController, delegate: FormCellItemDelegate, sorter: Bool) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: FUIFilterFormCell.reuseIdentifier, for: indexPath)
    if let cell =  cell as? FUIFilterFormCell {
      if let filterItems = ParameterHelper.getParameterAsStringArray(cellParams: cellParams,
                                                                     paramName: (sorter) ?
                                                                      Parameters.SortByItems.rawValue : Parameters.FilterItems.rawValue) {
        cell.valueOptions = filterItems
      }
      if sorter {
        cell.allowsMultipleSelection = false // not supported for sorter form cells
      } else {
        if let allowsMultipleSelection = ParameterHelper.getParameterAsBool(cellParams: cellParams, paramName: Parameters.AllowMultipleSelection.rawValue) {
          cell.allowsMultipleSelection = allowsMultipleSelection
        }
      }
      if let valuesSelected = ParameterHelper.getParameterAsIntArray(cellParams: cellParams, paramName: Parameters.Value.rawValue) {
        cell.value = valuesSelected
      }
      if let caption = ParameterHelper.getParameterAsString(cellParams: cellParams, paramName: Parameters.Caption.rawValue) {
        cell.keyName = caption
      }
      if let isEditable = ParameterHelper.getParameterAsBool(cellParams: cellParams, paramName: Parameters.IsEditable.rawValue) {
        cell.isEditable = isEditable
      }
      if let allowsEmptySelection = ParameterHelper.getParameterAsBool(cellParams: cellParams, paramName: Parameters.AllowEmptySelection.rawValue) {
        cell.allowsEmptySelection = allowsEmptySelection
      }

      // Styling
      if let styles = ParameterHelper.getParameterAsDictionary(cellParams: cellParams, paramName: Parameters.Styles.rawValue) {
        if let backgroundStyle = ParameterHelper.getParameterAsString(cellParams: styles, paramName: Parameters.Background.rawValue) {
          setBackgroundStyle(view: cell, style: backgroundStyle)
        }

        if let captionStyle = ParameterHelper.getParameterAsString(cellParams: styles, paramName: Parameters.Caption.rawValue) {
          cell.keyLabel.nuiClass = captionStyle
        }
      }

      // set validation message and view
      setValidationView(for: cell, with: cellParams)
      cell.onChangeHandler = { newValue in
        self.needRedraw = true
        notifyFormCellUpdate(delegate, newValue, indexPath, formCellController)
      }
    }
    return cell
  }

  private static func setValidationView(for cell: FUIInlineValidationTableViewCell, with cellParams: [String: Any]) {
    cell.validationMessage = ParameterHelper.getParameterAsString(cellParams: cellParams, paramName: Parameters.ValidationMessage.rawValue)
    if let validationMessageColor = ParameterHelper.getParameterAsColor(cellParams: cellParams, paramName: Parameters.ValidationMessageColor.rawValue) {
      cell.validationView.titleLabel.textColor = validationMessageColor
    }
    cell.validationView.separator.backgroundColor = ParameterHelper.getParameterAsColor(cellParams: cellParams, paramName: Parameters.SeparatorBackgroundColor.rawValue)
    if let separatorIsHidden = ParameterHelper.getParameterAsBool(cellParams: cellParams, paramName: Parameters.SeparatorIsHidden.rawValue) {
      cell.validationView.separator.isHidden = separatorIsHidden
    } else {
      cell.validationView.separator.isHidden = true
    }
    cell.validationView.backgroundColor = ParameterHelper.getParameterAsColor(cellParams: cellParams, paramName: Parameters.ValidationViewBackgroundColor.rawValue)
    if let validationViewIsHidden = ParameterHelper.getParameterAsBool(cellParams: cellParams, paramName: Parameters.ValidationViewIsHidden.rawValue) {
      cell.validationView.isHidden = validationViewIsHidden
    } else {
      cell.validationView.isHidden = true
    }
  }

  private static func attachmentFormCell(tableView: UITableView, indexPath: IndexPath, cellParams: [String: Any],
                                         formCellController: FormCellContainerViewController, delegate: FormCellItemDelegate) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: FUIAttachmentsFormCell.reuseIdentifier, for: indexPath)
    if let cell =  cell as? FUIAttachmentsFormCell {
      setupAttachmentFormCell(iPath: indexPath, formCellController: formCellController, attachmentCell: cell, cellParams: cellParams)
    }

    // Styling
    if let styles = ParameterHelper.getParameterAsDictionary(cellParams: cellParams, paramName: Parameters.Styles.rawValue) {
      if let backgroundStyle = ParameterHelper.getParameterAsString(cellParams: styles, paramName: Parameters.Background.rawValue) {
        setBackgroundStyle(view: cell, style: backgroundStyle)
      }
    }

    return cell
  }

  private static func setupAttachmentFormCell(iPath: IndexPath, formCellController: FormCellContainerViewController,
                                              attachmentCell: FUIAttachmentsFormCell, cellParams: [String: Any]) {
    var aDelegate = formCellController.aDelegates[iPath]
    if aDelegate == nil {
      aDelegate = AttachmentFormViewDelegate(controller: formCellController, indexPath: iPath, params: cellParams)
      formCellController.aDelegates.updateValue(aDelegate!, forKey: iPath)
    }

    let addTitle = ParameterHelper.getParameterAsString(cellParams: cellParams, paramName: Parameters.AttachmentAddTitle.rawValue)
    attachmentCell.attachmentsController.customPopupTitleString = addTitle
    let cancelTitle = ParameterHelper.getParameterAsString(cellParams: cellParams, paramName: Parameters.AttachmentCancelTitle.rawValue)
    attachmentCell.attachmentsController.customCancelString = cancelTitle

    let title = ParameterHelper.getParameterAsString(cellParams: cellParams, paramName: Parameters.AttachmentTitle.rawValue)
    attachmentCell.attachmentsController.customAttachmentsTitleFormat = title

    if let aTypes = ParameterHelper.getParameterAsStringArray(cellParams: cellParams, paramName: Parameters.AttachmentActionType.rawValue) {

      if aTypes.contains("AddPhoto") {
        let addPhotoAction = FUIAddPhotoAttachmentAction()
        addPhotoAction.delegate = aDelegate
        attachmentCell.attachmentsController.addAttachmentAction(addPhotoAction)
      }

      if aTypes.contains("TakePhoto") {
        let takePhotoAction = FUITakePhotoAttachmentAction()
        takePhotoAction.delegate = aDelegate
        attachmentCell.attachmentsController.addAttachmentAction(takePhotoAction)
      }
    }

    if let attachments = ParameterHelper.getParameterAsNSDictionaryArray(cellParams: cellParams, paramName: Parameters.Value.rawValue) {
      for attachmentEntry in attachments {
        aDelegate?.addAttachmentEntry(attachmentEntry: attachmentEntry)
      }
    }

    attachmentCell.attachmentsController.delegate = aDelegate
    attachmentCell.attachmentsController.dataSource = aDelegate

    // Styling
    if let styles = ParameterHelper.getParameterAsDictionary(cellParams: cellParams, paramName: Parameters.Styles.rawValue) {
      if let backgroundStyle = ParameterHelper.getParameterAsString(cellParams: styles, paramName: Parameters.Background.rawValue) {
        setBackgroundStyle(view: attachmentCell, style: backgroundStyle)
      }
    }

    attachmentCell.attachmentsController.reloadData()
  }
}
